clear; clc;

addpath('C:\TEBC_project\matlab_code')
addpath('C:\toolboxes\fieldtrip-20251218');
ft_defaults;

data_folder = 'C:\TEBC_project\intermediate_files\ICA_cleaned\auditory';
dataset_files = dir(fullfile(data_folder, 'PL*.set'));

num_files = length(dataset_files);

trial_no_b4    = zeros(1, num_files);
trial_no_after = zeros(1, num_files);

for file_idx = 1:num_files

    try
        fprintf('\nProcessing %s\n', dataset_files(file_idx).name);

        dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

        %% ===== FILTER =====
        cfg = [];
        cfg.dataset  = dataset_filename;
        cfg.bpfilter = 'yes';
        cfg.bpfreq   = [1 30];
        data_filtered = ft_preprocessing(cfg);

        %% ===== EPOCH =====
        cfg = [];
        cfg.dataset            = dataset_filename;
        cfg.trialfun           = 'ft_trialfun_general';
        cfg.trialdef.eventtype = 'trigger';
        cfg.trialdef.eventvalue= 1;   % adjust if needed
        cfg.trialdef.prestim   = 0.2;
        cfg.trialdef.poststim  = 1;
        cfg = ft_definetrial(cfg);

        cfg.demean = 'yes';
        cfg.baselinewindow = [-0.2 0];

        data = ft_redefinetrial(cfg, data_filtered);
        erp  = ft_preprocessing(cfg, data);

        trial_no_b4(file_idx) = length(erp.trial);

        %% ===== REJECTION =====
        numTrials = length(erp.trial);

        threshold_low  = 175;
        threshold_high = 300;
        max_zero_columns = 25;

        reject_trial = false(1, numTrials);

        for tr = 1:numTrials
            trial_data = erp.trial{tr}(:,150:end);

            diff_vals = max(trial_data, [], 2) - min(trial_data, [], 2);

            if any(diff_vals > threshold_high)
                reject_trial(tr) = true;
            else
                zeroCount = sum(diff_vals <= threshold_low);
                if zeroCount < (128 - max_zero_columns)
                    reject_trial(tr) = true;
                end
            end
        end

        clean_trials = find(~reject_trial);
        trial_no_after(file_idx) = length(clean_trials);

        fprintf('Before: %d | After: %d | Rejected: %d\n', ...
            trial_no_b4(file_idx), ...
            trial_no_after(file_idx), ...
            trial_no_b4(file_idx) - trial_no_after(file_idx));

    catch ME
        warning('Error in %s: %s', dataset_files(file_idx).name, ME.message);
        continue;
    end

end

%% ===== FINAL SUMMARY =====

rejected_trials = trial_no_b4 - trial_no_after;

mean_trials = mean(trial_no_after);
std_trials  = std(trial_no_after);

percent_rejected = (rejected_trials ./ trial_no_b4) * 100;
mean_percent = mean(percent_rejected);
std_percent  = std(percent_rejected);

fprintf('\n===== FINAL SUMMARY =====\n');
fprintf('Trials retained: %.2f ± %.2f\n', mean_trials, std_trials);
fprintf('Percentage rejected: %.2f ± %.2f %%\n', mean_percent, std_percent);

fprintf('Min trials retained: %d\n', min(trial_no_after));
fprintf('Max trials retained: %d\n', max(trial_no_after));