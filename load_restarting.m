%% Read the saved Errors .mat files re-save the figures

matclass = 'PARSEC';
dir_stem = strcat('results/restarting/', matclass);
file_list = dir(strcat(dir_stem,'/*/*_EigvalsErrors_noorder_m=30.mat'));
name_list = {file_list.name};

for i = 1:length(file_list)
    % Read the errors .mat files
    t = load(fullfile(file_list(i).folder,file_list(i).name));
    classical_errs = t.classical_errs;
    rand_errs = t.rand_errs;
    eigs_errs = t.eigs_errs;
    maxiter_list = t.maxiter_list;
    m = t.m;
    clear t
    
    % Get the name of matrix
    [~,name,~] = fileparts(file_list(i).folder);
    fprintf('Load for matrix %s...\n', name);
    
    % Re-save the figures
    export_summary = true;
    run("plot_restarting.m");
end