n_classical = size(classical_errs,2);
n_rand = size(rand_errs,2);
K = size(classical_errs,1); % = number of requested eigvals

fignums = K;

% Define figure saving stem and create it if not exist
fig_name_maxiter_stem = fullfile(fig_stem, name, path_metric, path_maxiter);
mymakedir(fig_name_maxiter_stem);

for t = 1:fignums
    %% Absolute relative errors
    % Plot the absolute relative errors versus maxiter_list
    f(t) = figure('visible','off');
    ls = semilogy(m_list, abs(classical_errs(t,:)), 'o-', ...
                  m_list, abs(rand_errs(t,:)),      '*-', ...
                  'LineWidth', 1.5, 'MarkerSize',4);

    % Set x-tick as integers
    curtick = get(gca, 'xTick');
    xticks(unique(round(curtick)));
    
    % Set up legend, label
    legend('Classical RR', 'Randomized RR');
    xlabel('m');    
    if strcmp(metric,'residual')
        ylabel('Residual $||A x - \lambda x||_2$','interpreter','latex');
    elseif strcmp(metric,'lambdatrue')
        ylabel('Relative error $\frac{\min_{j}{|\lambda_j - \lambda_i^{\ast}|}}{|\lambda_i|}$','interpreter','latex');
    end

    
    % Set up title
    titlename = strrep(name, '_', '\_'); % To make sure "_" display properly
    title(strcat(titlename, sprintf(' (maxiter=%d, %s eigenvalue)', maxiter, toOrdinal(t))));
    grid on;

    % Save the figure
    if saved
        path_whicheigval = sprintf('%s_eigvals', toOrdinal(t));

        % Save the figure
        figname = strcat(name, '_', path_metric, '_', path_maxiter, '_', path_whicheigval, '.pdf'); % file name: {name}_maxiter={maxiter}_{which}_eigvals.pdf
        saveas(f(t), fullfile(fig_name_maxiter_stem, figname));
        
        % Export as a summary pdf file
        if export_summary
            mymakedir(summary_dir);
            filename_summary = strcat(matclass, '_', path_metric, '_', path_maxiter, '_', path_whicheigval, '_summary.pdf'); % file name: {matclass}_maxiter={maxiter}_{which}_eigvals_summary.pdf
            filepath_summary = fullfile(summary_dir, filename_summary);
            exportgraphics(f(t), filepath_summary, 'Append', true);
        end
    end
end