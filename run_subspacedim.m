% Plot relative errors versus subspace dimension

% Load l.h.s. matrix.
path_stem = 'SuiteSparseMat';
t = open(fullfile(path_stem, 'AtLeast1e5', 'ML_Geer.mat'));

A = t.Problem.A;
clear t

maxiter = 50;
tol = 1e-10;
K = 10;

% Define the range and step size for m_list
m_start = 20;
m_end = 200;
step_size = 20;
m_list = m_start:step_size:m_end;

% Initialize an array to store results
classical_errs = zeros(K,size(m_list,2));
rand_errs = zeros(K,size(m_list,2));

% Loop over each value of m
for i = 1:length(m_list)
    m = m_list(i);
    fprintf('m = %d\n', m);
    
    % 
    fprintf('randeigs with classical Rayleigh–Ritz approximation (classical Galerkin)... \n');  
    tic
    [V,D,flag] = randeigs(A,[],K,'largestabs','SubspaceDimension',m,'MaxIterations', maxiter,'Tolerance',tol,'ExactProj',1,'Display',0,'InvertOperator',1);
    toc
    col_norms = sqrt(sum(V.^2, 1));
    classical_errs(:,i) = norm(A * V - V * D) ./ col_norms;
    clear V
    
    %
    fprintf('randeigs with randomozed Rayleigh–Ritz approximation (sketched Galerkin)... \n');  
    tic
    [V,D,flag] = randeigs(A,[],K,'largestabs','SubspaceDimension',m,'MaxIterations', maxiter,'Tolerance',tol,'ExactProj',0,'Display',0,'InvertOperator',1);
    toc
    col_norms = sqrt(sum(V.^2, 1));
    rand_errs(:,i) = norm(A * V - V * D) ./ col_norms;
    clear V
end



% save('ML_Geer_errors_5_200.mat', 'classical_errs', 'rand_errs', 'm_list');
