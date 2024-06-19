saved = true;

%% For classical RR
fprintf('Saving figures for classical RR...\n');
% Determine the number of arrays (L) and the number of rows (fignums)
L = length(classical_errs_list);
fignums = size(classical_errs_list{1},1); % = number of requested eigvals

% Define figure saving stem and create it if not exist
fig_name_classical_stem = fullfile(fig_stem, name, 'classical', path_maxiter);
mymakedir(fig_name_classical_stem);

for row = 1:fignums
    % Create a new figure for each array
    f(row) = figure('visible','off');

    for i = 1:L
        % Get the current array
        classical_errs = classical_errs_list{i};
        
        % Plot the row
        semilogy(classical_errs(row, :), 'o-', 'DisplayName', sprintf('m = %d', m_list(i)), ...
                 'LineWidth', 1.5, 'MarkerSize',4);
        hold on;
    end
    
    hold off; % Release the hold on the current figure
    
    % Set x-tick as integers
    curtick = get(gca, 'xTick');
    xticks(unique(round(curtick)));
    
    % Set up legend, label
    legend show;
    xlabel('Inner iteration');
    ylabel('Relative error $\frac{\min_{j}{|\lambda_j - \lambda_i^{\ast}|}}{|\lambda_i|}$','interpreter','latex');
    
    % Set up title
    titlename = strrep(name, '_', '\_'); % To make sure "_" display properly
    title(strcat(titlename, sprintf(' (classical, maxiter=%d, %s eigenvalue)', maxiter, toOrdinal(row))));
    grid on;

    % Save the figure
    if saved
        path_whicheigval = sprintf('%s_eigvals', toOrdinal(row));

        % Save the figure
        figname = strcat(name, '_', path_maxiter, '_', path_whicheigval, '.pdf'); % file name: {name}_maxiter={maxiter}_{which}_eigvals.pdf
        saveas(f(row), fullfile(fig_name_classical_stem, figname));
        
        % Export as a summary pdf file
        if export_summary
            mymakedir(summary_dir);
            filename_summary = strcat(matclass, '_', path_maxiter, '_classical_', path_whicheigval, '_summary.pdf'); % file name: {matclass}_maxiter={maxiter}_classical_{which}_eigvals_summary.pdf
            filepath_summary = fullfile(summary_dir, filename_summary);
            exportgraphics(f(row), filepath_summary, 'Append', true);
        end
    end
end


%% For rand RR
fprintf('Saving figures for randomized RR...\n');
% Determine the number of arrays (L) and the number of rows (fignums)
L = length(rand_errs_list);
fignums = size(rand_errs_list{1},1); % = number of requested eigvals

% Define figure saving stem and create it if not exist
fig_name_rand_stem = fullfile(fig_stem, name, 'rand', path_maxiter);
mymakedir(fig_name_rand_stem);

for row = 1:fignums
    % Create a new figure for each array
    f(row) = figure('visible','off');

    for i = 1:L
        % Get the current array
        rand_errs = rand_errs_list{i};
        
        % Plot the row
        semilogy(rand_errs(row, :), 'o-', 'DisplayName', sprintf('m = %d', m_list(i)), ...
                 'LineWidth', 1.5, 'MarkerSize',4);
        hold on;
    end
    
    hold off; % Release the hold on the current figure
    
    % Set x-tick as integers
    curtick = get(gca, 'xTick');
    xticks(unique(round(curtick)));
    
    % Set up legend, label
    legend show;
    xlabel('Inner iteration');
    ylabel('Relative error $\frac{\min_{j}{|\lambda_j - \lambda_i^{\ast}|}}{|\lambda_i|}$','interpreter','latex');
    
    % Set up title
    titlename = strrep(name, '_', '\_'); % To make sure "_" display properly
    title(strcat(titlename, sprintf(' (randomized, maxiter=%d, %s eigenvalue)', maxiter, toOrdinal(row))));
    grid on;

    % Save the figure
    if saved
        path_whicheigval = sprintf('%s_eigvals', toOrdinal(row));

        % Save the figure
        figname = strcat(name, '_', path_maxiter, '_', path_whicheigval, '.pdf'); % file name: {name}_maxiter={maxiter}_{which}_eigvals.pdf
        saveas(f(row), fullfile(fig_name_rand_stem, figname));
        
        % Export as a summary pdf file
        if export_summary
            mymakedir(summary_dir);
            filename_summary = strcat(matclass, '_', path_maxiter, '_rand_', path_whicheigval, '_summary.pdf'); % file name: {matclass}_maxiter={maxiter}_rand_{which}_eigvals_summary.pdf
            filepath_summary = fullfile(summary_dir, filename_summary);
            exportgraphics(f(row), filepath_summary, 'Append', true);
        end
    end
end