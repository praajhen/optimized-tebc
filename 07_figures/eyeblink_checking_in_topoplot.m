%% ===================== EYEBLINK CHECK (ALL SUBJECTS) =====================

clear; clc

addpath('C:\toolboxes\fieldtrip-20251218');
ft_defaults;

cd('C:\TEBC_project\intermediate_files\ERP');

%% ===================== LOAD ALL YOUNG PERSONALISED =====================

young_personalised_ids = [01 02 03 06 09 11 13 15 17 20 ...
                         21 23 24 26 29 30 31 36 37 38 41];

data_all = cell(1,numel(young_personalised_ids));

for i = 1:numel(young_personalised_ids)
    p = young_personalised_ids(i);
    tmp = load(sprintf('PL%02d_TEBC.mat',p));
    data_all{i} = tmp.(sprintf('PL%02d_TEBC',p));
end

%% ===================== GRAND AVERAGE =====================
cfg = [];
cfg.keepindividual = 'yes';

ga = ft_timelockgrandaverage(cfg, data_all{:});

time_ms = ga.time * 1000;

%% ===================== CHANNELS =====================
frontal_ch = 1:10;        % blink-sensitive
roi_ch     = [6 7 106];   % your ROI

%% ===================== EXTRACT =====================

% shape: subjects × time
frontal_all = squeeze(mean(ga.individual(:,frontal_ch,:),2));
roi_all     = squeeze(mean(ga.individual(:,roi_ch,:),2));

% mean across subjects
frontal_mean = mean(frontal_all,1);
roi_mean     = mean(roi_all,1);

% SEM
frontal_sem = std(frontal_all)/sqrt(size(frontal_all,1));
roi_sem     = std(roi_all)/sqrt(size(roi_all,1));

%% ===================== BASELINE =====================
baseline_idx = time_ms < 0;

frontal_mean = frontal_mean - mean(frontal_mean(baseline_idx));
roi_mean     = roi_mean - mean(roi_mean(baseline_idx));

%% ===================== PLOT =====================
figure('Color','w','Position',[200 200 900 450])
hold on

% SEM shading
fill([time_ms fliplr(time_ms)], ...
     [frontal_mean+frontal_sem fliplr(frontal_mean-frontal_sem)], ...
     'r','FaceAlpha',0.2,'EdgeColor','none')

fill([time_ms fliplr(time_ms)], ...
     [roi_mean+roi_sem fliplr(roi_mean-roi_sem)], ...
     'k','FaceAlpha',0.2,'EdgeColor','none')

% mean lines
plot(time_ms,frontal_mean,'r','LineWidth',2)
plot(time_ms,roi_mean,'k','LineWidth',2)

xlim([-100 500])

xlabel('Time (ms)')
ylabel('Amplitude (µV)')
title('Eyeblink check (group-level)')

legend({'Frontal SEM','ROI SEM','Frontal','ROI'},'Box','off')

yline(0,'k--')

box off