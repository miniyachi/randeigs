matclass = 'PARSEC';
dir_stem = strcat('SuiteSparseMat/', matclass);
file_list = dir(strcat(dir_stem,'/*.mat'));
name_list = {file_list.name};
name_list = {'Si2.mat'};

tol = 1e-10;
K = 10;
maxiter = 1;

% Define the range and step size for maxiter_list (i.e. restarting iter)
m_list = [15:10:200]';

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
    lambdatrues = eigs(A,K,'largestabs','MaxIterations',100,'SubspaceDimension',500);
    
    % Initialize an array to store results
    classical_errs = zeros(K,size(m_list,2));
    rand_errs = zeros(K,size(m_list,2));
    eigs_errs = zeros(K,size(m_list,2));
    
    for j = 1:length(m_list)
        % Print current progress
        m = m_list(j);
        fprintf('m = %d (%s)\n', m, file_name);
    
        % 
        fprintf('randeigs with classical Rayleigh–Ritz approximation (classical Galerkin)... \n');  
        tic
        [V,D,flag] = randeigs(A,[],K,'largestabs','SubspaceDimension',m,'MaxIterations', maxiter,'Tolerance',tol,'ExactProj',1,'Display',0,'InvertOperator',1);
        toc
        classical_errs(:,j) = compute_errors(lambdatrues, diag(D));
        clear V
        
        %
        fprintf('randeigs with randomozed Rayleigh–Ritz approximation (sketched Galerkin)... \n');  
        tic
        [V,D,flag] = randeigs(A,[],K,'largestabs','SubspaceDimension',m,'MaxIterations', maxiter,'Tolerance',tol,'ExactProj',0,'Display',0,'InvertOperator',1);
        toc
        rand_errs(:,j) = compute_errors(lambdatrues, diag(D));
        clear V

        %
        fprintf('built-in eigs... \n');  
        tic
        [V,D,flag] = eigs(A, K, 'largestabs', 'SubspaceDimension', m, 'MaxIterations', maxiter, 'Tolerance',tol, 'Display', 0, 'FailureTreatment', 'keep');
        toc
        eigs_errs(:,j) = compute_errors(lambdatrues, diag(D));
        clear V
    end
    
    % Define directory to save the results
    name = strrep(file_name, '.mat', '');   % remove ".mat" from file_name
    save_dir_stem = fullfile('results/m_varies', matclass, name);
    
    % Check if the directory exists
    if exist(save_dir_stem, 'dir') ~= 7
        % Directory does not exist, create it
        mkdir(save_dir_stem);
    end
    
    % Save the errors files
    save_filename = strcat(name, '_EigvalsErrors_noorder_', sprintf('maxiter=%d', maxiter), '.mat'); % saved errors file name: {name}_EigvalsErrors_m={m}.mat
    save(fullfile(save_dir_stem, save_filename), 'classical_errs', 'rand_errs', 'eigs_errs', 'm_list', 'm');

    % Save the figure
    name = strrep(file_name, '.mat', ''); % remove ".mat" from file_name
    export_summary = true;
    run("plot_m.m");
end
