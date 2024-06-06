saved = true;
fignums = 10;

n_classical = size(classical_errs,2);
n_rand = size(rand_errs,2);



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
    
    % Set up legend, label, title
    legend([ls; hcxline; hrxline], 'Classical RR', 'Randomized RR', 'restart (classical)', 'restart (rand)');
    xlabel('Subspace dimension after restart');
    ylabel('Relative error $\frac{\min_{j}{|\lambda_j - \lambda_i^{\ast}|}}{|\lambda_i|}$','interpreter','latex');
    titlename = strrep(name, '_', '\_'); % To make sure "_" display properly
    title(strcat(titlename, sprintf(' (m=%d, maxiter=%d, %s eigenvalue)', m, maxiter, toOrdinal(t))));
    grid on;

    % Save the figure
    if saved
        % Set up directory and make it if not exists
        save_stem = fullfile('figs/inner', matclass, name, sprintf('m=%d_maxiter=%d', m, maxiter));
        mymakedir(save_stem)
        
        % Save the figure
        figname = strcat(name, '_', sprintf('m=%d_maxiter=%d_%s_eigvals.pdf', m, maxiter, toOrdinal(t)));
        saveas(f(t), fullfile(save_stem, figname));
        
        % Export as a summary pdf file
        if export_summary
            summary_stem = fullfile('figs/inner', matclass, 'Summary', sprintf('m=%d_maxiter=%d', m, maxiter));
            mymakedir(summary_stem);
            summary_path_name = fullfile(summary_stem, strcat(matclass, sprintf('_m=%d_maxiter=%d_%s_eigvals_summary.pdf', m, maxiter, toOrdinal(t))));
            exportgraphics(f(t), summary_path_name, 'Append', true);
        end
    end
end