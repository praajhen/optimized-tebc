%% --------------------------------------N1------------------------------------------%%
clear; clc;

addpath('C:\TEBC_project\matlab_code')
addpath('C:\toolboxes\fieldtrip-20230427');
ft_defaults;

trials_folder = 'C:\TEBC_project\intermediate_files\trials';  % Folder containing your datasets
trials_files = dir(fullfile(trials_folder, 'PL*.mat'));

data_folder = 'C:\TEBC_project\data\auditory\';  % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, 'PL*.edf'));  % List all .edf files in the folder


bins = {};

%--------------------------------------------------------------------------------------------------
file_idx = 2; %enter the file number
%--------------------------------------------------------------------------------------------------

trials_filename = fullfile(trials_folder, trials_files(file_idx).name)
load(trials_filename); %load accepted trials for averaging

dataset_filename = fullfile(data_folder, dataset_files(file_idx).name)


% Initialize a cell array to store the reconstructed trials
reconstructed_trials = cell(size(trials{1,1},1),1);

% Iterate over each trial
for trial_idx = 1:size(trials{1,1},1)
    % Initialize a matrix to store data for all electrodes in the current trial
    trial_data = zeros(128, size(trials{1}, 2));

    % Iterate over each electrode
    for electrode_idx = 1:128
        % Extract the data for the current electrode and trial
        trial_data(electrode_idx, :) = trials{electrode_idx}(trial_idx, :);
    end

    % Store the reconstructed trial data
    reconstructed_trials{trial_idx} = trial_data;
end


%%
cfg            = [];
cfg.dataset    = dataset_filename;
cfg.channel = {'Resp'};
Resp= ft_preprocessing(cfg);

resp=Resp.trial{1,1}; %complete resp data
respPhase = angle(hilbert(resp)); % Angle and Hilbert transform of respiration data

phase_data = zeros(length(tone_start_times), 1);

for t = 1:length(tone_start_times)
    phase_data(t)  = respPhase(1, tone_start_times(t));
end

phase_data = round(phase_data, 2);% rounded to ignore issue like 3.1408 which become NaN in the bins
all_sub_phase_data{file_idx} = phase_data;

% Define the bin edges
edges = linspace(-3.14, 3.14,3); % 2 bins on each side of 0

% Group data into bins
bin_indices = discretize(phase_data, edges);
all_sub_binIndices{file_idx} = bin_indices;


% Extracting bin indices and initializing cell arrays
binIndices = all_sub_binIndices{1, file_idx};
numBins = 2;
binMatrices = cell(1, numBins);

% Initialize each bin in binMatrices as an empty cell array
for binIdx = 1:numBins
    binMatrices{binIdx} = {};
end

% Loop through trials and assign them to the respective bin cell arrays
for trialIdx = 1:length(binIndices)
    binIndex = binIndices(trialIdx);

    % Extract the trial data from reconstructed_trials
    trialData = reconstructed_trials{trialIdx};

    % Append the trial data to the respective bin cell array
    % binMatrices{binIndex}{1, end + 1} = trialData; % to get horizontally
    binMatrices{binIndex} = [binMatrices{binIndex}; {trialData}]; % to get vertically
end


bins = [bins; binMatrices];

bins_folder = 'C:\TEBC_project\intermediate_files\trials\resp';  % Folder to save ERP results
[~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
bin_filename = fullfile(bins_folder, [base_filename '.mat'])
save(bin_filename, 'binMatrices');


%%
% load('C:\TEBC_project\intermediate_files\label.mat')
% 
% bin1.trial = bins{file_idx, 1};
% bin1.fsample = 1000;
% bin1.time = {};
% bin1.time{1, 1} = linspace(-0.2, 1, 1200);
% for k = 1: length(bin1.trial)
%     bin1.time{1, k} = bin1.time{1, 1};
% end
% bin1.label = label;
% 
% cfg= [];
% ga_erp_1=ft_timelockanalysis(cfg,bin1);
% 
% trials_folder = 'C:\TEBC_project\intermediate_files\ERP_bins\resp\bin1';  % Folder to save ERP results
% [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
% erp_filename = fullfile(trials_folder, [base_filename '.mat']);
% save(erp_filename, 'ga_erp_1');
% 
% 
% bin2.trial = bins{file_idx, 2};
% bin2.fsample = 1000;
% bin2.time = {};
% bin2.time{1, 1} =linspace(-0.2, 1, 1200);
% for k = 1: length(bin2.trial)
%     bin2.time{1, k} = bin2.time{1, 1};
% end
% bin2.label = label;
% 
% cfg= [];
% ga_erp_2=ft_timelockanalysis(cfg,bin2);
% 
% trials_folder = 'C:\TEBC_project\intermediate_files\ERP_bins\resp\bin2';  % Folder to save ERP results
% [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
% erp_filename = fullfile(trials_folder, [base_filename '.mat']);
% save(erp_filename, 'ga_erp_2');
% 
% 
% 
% 
% %%plot
% % Extract relevant data
% channels = [6, 7, 106];  % interested channel indices
% ins = ga_erp_1.avg(channels, :);  % inspiration
% exp = ga_erp_2.avg(channels, :);  % expiration
% 
% % Calculate means
% mean_ins = mean(ins, 1);
% mean_exp = mean(exp, 1);
% 
% % Plotting
% figure (2);
% plot(linspace(-0.2, 1, 1200),mean_ins, 'LineWidth', 2, 'Color', 'b');  % Blue line for ins
% hold on;
% plot(linspace(-0.2, 1, 1200),mean_exp, 'LineWidth', 2, 'Color', 'r');  % Red line for exp
% 
% % Add labels and title
% xlabel('Time (ms)');
% ylabel('Amplitude (µV)');
% title('Mean of electrodes 6,7,106: ins vs. exp');
% 
% % Add legend for clarity
% legend({'inspiration', 'expiration'}, 'Location', 'Best');
