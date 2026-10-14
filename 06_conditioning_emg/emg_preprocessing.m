clear; clc

addpath('C:\TEBC_project\matlab_code')
addpath('C:\toolboxes\fieldtrip-20230427');
ft_defaults;


data_folder = 'C:\TEBC_project\data\TEBC';  % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, 'PL*.edf'));  % List all .edf files in the folder

file_idx = 1

dataset_filename = fullfile(data_folder, dataset_files(file_idx).name)

cfg = [];
cfg.dataset  = dataset_filename;
cfg.channel = 'emg';
cfg.hpfreq = 60;
cfg.lpfreq = 20;
emg_filtered= ft_preprocessing(cfg);


%EEG preprocessing
cfg                         = [];
cfg.dataset                 = dataset_filename;
cfg.trialfun                = 'emgtrial'; % this is the default
cfg.baselinewindow = [-0.5 0];
cfg.demean = 'yes';
cfg = ft_definetrial(cfg);
data = ft_redefinetrial(cfg,emg_filtered);
emg_trial= ft_preprocessing(cfg,data);


EMG = zeros(length(emg_trial.trial), size(emg_trial.trial{1}, 2));

% Loop through each cell and concatenate the data
for i = 1:60
    EMG(i, :) = emg_trial.trial{1,i};  % Store each trial in a new row
end

% ----- CHECK POLARITY -----
t = -500:1:1000;

figure;
plot(t, mean(EMG,1),'k','LineWidth',1.5);
xlabel('Time (ms)');
ylabel('EMG amplitude');
title('Mean raw EMG – check polarity');


k = 1;
cr = [];

%calculate threshold
    bslmean = mean(mean(EMG(:, 1:500)));
    bslsd = mean(std(EMG(:, 1:500)));
    th = bslmean+2.5*bslsd; % here I chose 2.5 as the coefficient, in Waselius et al 2022 it was 2.0
    ymax = 4*mean(mean(EMG)); % made-up, change if you wish, just for visualization

    bts = [];
    CRs = [];
    noCRs = [];

    for i =  1:60 %6:55
        if max(EMG(i,300:510)) <=th &&  max(EMG(i,1100:1300)) >= th
            cr(i,k) = 1;
            CRs = vertcat(CRs, EMG(i, :));
        elseif (max(EMG(i,300:510)) >=th)
            cr(i,k) =-1;
            bts = vertcat(bts, EMG(i, :));
        else
            cr(i,k) =0;
            noCRs = vertcat(noCRs, EMG(i, :));
        end
    end

t = -500:1:1000;
t = t';

figure (1);
plot(t', mean(bts), 'k--');
    hold on
    plot(t', mean(noCRs), 'k');
    plot(t', mean(CRs), 'r');
    % ylim([0 ymax])
    xticks([-500 -200 0 200 800 900])
    rectangle('Position', [0, 0, 200, 0.2], 'FaceColor', [0, 0, 0]) % CS
    rectangle('Position', [800, 0, 100, 0.2], 'FaceColor', [0, 0, 0]) % US
    legend(['bad trials, n = ', int2str(size(bts, 1))], ['no CRs, n = ', int2str(size(noCRs, 1))], ['CRs, n = ', int2str(size(CRs, 1))])
    legend('Location', 'northwest')
    legend boxoff
    xlabel('time in ms')
    ylabel('EMG amplitude')


