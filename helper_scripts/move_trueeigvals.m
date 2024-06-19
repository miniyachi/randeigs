% Define the source directory and target directory
sourceDir = 'TrueEigvals';
targetDir = 'TrueEigvals';

% Ensure the target directory exists, if not, create it
if ~exist(targetDir, 'dir')
    mkdir(targetDir);
end

% Recursively search for all files named 'shifted_lambdatrues.mat'
filePattern = fullfile(sourceDir, '**', '*_lambdatrues.mat');
files = dir(filePattern);

% Loop through each file found
for k = 1:length(files)
    % Get the full path of the current file
    currentFilePath = fullfile(files(k).folder, files(k).name);
    
    % Extract the name of the last-level folder
    [~, parentFolderName] = fileparts(files(k).folder);

    % Load the file
    lambdatrues = load(currentFilePath).lambdatrues;
    K = length(lambdatrues);
    
    % Construct the new file name with the parent folder name
    newFileName = [parentFolderName, '_ShiftByMax', sprintf('_K=%d', K), '_lambdatrues.mat'];
    
    % Construct the full path for the new file location
    newFileDir = fullfile(targetDir, parentFolderName);
    mymakedir(newFileDir);
    newFilePath = fullfile(newFileDir, newFileName);
    
    % Move and rename the file to the target directory
    movefile(currentFilePath, newFilePath);
end

disp('Files have been moved and renamed successfully.');
