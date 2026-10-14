clear; clc;

addpath('C:\TEBC_project\matlab_code')
addpath('C:\toolboxes\fieldtrip-20230427');
ft_defaults;

% --- Path to your EDF file ---
data_folder = 'C:\TEBC_project\data\auditory\';
dataset_files = dir(fullfile(data_folder, 'PL*.edf'));


file_idx =2;  % select which file
dataset_filename = fullfile(data_folder, dataset_files(file_idx).name)

% Read the whole EEG data
cfg            = [];
cfg.dataset    = dataset_filename;
cfg.channel = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60','61', '62', '63', '64', '65', '66', '67', '68', '69', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '100','101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', '121', '122', '123', '124', '125', '126', '127', '128'};
data           = ft_preprocessing(cfg);

% --- Get EEG matrix and info ---
EEG = cell2mat(data.trial);  % concatenate trials if it's segmented
fs = data.fsample;
labels = data.label;

% --- Compute basic metrics per channel ---
ch_std = std(EEG, 0, 2);   % standard deviation per channel
ch_mean = mean(EEG, 2);
ch_range = max(EEG, [], 2) - min(EEG, [], 2);

% --- Detect flat and noisy channels ---
flat_thresh = 1e-6; % near-zero variance
flat_ch = find(ch_std < flat_thresh);

noisy_thresh = 3 * mean(ch_std); % >3× average SD
noisy_ch = find(ch_std > noisy_thresh);

fprintf('Flat channels: %s\n', strjoin(labels(flat_ch), ', '));
fprintf('Noisy channels: %s\n', strjoin(labels(noisy_ch), ', '));

% --- Plot variance to visualize noise ---
figure;
bar(ch_std);
xlabel('Channel index');
ylabel('Standard deviation (µV)');
title('Channel-wise variability');
grid on;

% --- Plot a few example channels ---
num_plot = min(10, length(labels));
t = (0:size(EEG,2)-1)/fs;
figure;
plot(t, EEG(1:num_plot,:)');
xlabel('Time (s)');
ylabel('Amplitude (µV)');
title('First 10 EEG channels');
legend(labels(1:num_plot), 'Location', 'bestoutside');
grid on;

% --- Optional: Remove bad channels ---
bad_ch = unique([flat_ch; noisy_ch]);
good_ch = setdiff(1:length(labels), bad_ch);
EEG_clean = EEG(good_ch, :);
labels_clean = labels(good_ch);

fprintf('Cleaned data has %d good channels remaining.\n', numel(good_ch));
