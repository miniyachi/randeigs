function plot_matvec_save(matinfo,config)
    %% Extract matrix info
    class = matinfo.MatClass;
    name = matinfo.MatName;
    Transform = matinfo.Transform; % ['ShiftByMax']
    CanComputeEigval = matinfo.CanComputeEigval;
    fprintf('Start plotting for matrix %s ... \n', name);

    %% Extract config info
    m = config.SubspaceDim;
    maxiter = config.MaxIter;
    K = config.K;
    method = config.Method;
    str_K_m_maxiter = sprintf('K=%d_m=%d_maxiter=%d', K, m, maxiter);
    
    %% Directory
    FigDir = fullfile('figs', class, name, Transform);

    %% Load output
    str_method_K_m_maxiter = sprintf('%s_K=%d_m=%d_maxiter=%d', method, K, m, maxiter);
    Dir = fullfile('results', class, name, Transform);

    FileName_c = [name, '_classical_', str_method_K_m_maxiter, '.mat']; 
    FileName_r = [name, '_rand_', str_method_K_m_maxiter, '.mat']; 

    FilePath_c = fullfile(Dir, 'classical', FileName_c);
    FilePath_r = fullfile(Dir, 'rand', FileName_r);
    
    out_c = load(FilePath_c).output;
    out_r = load(FilePath_r).output;
    
    matvec_c = out_c.matvec_count;
    matvec_r = out_r.matvec_count;

    restart_c = out_c.restart_info;
    restart_r = out_r.restart_info;
    st_idx_c = restart_c.cycle_start_idx;
    st_idx_r = restart_r.cycle_start_idx;

    color_c = "#0072BD";
    color_r = "#D95319";

    %% Plot lambdatrue errors
    fprintf('Plot and save for lambdatrues ... \n');
    errs_c = out_c.lambdatrue_errors;
    errs_r = out_r.lambdatrue_errors;

    % Plot and save K figures (one for each eigval)
    for i = 1:K
        %% Plotting
        % Create a figure and disable fig window
        fig(i) = figure('visible','off');

        % Field name
        field_name = sprintf('eigval_%d', i);
        
        % Semilogy
        lr = semilogy(matvec_r, errs_r.(field_name), '*-', ...
                      'Color', color_r, 'LineWidth', 1.5, 'MarkerSize',4);
        hold on;
        lc = semilogy(matvec_c, errs_c.(field_name), 'o-', ...
                      'Color', color_c, 'LineWidth', 1.5, 'MarkerSize',4);
        
        % Add vertical lines for restart
        for idx = matvec_c(st_idx_c)
            hcxline = xline(idx, 'm-.', 'LineWidth', 2);
        end
        for idx = matvec_r(st_idx_r)
            hrxline = xline(idx, 'g--', 'LineWidth', 2);
        end
        hold off;

        % x-axis
        x_min = min(matvec_c(1), matvec_r(1));
        x_max = max(matvec_c(end), matvec_r(end));
        xlim([x_min, x_max]);
        xticks([x_min, xticks, x_max]);

        % Legend, Label
        legend([lc; lr; hcxline; hrxline], 'Classical RR', 'Randomized RR', 'restart (classical)', 'restart (rand)');
        xlabel('Number of mat-vecs');
        ylabel('Relative error $\frac{\min_{j}{|\lambda_j - \lambda_i^{\ast}|}}{|\lambda_i|}$','interpreter','latex');
        
        % Title
        titlename = strrep(name, '_', '\_'); % To make sure "_" display properly
        title(strcat(titlename, sprintf(' (m=%d, maxiter=%d, %s eigenvalue)', m, maxiter, toOrdinal(i))));
        grid on;

        %% Saving
        Dir_true = fullfile(FigDir, 'y=lambdatrues', [method,'_',str_K_m_maxiter]);
        str_WhichEigval = sprintf('%s_eigvals', toOrdinal(i));
        FigNameStem = [name, '_lambdatrues_', str_K_m_maxiter, '_', str_WhichEigval];

        % Save as pdf
        FigName = [FigNameStem, '.pdf'];
        FigPath = fullfile(Dir_true, 'pdf', FigName);
        mymakedir(fullfile(Dir_true, 'pdf'));
        saveas(fig(i), FigPath);

        % Save as eps
        FigName = [FigNameStem, '.eps'];
        FigPath = fullfile(Dir_true, 'eps', FigName);
        mymakedir(fullfile(Dir_true, 'eps'));
        saveas(fig(i), FigPath);
    end


    %% Plot residuals
    fprintf('Plot and save for residuals ... \n');
    res_c = out_c.residuals;
    res_r = out_r.residuals;

    % Plot and save K figures (one for each eigval)
    for i = 1:K
        %% Plotting
        % Create a figure and disable fig window
        fig(i) = figure('visible','off');

        % Field name
        field_name = sprintf('eigval_%d', i);
        
        % Semilogy
        lr = semilogy(matvec_r, res_r.(field_name), '*-', ...
                      'Color', color_r, 'LineWidth', 1.5, 'MarkerSize',4);
        hold on;
        lc = semilogy(matvec_c, res_c.(field_name), 'o-', ...
                      'Color', color_c, 'LineWidth', 1.5, 'MarkerSize',5);
        
        % Add vertical lines for restart
        for idx = matvec_c(st_idx_c)
            hcxline = xline(idx, 'm-.', 'LineWidth', 2);
        end
        for idx = matvec_r(st_idx_r)
            hrxline = xline(idx, 'g--', 'LineWidth', 2);
        end
        hold off;

        % x-axis
        x_min = min(matvec_c(1), matvec_r(1));
        x_max = max(matvec_c(end), matvec_r(end));
        xlim([x_min, x_max]);
        xticks([x_min, xticks, x_max]);

        % Legend, Label
        legend([lc; lr; hcxline; hrxline], 'Classical RR', 'Randomized RR', 'restart (classical)', 'restart (rand)');
        xlabel('Number of mat-vecs');
        ylabel('Residual $||A x - \lambda x||_2$','interpreter','latex');
        
        % Title
        titlename = strrep(name, '_', '\_'); % To make sure "_" display properly
        title(strcat(titlename, sprintf(' (m=%d, maxiter=%d, %s eigenvalue)', m, maxiter, toOrdinal(i))));
        grid on;

        %% Saving
        Dir_true = fullfile(FigDir, 'y=residuals', [method,'_',str_K_m_maxiter]);
        str_WhichEigval = sprintf('%s_eigvals', toOrdinal(i));
        FigNameStem = [name, '_residuals_', str_K_m_maxiter, '_', str_WhichEigval];

        % Save as pdf
        FigName = [FigNameStem, '.pdf'];
        FigPath = fullfile(Dir_true, 'pdf', FigName);
        mymakedir(fullfile(Dir_true, 'pdf'));
        saveas(fig(i), FigPath);

        % Save as eps
        FigName = [FigNameStem, '.eps'];
        FigPath = fullfile(Dir_true, 'eps', FigName);
        mymakedir(fullfile(Dir_true, 'eps'));
        saveas(fig(i), FigPath);
    end

    %% Plot sorted residuals
    fprintf('Plot and save for sorted residuals ... \n');
    sorted_res_c = sort_residuals(res_c);
    sorted_res_r = sort_residuals(res_r);

    % Plot and save K figures
    for i = 1:K
        %% Plotting
        % Create a figure and disable fig window
        fig(i) = figure('visible','off');

        % Field name
        field_name = sprintf('small_%d', i);
        
        % Semilogy
        lr = semilogy(matvec_r, sorted_res_r.(field_name), '*-', ...
                      'Color', color_r, 'LineWidth', 1.5, 'MarkerSize',4);
        hold on;
        lc = semilogy(matvec_c, sorted_res_c.(field_name), 'o-', ...
                      'Color', color_c, 'LineWidth', 1.5, 'MarkerSize',5);
        
        % Add vertical lines for restart
        for idx = matvec_c(st_idx_c)
            hcxline = xline(idx, 'm-.', 'LineWidth', 2);
        end
        for idx = matvec_r(st_idx_r)
            hrxline = xline(idx, 'g--', 'LineWidth', 2);
        end
        hold off;

        % x-axis
        x_min = min(matvec_c(1), matvec_r(1));
        x_max = max(matvec_c(end), matvec_r(end));
        xlim([x_min, x_max]);
        xticks([x_min, xticks, x_max]);

        % Legend, Label
        legend([lc; lr; hcxline; hrxline], 'Classical RR', 'Randomized RR', 'restart (classical)', 'restart (rand)');
        xlabel('Number of mat-vecs');
        ylabel('Residual $||A x - \lambda x||_2$','interpreter','latex');
        
        % Title
        titlename = strrep(name, '_', '\_'); % To make sure "_" display properly
        title(strcat(titlename, sprintf(' (m=%d, maxiter=%d, %s smallest)', m, maxiter, toOrdinal(i))));
        grid on;

        %% Saving
        Dir_true = fullfile(FigDir, 'y=sorted_residuals', [method,'_',str_K_m_maxiter]);
        str_Order = sprintf('%s_smallest', toOrdinal(i));
        FigNameStem = [name, '_SortedResiduals_', str_K_m_maxiter, '_', str_Order];

        % Save as pdf
        FigName =  [FigNameStem, '.pdf'];
        FigPath = fullfile(Dir_true, 'pdf', FigName);
        mymakedir(fullfile(Dir_true, 'pdf'));
        saveas(fig(i), FigPath);

        % Save as eps
        FigName = [FigNameStem, '.eps'];
        FigPath = fullfile(Dir_true, 'eps', FigName);
        mymakedir(fullfile(Dir_true, 'eps'));
        saveas(fig(i), FigPath);
    end
end



function sorted_res = sort_residuals(res)
    % Sort the residuals for every single iteration

    field_names = fieldnames(res);
    K = length(field_names);
    
    % Put all residuals into a matrix
    res_mat = [];
    for j = 1:K
        res_mat = [res_mat; res.(field_names{j,1})];
    end
    
    % Sort each column
    sorted_res_mat = sort(res_mat,1);

    % Construct a new residuals struct
    sorted_res = struct();
    for i = 1:K
        field_name = sprintf('small_%d', i);
        sorted_res(1).(field_name) = sorted_res_mat(i,:);
    end

end



