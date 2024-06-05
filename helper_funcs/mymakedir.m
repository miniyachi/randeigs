function mymakedir(stem)
    % Check if the directory exists
    if exist(stem, 'dir') ~= 7
        % Directory does not exist, create it
        mkdir(stem);
    end
end