n_classical = size(classical_errs,2);
n_rand = size(rand_errs,2);
K = size(classical_errs,1); % = number of requested eigvals

fignums = K;

% Define figure saving stem and create it if not exist
fig_name_m_maxiter_stem = fullfile(fig_stem, name, path_metric, path_m_maxiter);
mymakedir(fig_name_m_maxiter_stem);

for t = 1:fignums
    %% Absolute relative errors
    % Plot the absolute relative errors versus maxiter_list
    f(t) = figure('visible','off');
    ls = semilogy(1:n_classical, abs(classical_errs(t,:)), 'o-', ...
                  1:n_rand,      abs(rand_errs(t,:)),      '*-', ...
                  'LineWidth', 1.5, 'MarkerSize',4);
    hold on; % To add additional plots to the same figure

    % Add vertical red dashed lines for classical_pos_dim
    for idx = classical_pos_dim(1,:)
        hcxline = xline(idx, 'm-.', 'LineWidth', 2);
    end
    
    % Add vertical red dashed lines for rand_pos_dim
    for idx = rand_pos_dim(1,:)
        hrxline = xline(idx, 'g--', 'LineWidth', 2);
    end
    
    hold off; % Release the hold on the current figure
    
    % Set custom x-ticks and labels
    xticks(classical_pos_dim(1,:));  % Set x-tick positions
    
    % Convert numeric labels to strings
    custom_labels = arrayfun(@num2str, classical_pos_dim(2,:), 'UniformOutput', false);
    xticklabels(custom_labels); % Set x-tick labels
    
    % Set up legend, label
    legend([ls; hcxline; hrxline], 'Classical RR', 'Randomized RR', 'restart (classical)', 'restart (rand)');
    xlabel('Subspace dimension after restart');
    
    if strcmp(metric,'residual')
        ylabel('Residual $||A x - \lambda x||_2$','interpreter','latex');
    elseif strcmp(metric,'lambdatrue')
        ylabel('Relative error $\frac{\min_{j}{|\lambda_j - \lambda_i^{\ast}|}}{|\lambda_i|}$','interpreter','latex');
    end

    
    % Set up title
    titlename = strrep(name, '_', '\_'); % To make sure "_" display properly
    title(strcat(titlename, sprintf(' (m=%d, maxiter=%d, %s eigenvalue)', m, maxiter, toOrdinal(t))));
    grid on;

    % Save the figure
    if saved
        path_whicheigval = sprintf('%s_eigvals', toOrdinal(t));

        % Save the figure
        figname = strcat(name, '_', path_metric, '_', path_m_maxiter, '_', path_whicheigval, '.pdf'); % file name: {name}_m={m}_maxiter={maxiter}_{which}_eigvals.pdf
        saveas(f(t), fullfile(fig_name_m_maxiter_stem, figname));
        
        % Export as a summary pdf file
        if export_summary
            mymakedir(summary_dir);
            filename_summary = strcat(matclass, '_', path_metric, '_', path_m_maxiter, '_', path_whicheigval, '_summary.pdf'); % file name: {matclass}_m={m}_maxiter={maxiter}_{which}_eigvals_summary.pdf
            filepath_summary = fullfile(summary_dir, filename_summary);
            exportgraphics(f(t), filepath_summary, 'Append', true);
        end
    end
end