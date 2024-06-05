saved = true;
fignums = 10;

for t = 1:fignums
    %% Absolute relative errors
    % Plot the absolute relative errors versus maxiter_list
    f(t) = figure('visible','off');
    semilogy(m_list, abs(classical_errs(t,:)), 'o-', ...
             m_list, abs(rand_errs(t,:)),      '*-', ...
             m_list, abs(eigs_errs(t,:)),      'x-', ...
             'LineWidth', 2);
    legend('Classical RR', 'Randomized RR', 'Built-in eigs');
    xlabel('m');
    ylabel('Relative error $\frac{\min_{j}{|\lambda_j - \lambda_i^{\ast}|}}{|\lambda_i|}$','interpreter','latex');
    titlename = strrep(name, '_', '\_'); % To make sure "_" display properly
    title(strcat(titlename, sprintf(' (maxiter=%d, %s eigenvalue)', maxiter, toOrdinal(t))));
    grid on;

    % Set x-tick as integers
    curtick = get(gca, 'xTick');
    xticks(unique(round(curtick)));
    
    % Save the figure
    if saved
        % Set up directory and make it if not exists
        save_stem = fullfile('figs/m_varies', matclass, name, sprintf('maxiter=%d_noorder', maxiter));
        mymakedir(save_stem)
        
        % Save the figure
        figname = strcat(name, '_', sprintf('maxiter=%d_%s_eigvals_abs_noorder.pdf', maxiter, toOrdinal(t)));
        saveas(f(t), fullfile(save_stem, figname));
        
        % Export as a summary pdf file
        if export_summary
            summary_stem = fullfile('figs/m_varies', matclass, 'Summary', sprintf('maxiter=%d_noorder', maxiter));
            mymakedir(summary_stem);
            summary_path_name = fullfile(summary_stem, strcat(matclass, sprintf('_maxiter=%d_%s_eigvals_abs_noorder_summary.pdf', maxiter, toOrdinal(t))));
            exportgraphics(f(t), summary_path_name, 'Append', true);
        end
    end
end