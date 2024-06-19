% matclass = 'Fluorem';
% mat_stem = strcat('SuiteSparseMat/', matclass);
% file_list = dir(strcat(mat_stem,'/*.mat'));
% name_list = {file_list.name};
% name_list = {'Si2.mat'};
% name_list = {'vas_stokes_1M.mat'};
name_list = {'PR02R.mat'};

matclass = 'Interested';
% name_list = load(fullfile('SuiteSparseMat','interest_list.mat')).interest_list;

saved = true;
metric = 'residual';
% metric = 'lambdatrue';

tol = 1e-10;
K = 10;
m = 1000;

% Define saving stems
path_experiment_matclass = fullfile('restarting', matclass);
path_m = sprintf('m=%d', m);
path_metric = sprintf('metric=%s', metric);
fig_stem = fullfile('figs', path_experiment_matclass);
results_stem = fullfile('results', path_experiment_matclass);

% Set up summary file path and delete existing file if clear_summary=true
export_summary = false;
clear_summary = true;
summary_dir = fullfile(fig_stem, 'Summary', path_metric, path_m);
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
    results_name_stem = fullfile('results', path_experiment_matclass, name, path_metric);

    % Create stem directory if not exist
    mymakedir(results_name_stem);

    % Read the matrix
    file_info = dir(fullfile('SuiteSparseMat','**',file_name));
    t = open(fullfile(file_info(1).folder, file_name));
    A = t.Problem.A;
    clear t
    
    % Shift the matrix to compute the bottom eigenvalue
    [v,lambdamax] = eigs(A,1);
    lambdamax = norm(A*v)/norm(v);
    n = size(A,1);
    A = speye(n,n)-A/(lambdamax+0.1);
    
    if strcmp(metric,'lambdatrue')
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
            fprintf('File not exists. Running eigs...\n');
            ml_dim = floor(2147483648 / size(A,1)); % make sure that memory for subspace basis not exceed 16GB
            lambdatrues = eigs(A,K,'largestabs','MaxIterations',60,'SubspaceDimension',min([size(A,1),ml_dim,1200]),'Display',1);
            save(filepath_lambdatrues, 'lambdatrues');    
        end
        fprintf(repmat('-.', 1, 50));
        fprintf('\n');
    elseif strcmp(metric,'residual')
        lambdatrues = [];
    end

    % Generate the list
    maxiter_list = [1:1:4]';

    % Initialize an array to store results
    classical_errs = zeros(K,size(maxiter_list,2));
    rand_errs = zeros(K,size(maxiter_list,2));
    eigs_errs = zeros(K,size(maxiter_list,2));
    
    for j = 1:length(maxiter_list)
        % Print current progress
        maxiter = maxiter_list(j);
        fprintf(repmat('-.', 1, 50));
        fprintf('\n');
        fprintf('maxiter = %d (%s)\n', maxiter, file_name);
    
        % 
        fprintf('randeigs with classical Rayleigh–Ritz approximation (classical Galerkin)... \n');
        I = @(x) x;
        tic
        [V,D,flag,errs,pd] = randeigs(A,[],K,'largestabs','SubspaceDimension',m,'MaxIterations', maxiter,'Tolerance',tol,'ExactProj',1,'Display',1,'InvertOperator',1, ...
                                             'TrackInner',0, 'Metric', metric, 'Lambdatrue', lambdatrues);
        toc
        classical_errs(:,j) = compute_residuals(A,V,diag(D));
        clear V
        
        %
        fprintf('randeigs with randomozed Rayleigh–Ritz approximation (sketched Galerkin)... \n');  
        tic
        [V,D,flag,errs,pd] = randeigs(A,[],K,'largestabs','SubspaceDimension',m,'MaxIterations', maxiter,'Tolerance',tol,'ExactProj',0,'Display',1,'InvertOperator',1, ...
                                             'TrackInner',0, 'Metric', metric, 'Lambdatrue', lambdatrues);
        toc
        rand_errs(:,j) = compute_residuals(A,V,diag(D));
        clear V
    end

    % Save the errors files
    if saved
        filename_errors = strcat(name, '_EigvalsErrors_', path_m, '.mat'); % file name: {name}_EigvalsErrors_m={m}_maxiter={maxiter}.mat
        save(fullfile(results_name_stem, filename_errors), 'classical_errs', 'rand_errs', 'm', ...
                                                           'matclass', 'fig_stem', 'name', 'path_m');
    end

    % Generate and save the figure
    run("plot_restarting_new.m");
end
