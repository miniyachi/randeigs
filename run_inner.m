matclass = 'VLSI';
dir_stem = strcat('SuiteSparseMat/', matclass);
file_list = dir(strcat(dir_stem,'/*.mat'));
% name_list = {file_list.name};
% name_list = {'Si2.mat'};
name_list = {'vas_stokes_1M.mat'};

tol = 1e-10;
K = 10;
m = 400;
maxiter = 5;

for i = 1:length(name_list)
    fprintf(repmat('=', 1, 100));
    fprintf('\n');

    % Get file name
    file_name = name_list{i};
    fprintf('Run for matrix %s...\n', file_name);

    % Read the matrix
    t = open(fullfile(dir_stem, file_name));
    A = t.Problem.A;
    clear t
    
    % Shift the matrix to compute the bottom eigenvalue
    [v,lambdamax] = eigs(A,1);
    lambdamax = norm(A*v)/norm(v);
    n = size(A,1);
    A = speye(n,n)-A/(lambdamax+0.1);
    
    % Obtain top K true eigvals from eigs
    fprintf('Getting lambdatrues...\n');
    lambdatrues = eigs(A,K,'largestabs','MaxIterations',500,'SubspaceDimension',min(size(A,1),1000));
     
    % 
    fprintf('randeigs with classical Rayleigh–Ritz approximation (classical Galerkin)... \n');  
    tic
    [V,D,flag,ds,pd] = randeigs(A,[],K,'largestabs','SubspaceDimension',m,'MaxIterations', maxiter,'Tolerance',tol,'ExactProj',1,'Display',0,'InvertOperator',1,'TrackVals',1);
    toc
    classical_errs = compute_errors(lambdatrues, ds);
    classical_pos_dim = pd;
    clear V
    
    %
    fprintf('randeigs with randomozed Rayleigh–Ritz approximation (sketched Galerkin)... \n');  
    tic
    [V,D,flag,ds,pd] = randeigs(A,[],K,'largestabs','SubspaceDimension',m,'MaxIterations', maxiter,'Tolerance',tol,'ExactProj',0,'Display',0,'InvertOperator',1,'TrackVals',1);
    toc
    rand_errs = compute_errors(lambdatrues, ds);
    rand_pos_dim = pd;
    clear V
    
    % Define directory to save the results
    name = strrep(file_name, '.mat', '');   % remove ".mat" from file_name
    save_dir_stem = fullfile('results/inner', matclass, name);

    % Check if the directory exists
    if exist(save_dir_stem, 'dir') ~= 7
        % Directory does not exist, create it
        mkdir(save_dir_stem);
    end

    % Save the errors files
    save_filename = strcat(name, '_EigvalsErrors_', sprintf('m=%d_maxiter=%d', m, maxiter), '.mat'); % file name: {name}_EigvalsErrors_m={m}_maxiter={maxiter}.mat
    save(fullfile(save_dir_stem, save_filename), 'classical_errs', 'rand_errs', 'classical_pos_dim', 'rand_pos_dim', 'm', 'maxiter');

    % Save the figure
    name = strrep(file_name, '.mat', ''); % remove ".mat" from file_name
    export_summary = true;
    run("plot_inner.m");
end
