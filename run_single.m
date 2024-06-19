% Get matrix name
matclass = 'PARSEC';
mat_stem = strcat('SuiteSparseMat/', matclass);
file_name = 'Si2.mat';

% Define *_name_stem
name = strrep(file_name, '.mat', ''); % remove ".mat" from file_name

% Read the matrix
t = open(fullfile(mat_stem, file_name));
A = t.Problem.A;
clear t

% Shift the matrix to compute the bottom eigenvalue
[v,lambdamax] = eigs(A,1);
n = size(A,1);
A = speye(n,n)-A/(lambdamax+0.1);


matinfo = struct( ...
    'MatClass',         'PARSEC', ...
    'MatName',          'Si2', ...
    'Transform',        'ShiftByMax', ...
    'CanComputeEigval', 1 );

config = struct( ...
    'SubspaceDim',  100, ...
    'MaxIter',      5, ...
    'K',            10, ...
    'Method',       'largestabs');

RRType = 'classical';
run_save(A, matinfo, RRType, config);

RRType = 'rand';
run_save(A, matinfo, RRType, config);

plot_matvec_save(matinfo,config)