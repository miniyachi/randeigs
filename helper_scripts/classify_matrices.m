% Define the directory containing .mat files
source_directory = 'SuiteSparseMat';

% Define the directories for different matrix dimensions
small_matrix_directory = 'SuiteSparseMat/Small';
e5_matrix_directory = 'SuiteSparseMat/AtLeast1e5';
e6_matrix_directory = 'SuiteSparseMat/AtLeast1e6';

% Get a list of all .mat files in the source directory
mat_files = dir(fullfile(source_directory, '*.mat'));

% Loop through each .mat file
for i = 1:length(mat_files)
    % Load the matrix from the file
    file_path = fullfile(source_directory, mat_files(i).name);
    mat_data = open(file_path);
    matrix = mat_data.Problem.A;  % Assuming the matrix variable in the .mat file is named 'matrix'
    clear mat_data
    
    % Classify the matrix based on its dimensions
    matrix_size = size(matrix,1);
    if matrix_size <= 1e5  % Small matrix
        destination_directory = small_matrix_directory;
    elseif matrix_size <= 1e6
        destination_directory = e5_matrix_directory;
    else
        destination_directory = e6_matrix_directory;
    end
    
    % Move the file to the corresponding directory
    movefile(file_path, destination_directory);
end
