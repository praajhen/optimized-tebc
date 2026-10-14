clear; clc;

resp_folder = 'C:\TEBC_project\intermediate_files\trials\resp';
ecg_folder  = 'C:\TEBC_project\intermediate_files\trials\ecg';

resp_files = dir(fullfile(resp_folder, 'PL*.mat'));
ecg_files  = dir(fullfile(ecg_folder,  'PL*.mat'));

num_files = length(resp_files);

% Preallocate
n_insp = zeros(1, num_files);
n_exp  = zeros(1, num_files);

n_sys  = zeros(1, num_files);
n_dia  = zeros(1, num_files);

for file_idx = 1:num_files

    %% ===== LOAD RESP =====
    resp_filename = fullfile(resp_folder, resp_files(file_idx).name);
    load(resp_filename);   % loads binMatrices
    resp_bins = binMatrices;

    n_insp(file_idx) = length(resp_bins{1,1});
    n_exp(file_idx)  = length(resp_bins{1,2});

    %% ===== LOAD ECG =====
    ecg_filename = fullfile(ecg_folder, ecg_files(file_idx).name);
    load(ecg_filename);    % loads binMatrices
    ecg_bins = binMatrices;

    n_sys(file_idx) = length(ecg_bins{1,1});
    n_dia(file_idx) = length(ecg_bins{1,2});

    %% ===== PRINT PER SUBJECT =====
    fprintf('%s → Insp:%d Exp:%d | Sys:%d Dia:%d\n', ...
        resp_files(file_idx).name, ...
        n_insp(file_idx), n_exp(file_idx), ...
        n_sys(file_idx), n_dia(file_idx));
end

%% ===== FINAL STATS =====

mean_insp = mean(n_insp); std_insp = std(n_insp);
mean_exp  = mean(n_exp);  std_exp  = std(n_exp);

mean_sys  = mean(n_sys);  std_sys  = std(n_sys);
mean_dia  = mean(n_dia);  std_dia  = std(n_dia);

fprintf('\n===== FINAL =====\n');
fprintf('Inspiration: %.2f ± %.2f\n', mean_insp, std_insp);
fprintf('Expiration : %.2f ± %.2f\n', mean_exp, std_exp);

fprintf('Systole    : %.2f ± %.2f\n', mean_sys, std_sys);
fprintf('Diastole   : %.2f ± %.2f\n', mean_dia, std_dia);