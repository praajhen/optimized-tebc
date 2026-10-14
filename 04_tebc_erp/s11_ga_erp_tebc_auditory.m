clear; clc;

%% ===================== SETUP FIELDTRIP =====================
addpath('C:\toolboxes\fieldtrip-20251218');
ft_defaults;

%% ===================== DATA FOLDER =========================
data_folder = 'C:\TEBC_project\intermediate_files\ERP';
cd(data_folder);

%% ===================== GROUP DEFINITIONS ===================
young_participants = 1:41;
older_participants = 1:19;   % <<< define number of older participants here

nYoung = numel(young_participants);
nOlder = numel(older_participants);

channels = [6 7 106];        % ROI channels

%% ===================== LOAD YOUNG DATA =====================
TEBC_young = cell(1, nYoung);
A_young    = cell(1, nYoung);

for idx = 1:nYoung
    p = young_participants(idx);

    tmp = load(sprintf('PL%02d_TEBC.mat', p));
    TEBC_young{idx} = tmp.(sprintf('PL%02d_TEBC', p));

    tmp = load(sprintf('PL%02d_A.mat', p));
    A_young{idx} = tmp.(sprintf('PL%02d_A', p));
end

%% ===================== LOAD OLDER DATA =====================
TEBC_older = cell(1, nOlder);
A_older    = cell(1, nOlder);

for idx = 1:nOlder
    p = older_participants(idx);

    tmp = load(sprintf('PLe%02d_TEBC.mat', p));
    TEBC_older{idx} = tmp.(sprintf('PLe%02d_TEBC', p));

    tmp = load(sprintf('PLe%02d_A.mat', p));
    A_older{idx} = tmp.(sprintf('PLe%02d_A', p));
end

%% ===================== GRAND AVERAGES ======================
cfg = [];
cfg.keepindividual = 'yes'; % remember uncomment if you want sem

ga_TEBC_young = ft_timelockgrandaverage(cfg, TEBC_young{:});
ga_TEBC_older = ft_timelockgrandaverage(cfg, TEBC_older{:});

ga_A_young = ft_timelockgrandaverage(cfg, A_young{:});
ga_A_older = ft_timelockgrandaverage(cfg, A_older{:});

%% ===================== EXTRACT ROI (MEAN ± SEM) ============
% ---------- TEBC ----------
time_ms_TEBC = ga_TEBC_young.time * 1000;

roi_TEBC_y = squeeze(mean(ga_TEBC_young.individual(:,channels,:),2));
roi_TEBC_o = squeeze(mean(ga_TEBC_older.individual(:,channels,:),2));

mean_TEBC_y = mean(roi_TEBC_y,1);
sem_TEBC_y  = std(roi_TEBC_y,0,1)/sqrt(nYoung);

mean_TEBC_o = mean(roi_TEBC_o,1);
sem_TEBC_o  = std(roi_TEBC_o,0,1)/sqrt(nOlder);

% ---------- AUDITORY ----------
time_ms_A = ga_A_young.time * 1000;

roi_A_y = squeeze(mean(ga_A_young.individual(:,channels,:),2));
roi_A_o = squeeze(mean(ga_A_older.individual(:,channels,:),2));

mean_A_y = mean(roi_A_y,1);
sem_A_y  = std(roi_A_y,0,1)/sqrt(nYoung);

mean_A_o = mean(roi_A_o,1);
sem_A_o  = std(roi_A_o,0,1)/sqrt(nOlder);

figure('Units','normalized','Position',[0.05 0.25 0.85 0.45]);

%% -------- AUDITORY (LEFT) --------
subplot(1,2,1); hold on;

% Young SEM (shaded)
fill([time_ms_A fliplr(time_ms_A)], ...
     [mean_A_y+sem_A_y fliplr(mean_A_y-sem_A_y)], ...
     [0 0 0], 'FaceAlpha', 0.30, 'EdgeColor', 'none');

% Older SEM (shaded)
fill([time_ms_A fliplr(time_ms_A)], ...
     [mean_A_o+sem_A_o fliplr(mean_A_o-sem_A_o)], ...
     [1 0 0], 'FaceAlpha', 0.20, 'EdgeColor', 'none');

% Means (store handles!)
hYoung = plot(time_ms_A, mean_A_y, 'k', 'LineWidth', 2);
hOlder = plot(time_ms_A, mean_A_o, 'r', 'LineWidth', 2);

xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Auditory ERP (ROI mean \pm SEM)');

legend([hYoung hOlder], ...
       {sprintf('Young (n=%d)', nYoung), ...
        sprintf('Older (n=%d)', nOlder)}, ...
       'Location','best');

box off;


%% -------- TEBC (RIGHT) --------
subplot(1,2,2); hold on;

% Young SEM (shaded)
fill([time_ms_TEBC fliplr(time_ms_TEBC)], ...
     [mean_TEBC_y+sem_TEBC_y fliplr(mean_TEBC_y-sem_TEBC_y)], ...
     [0 0 0], 'FaceAlpha', 0.30, 'EdgeColor', 'none');

% Older SEM (shaded)
fill([time_ms_TEBC fliplr(time_ms_TEBC)], ...
     [mean_TEBC_o+sem_TEBC_o fliplr(mean_TEBC_o-sem_TEBC_o)], ...
     [1 0 0], 'FaceAlpha', 0.20, 'EdgeColor', 'none');

% Means (store handles!)
hYoung = plot(time_ms_TEBC, mean_TEBC_y, 'k', 'LineWidth', 2);
hOlder = plot(time_ms_TEBC, mean_TEBC_o, 'r', 'LineWidth', 2);

xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('TEBC ERP (ROI mean \pm SEM)');

legend([hYoung hOlder], ...
       {sprintf('Young (n=%d)', nYoung), ...
        sprintf('Older (n=%d)', nOlder)}, ...
       'Location','best');

box off;
