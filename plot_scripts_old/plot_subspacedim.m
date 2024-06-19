saved = true;

fignums = 2;

% Plot the results versus m
figure(1)
semilogy(m_list, classical_errs(1,:), 'o-', m_list, rand_errs(1,:), '*-', 'LineWidth', 2);
legend('Classical RR', 'Randomized RR');
xlabel('m');
ylabel('relative error');
title('1st eigenvalue');
grid on;

figure(2)
semilogy(m_list, classical_errs(2,:), 'o-', m_list, rand_errs(2,:), '*-', 'LineWidth', 2);
legend('Classical RR', 'Randomized RR');
xlabel('m');
ylabel('relative error');
title('2nd eigenvalue');
grid on;


if saved
    name = strrep(file_name, '.mat', '');
    save_stem = fullfile('figs', name);

    for i = 1:fignums
        figname = sprintf('dim_%deigval.pdf', i);
        saveas(figure(i), fullfile(save_stem, figname));
    end
end