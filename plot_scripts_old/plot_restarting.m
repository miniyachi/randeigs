saved = true;
fignums = 10;

for t = 1:fignums
    % %% Relative errors
    % % Plot the relative errors versus maxiter_list
    % f(t) = figure('visible','off');
    % semilogy(maxiter_list, classical_errs(t,:), 'o-', ...
    %          maxiter_list, rand_errs(t,:),      '*-', ...
    %          maxiter_list, eigs_errs(t,:),      'x-', ...
    %          'LineWidth', 2);
    % legend('Classical RR', 'Randomized RR', 'Built-in eigs');
    % xlabel('maxiter');
    % ylabel('Relative error $\frac{\lambda_i - \lambda_i^{\ast}}{|\lambda_i|}$','interpreter','latex');
    % titlename = strrep(name, '_', '\_'); % To make sure "_" display properly
    % title(strcat(titlename, sprintf(' (m=%d, %s eigenvalue)', m, toOrdinal(t))));
    % grid on;
    % 
    % % Set x-tick as integers
    % curtick = get(gca, 'xTick');
    % xticks(unique(round(curtick)));
    % 
    % % Save the figure
    % if saved
    %     % Set up directory and make it if not exists
    %     save_stem = fullfile('figs/restarting', matclass, name);
    %     mymakedir(save_stem)
    % 
    %     % Save the figure
    %     figname = strcat(name, '_', sprintf('m=%d_%s_eigvals_noorder.pdf', m, toOrdinal(t)));
    %     saveas(f(t), fullfile(save_stem, figname));
    % 
    %     % Export as a summary pdf file
    %     if export_summary
    %         summary_stem = fullfile('figs/restarting', matclass, 'Summary');
    %         mymakedir(summary_stem);
    %         summary_path_name = fullfile(summary_stem, strcat(matclass, sprintf('_m=%d_%s_eigvals_noorder_summary.pdf', m, toOrdinal(t))));
    %         exportgraphics(f(t), summary_path_name, 'Append', true);
    %     end
    % end
    
    %% Absolute relative errors
    % Plot the absolute relative errors versus maxiter_list
    f(t) = figure('visible','off');
    semilogy(maxiter_list, abs(classical_errs(t,:)), 'o-', ...
             maxiter_list, abs(rand_errs(t,:)),      '*-', ...
             maxiter_list, abs(eigs_errs(t,:)),      'x-', ...
             'LineWidth', 2);
    legend('Classical RR', 'Randomized RR', 'Built-in eigs');
    xlabel('maxiter');
    ylabel('Relative error $\frac{\min_{j}{|\lambda_j - \lambda_i^{\ast}|}}{|\lambda_i|}$','interpreter','latex');
    titlename = strrep(name, '_', '\_'); % To make sure "_" display properly
    title(strcat(titlename, sprintf(' (m=%d, %s eigenvalue)', m, toOrdinal(t))));
    grid on;

    % Set x-tick as integers
    curtick = get(gca, 'xTick');
    xticks(unique(round(curtick)));
    
    % Save the figure
    if saved
        % Set up directory and make it if not exists
        save_stem = fullfile('figs/restarting', matclass, name, sprintf('m=%d_noorder', m));
        mymakedir(save_stem)
        
        % Save the figure
        figname = strcat(name, '_', sprintf('m=%d_%s_eigvals_abs_noorder.pdf', m, toOrdinal(t)));
        saveas(f(t), fullfile(save_stem, figname));
        
        % Export as a summary pdf file
        if export_summary
            summary_stem = fullfile('figs/restarting', matclass, 'Summary', sprintf('m=%d_noorder', m));
            mymakedir(summary_stem);
            summary_path_name = fullfile(summary_stem, strcat(matclass, sprintf('_m=%d_%s_eigvals_abs_noorder_summary.pdf', m, toOrdinal(t))));
            exportgraphics(f(t), summary_path_name, 'Append', true);
        end
    end
end