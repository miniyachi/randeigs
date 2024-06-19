matclass = 'PARSEC';
mat_stem = strcat('SuiteSparseMat/', matclass);
file_list = dir(strcat(mat_stem,'/*.mat'));
name_list = {file_list.name};
% name_list = {'Si2.mat'};
% name_list = {'vas_stokes_1M.mat'};
% name_list = name_list(1);

tol = 1e-10;
K = 10;
maxiter = 10;

% Define the range and step size for maxiter_list (i.e. restarting iter)
m_list = [13:2:21]';

% Define saving stems
path_experiment_matclass = fullfile('matvec', matclass);
path_maxiter = sprintf('maxiter=%d', maxiter);
fig_stem = fullfile('figs', path_experiment_matclass);
results_stem = fullfile('results', path_experiment_matclass);

% Set up summary file path and delete existing file if clear_summary=true
export_summary = true;
clear_summary = true;
summary_dir = fullfile(fig_stem, 'Summary', path_maxiter);
if export_summary && clear_summary && exist(summary_dir, 'dir')
    rmdir(summary_dir, 's');
    disp(['Directory ', summary_dir, ' has been deleted before creating new summary.']);
end

% Main loop
for i = 1:length(name_list)
    fprintf(repmat('=', 1, 100));
    fprintf('\n');

    % Get matrix name
    file_name = name_list{i};
    fprintf('Run for matrix %s...\n', file_name);
    
    % Define *_name_stem
    name = strrep(file_name, '.mat', ''); % remove ".mat" from file_name
    results_name_stem = fullfile('results', path_experiment_matclass, name);

    % Create stem directory if not exist
    mymakedir(results_name_stem);

    % Read the matrix
    t = open(fullfile(mat_stem, file_name));
    A = t.Problem.A;
    clear t
    
    % Shift the matrix to compute the bottom eigenvalue
    [v,lambdamax] = eigs(A,1);
    lambdamax = norm(A*v)/norm(v);
    n = size(A,1);
    A = speye(n,n)-A/(lambdamax+0.1);
    
    % Obtain top K true eigvals
    fprintf('Getting lambdatrues... ');
    trueeigvals_stem = fullfile('TrueEigvals', name);
    mymakedir(trueeigvals_stem);
    filepath_lambdatrues = fullfile(trueeigvals_stem, strcat(name, '_shifted_lambdatrues.mat'));
    if exist(filepath_lambdatrues, 'file') == 2
        % Load the file to obtain lambdatrues
        fprintf('Loading from existing file...\n');
        lambdatrues = load(filepath_lambdatrues, 'lambdatrues').lambdatrues;
    else
        fprintf('File not exists. Running eigs...');
        lambdatrues = eigs(A,K,'largestabs','MaxIterations',500,'SubspaceDimension',min(size(A,1),800),'Display',1);
        save(filepath_lambdatrues, 'lambdatrues');    
    end

    % Initialize an array to store results
    classical_errs_list = {};
    rand_errs_list = {};
    
    for j = 1:length(m_list)
        m = m_list(j);
        fprintf(repmat('-.', 1, 50));
        fprintf('\n');
        fprintf('m = %d (%s)\n', m, file_name);
        
        % 
        fprintf('randeigs with classical Rayleigh–Ritz approximation (classical Galerkin)... \n');
        I = @(x) x;
        tic
        [V,D,flag,ds,pd] = randeigs(A,[],K,'largestabs','SubspaceDimension',m,'MaxIterations', maxiter,'Tolerance',tol,'ExactProj',0,'Display',0,'InvertOperator',1,'TrackVals',1, ...
                                                        'SketchingMatrixFun',@() I);
        toc
        classical_errs_list{j} = compute_errors(lambdatrues, ds);
        % classical_pos_dim = pd;
        clear V
        
        %
        fprintf('randeigs with randomozed Rayleigh–Ritz approximation (sketched Galerkin)... \n');  
        tic
        [V,D,flag,ds,pd] = randeigs(A,[],K,'largestabs','SubspaceDimension',m,'MaxIterations', maxiter,'Tolerance',tol,'ExactProj',0,'Display',0,'InvertOperator',1,'TrackVals',1);
        toc
        rand_errs_list{j} = compute_errors(lambdatrues, ds);
        % rand_pos_dim = pd;
        clear V
    end

    % Save the errors files
    filename_errors = strcat(name, '_EigvalsErrors_', path_maxiter, '.mat'); % file name: {name}_EigvalsErrors_m={m}_maxiter={maxiter}.mat
    save(fullfile(results_name_stem, filename_errors), 'classical_errs_list', 'rand_errs_list', 'm', 'maxiter', ...
                                                       'matclass', 'fig_stem', 'name', 'path_maxiter');
    fprintf(repmat('-.', 1, 50));
    fprintf('\n');
    % Generate and save the figure
    run("plot_matvec.m");
end
