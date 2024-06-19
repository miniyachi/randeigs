function run_save(A, matinfo, RRType, config)
    
    tol = 1e-10;
    
    %% Extract matrix info
    class = matinfo.MatClass;
    name = matinfo.MatName;
    Transform = matinfo.Transform; % ['ShiftByMax']
    CanComputeEigval = matinfo.CanComputeEigval;
    fprintf('Run for matrix %s...\n', name);

    %% Extract input arguments
    m = config.SubspaceDim;
    maxiter = config.MaxIter;
    K = config.K;
    method = config.Method;
    
    if strcmp(RRType, 'classical')
        ExactProj = 0; % This is 0 since we set SketchingMatrixFun to be identity
        I = @(x) x;
        sketching_fun = @() I;
    elseif strcmp(RRType, 'rand')
        ExactProj = 0;
    else
        error('InputError:RR_type', 'Unknown RR_type. Must be "classical" or "rand".');
    end

    %% Set lambdatrues
    if CanComputeEigval % will not take too long
        fprintf('Getting lambdatrues... ');

        % Make dir if not exists
        Dir = fullfile('TrueEigvals', name);
        mymakedir(Dir);
        
        % Full path
        FileName = [name, '_', Transform, sprintf('_K=%d', K), '_lambdatrues.mat'];
        FilePath = fullfile(Dir, FileName);

        % Load if exists; otherwise, compute and save
        if exist(FilePath, 'file') == 2  % exists
            fprintf('Loading from existing file...\n');
            lambdatrues = load(FilePath, 'lambdatrues').lambdatrues;
        else CanComputeEigval  % not exists
            fprintf('File not exists. Running eigs...\n');
            max_dim = floor(2147483648 / size(A,1)); % make sure that memory for subspace basis not exceed 16GB
            lambdatrues = eigs(A,K,'largestabs','MaxIterations',60,'SubspaceDimension',min([size(A,1),max_dim,1200]),'Display',1);
            save(FilePath, 'lambdatrues');
        end
    else
        fprintf('Not using lambdatrues for time efficiency.')
        lambdatrues = [];
    end
    fprintf(repmat('-.', 1, 50));
    fprintf('\n');

    %% Run randeigs()
    fprintf('randeigs with %s Rayleigh–Ritz approximation (classical Galerkin)... \n', RRType);
    
    if strcmp(RRType, 'classical')
        tic
        [V,D,flag,output] = randeigs(A, [], K, ...
                                     method, ...
                                     'SubspaceDimension', m, ...
                                     'MaxIterations', maxiter, ...
                                     'Tolerance', tol, ...
                                     'ExactProj', ExactProj, ...
                                     'Display', 1, ...
                                     'InvertOperator', 1, ...
                                     'TrackInner',1, ...
                                     'Lambdatrue', lambdatrues, ...
                                     'SketchingMatrixFun',@() I);
        toc
    elseif strcmp(RRType, 'rand')
        tic
        [V,D,flag,output] = randeigs(A, [], K, ...
                                     method, ...
                                     'SubspaceDimension', m, ...
                                     'MaxIterations', maxiter, ...
                                     'Tolerance', tol, ...
                                     'ExactProj', ExactProj, ...
                                     'Display', 1, ...
                                     'InvertOperator', 1, ...
                                     'TrackInner',1, ...
                                     'Lambdatrue', lambdatrues);
        toc
    end

    %% Save output for later analysis
    str_method_K_m_maxiter = sprintf('%s_K=%d_m=%d_maxiter=%d', method, K, m, maxiter);
    Dir = fullfile('results', class, name, Transform, RRType);
    FileName = [name, '_' , RRType, '_', str_method_K_m_maxiter, '.mat'];
    FilePath = fullfile(Dir, FileName);
    mymakedir(Dir);
    save(FilePath, 'output', 'matinfo', 'config');
end