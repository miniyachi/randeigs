function ordinal_str = toOrdinal(t)
    % Define the suffixes for ordinal numbers
    suffixes = {'st', 'nd', 'rd', 'th'};
    
    % Convert t to a string
    t_str = num2str(t);
    
    % Check if t ends with 11, 12, or 13 (special cases)
    if mod(t, 100) >= 11 && mod(t, 100) <= 13
        suffix_idx = 4;  % Use 'th' for these cases
    else
        % Otherwise, determine the suffix based on the last digit
        last_digit = mod(t, 10);
        if last_digit == 0
            suffix_idx = 4;
        else
            suffix_idx = min(last_digit, length(suffixes));
        end
    end
    
    % Construct the ordinal string
    ordinal_str = [t_str, suffixes{suffix_idx}];
end