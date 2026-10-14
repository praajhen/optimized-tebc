clear; clc;

addpath('C:\MyTemp\fieldtrip-20230427');
ft_defaults;


data_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\data\auditory\';  % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder

for file_idx = 1:60

dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);


    cfg            = [];
    %     cfg.trialfun                = 'mytrialfun';
    cfg.dataset    = dataset_filename;
    cfg.channel = 'Resp';
     cfg.bpfilter = 'yes';           % Apply band-pass filter
    cfg.bpfreq = [0.1 0.5];         % Specify filter frequency range
    cfg.bpfilttype = 'but';         % Filter type (Butterworth)
    cfg.bpfiltord = 2;              % Filter order

    Resp= ft_preprocessing(cfg);

  
% Given sampling frequency
sampling_frequency = 1000; % Hz

[rpeaks, locs] = findpeaks(Resp.trial{1,1});

% Calculate time intervals between consecutive R-peaks (in seconds)
time_intervals = diff(locs) / sampling_frequency;

% Calculate average time interval (in seconds)
avg_time_interval = mean(time_intervals);

% Convert average time interval to breaths per minute (bpm)
respiration_rate_bpm(file_idx) = 60 / avg_time_interval;

  % Convert average time interval to respiration frequency (Hz)
    respiration_frequency(file_idx) = 1 / avg_time_interval;

    %% Heartbeat rate (bpm)


    cfg            = [];
    cfg.dataset    =  dataset_filename;
    cfg.channel = 'ecg';
    ecg = ft_preprocessing(cfg);

  
    % Given sampling frequency
    sampling_frequency = 1000; % Hz

     % Extraction ECG data
    [rpeaks,locs] = findpeaks((ecg.trial{1,1}),'MinPeakProminence',700,'MinPeakDistance',600);

    % Calculate time intervals between consecutive R-peaks (in seconds)
    time_intervals = diff(locs) / sampling_frequency;

    % Calculate average time interval (in seconds)
    avg_time_interval = mean(time_intervals);

    % Convert average time interval to heart rate (beats per minute, bpm)
    heart_rate_bpm(file_idx) = 60 / avg_time_interval;

end

