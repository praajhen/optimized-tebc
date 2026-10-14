clear; clc;

addpath('C:\MyTemp\Personalised TEBC (2024-2025)\matlab_code')
addpath('C:\MyTemp\fieldtrip-20230427');
ft_defaults;

data_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\ICA_cleaned\auditory';  % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, 'PL*.set'));  % List all .edf files in the folder

%--------------------------------------------------------------------------------------------------
 file_idx =2 %enter the file number
    %--------------------------------------------------------------------------------------------------
    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name)
  
    cfg = [];
    cfg.dataset  = dataset_filename;
    data_clean = ft_preprocessing(cfg);


    cfg = [];
    cfg.dataset  = dataset_filename;
    cfg.bpfilter      = 'yes';
    cfg.bpfreq = [1 30];
    data_filtered = ft_preprocessing(cfg,data_clean);

 % Save bandpass filtered  data
% filtered_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\BP_filtered\';  % Folder to BP filtered data
% [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
% filtered_data_filename = fullfile(filtered_folder, [base_filename '.mat']);
% save(filtered_data_filename, 'data_filtered','-v7.3');

 
%EEG preprocessing  
cfg                         = [];
cfg.dataset                 = dataset_filename;
cfg.trialfun                = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype      = 'trigger';
cfg.trialdef.eventvalue     = 1; % the values of the stimulus trigger for the three conditions
cfg.trialdef.prestim        = 0.2; % in seconds
cfg.trialdef.poststim       = 1; % in seconds
% cfg.channel = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60','61', '62', '63', '64', '65', '66', '67', '68', '69', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '100','101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', '121', '122', '123', '124', '125', '126', '127', '128'};
cfg.baselinewindow = [-0.2 0];
cfg.demean = 'yes';
cfg = ft_definetrial(cfg);
data = ft_redefinetrial(cfg,data_filtered);
erp = ft_preprocessing(cfg,data);

trial_no_b4(file_idx) = length(erp.trial);

    %% Amplitude thresholding

    % Preallocate memory
    numTrials = length(erp.trial);
    difftrial = cell(1, numTrials);
    btrial = cell(1, numTrials);
    clean_trials = [];
    reject_trial = false(1, numTrials);

    %threshold limits
    threshold_low = 175;
    threshold_high = 300;
    max_zero_columns = 25;

    % Calculate differences
    for tr = 1:numTrials
        difftrial{tr} = max(erp.trial{tr}(:, 150:end), [], 2) - min(erp.trial{tr}(:, 150:end), [], 2);
    end


    for tr = 1:numTrials
        % Check if any value exceeds the high threshold
        if any(difftrial{tr} > threshold_high)
            % Reject the trial if any value exceeds the high threshold
            reject_trial(tr) = true;
        else
            % Otherwise, check the number of zero columns with respect to low threshold
            btrial{tr} = difftrial{tr} <= threshold_low;
            zeroCount(tr) = sum(btrial{tr} == 0);
            if zeroCount(tr) > max_zero_columns
                reject_trial(tr) = true; % Reject the trial if zero columns exceed the limit
            else
                reject_trial(tr) = false; % Accept the trial otherwise
            end
        end
    end

    % Keep only the trials that are not rejected
    clean_trials = find(~reject_trial);

    trial_no_after(file_idx) = length(clean_trials);

    % Create the cleantrials matrix

    erp.sampleinfo = erp.sampleinfo(clean_trials,:);
    erp.trial = erp.trial(:, clean_trials);
    erp.time = erp.time(:, clean_trials);

cfg = [];
cfg.reref = 'yes';
cfg.refmethod = 'avg';
cfg.refchannel = 'all';
erp_trials = ft_preprocessing(cfg,erp);


    %Extracting each electrodes and their trial data into one individual cell
    trials = cell(128, 1);

    for electrode_idx = 1:128
        electrode_name = {electrode_idx};  % Assuming ch is a cell array of electrode labels
        electrode_trials = [];

        for trial_idx = 1:length(erp_trials.trial)
            trial_data = erp_trials.trial{trial_idx}(electrode_idx, :);  % Extract trial data for the current electrode
            electrode_trials = [electrode_trials; trial_data];
        end

        trials{electrode_idx} = electrode_trials;  % Save trials for the current electrode
    end
    
     [tone_start_times] = tone_times(dataset_filename,erp_trials);

        trials_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\trials';  % Folder to save ERP results
        [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
        erp_filename = fullfile(trials_folder, [base_filename '.mat']);
        save(erp_filename, 'trials','tone_start_times');

    %average of ERPs
    cfg= [];
    ga_erp=ft_timelockanalysis(cfg,erp_trials);

    % Save ERP results
    
        erp_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\ERP';  % Folder to save ERP results
        [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
        eval([base_filename ' = ga_erp;']);
   
    erp_filename = fullfile(erp_folder, [base_filename '.mat'])
    save(erp_filename, base_filename);



%%plot
% Extract relevant data
channels = [6, 7, 106];  % interested channel indices
roe = ga_erp.avg(channels, :);  % region of interest electrodes


% Calculate means
mean_roe = mean(roe, 1);


% Plotting
figure;
plot(linspace(-0.2, 1, 1200),mean_roe, 'LineWidth', 2, 'Color', 'b');  % Blue line 
hold on;
% plot(linspace(-0.2, 1, 1200),roe(1,:), 'LineWidth', 2, 'Color', 'r');  % channel 6
% plot(linspace(-0.2, 1, 1200),roe(2,:), 'LineWidth', 2, 'Color', 'g');  % channel 7 
% plot(linspace(-0.2, 1, 1200),roe(3,:), 'LineWidth', 2, 'Color', 'k');  % channel 106 


% Add labels and title
xlabel('Time (ms)');
ylabel('Amplitude (µV)');
title('ERP of electrodes 6,7,106 and mean');

% Add legend for clarity
legend({'mean', 'channel 6', 'channel 7', 'channel 106'}, 'Location', 'Best');

