clear; clc

%% ===================== FIELDTRIP =====================
addpath('C:\MyTemp\fieldtrip-20251218');
ft_defaults;

cd('C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\ERP');

%% ===================== EEGLAB ========================
addpath('C:\MyTemp\eeglab2025.1.0')
eeglab; close

chanlocs = readlocs('GSN-HydroCel-128.sfp');
chanlocs(1:3) = [];

%% ===================== ROI ===========================
channels = [6 7 106];

%% ===================== SUBJECT GROUPS =================
young_personalised_ids = [01 02 03 06 09 11 13 15 17 20 ...
                         21 23 24 26 29 30 31 36 37 38 41];

young_control_ids = [04 05 07 08 10 12 14 16 18 19 ...
                     22 25 27 28 32 33 34 35 39 40];

older_personalised_ids = [01 03 04 06 09 11 13 14 15 18];
older_control_ids = [02 05 07 08 10 12 16 17 19];

%% ===================== LOAD DATA ======================
TEBC_yc = cell(1,numel(young_control_ids));
for i = 1:numel(young_control_ids)
    p = young_control_ids(i);
    tmp = load(sprintf('PL%02d_TEBC.mat',p));
    TEBC_yc{i} = tmp.(sprintf('PL%02d_TEBC',p));
end

TEBC_yp = cell(1,numel(young_personalised_ids));
for i = 1:numel(young_personalised_ids)
    p = young_personalised_ids(i);
    tmp = load(sprintf('PL%02d_TEBC.mat',p));
    TEBC_yp{i} = tmp.(sprintf('PL%02d_TEBC',p));
end

TEBC_oc = cell(1,numel(older_control_ids));
for i = 1:numel(older_control_ids)
    p = older_control_ids(i);
    tmp = load(sprintf('PLe%02d_TEBC.mat',p));
    TEBC_oc{i} = tmp.(sprintf('PLe%02d_TEBC',p));
end

TEBC_op = cell(1,numel(older_personalised_ids));
for i = 1:numel(older_personalised_ids)
    p = older_personalised_ids(i);
    tmp = load(sprintf('PLe%02d_TEBC.mat',p));
    TEBC_op{i} = tmp.(sprintf('PLe%02d_TEBC',p));
end

%% ===================== GRAND AVERAGES =================
cfg = [];
cfg.keepindividual = 'yes';

ga_yc = ft_timelockgrandaverage(cfg, TEBC_yc{:});
ga_yp = ft_timelockgrandaverage(cfg, TEBC_yp{:});
ga_oc = ft_timelockgrandaverage(cfg, TEBC_oc{:});
ga_op = ft_timelockgrandaverage(cfg, TEBC_op{:});

%% ===================== SANITY CHECK ===================
labels_data = ga_yc.label;
[~, idx] = ismember(labels_data, {chanlocs.labels});
chanlocs = chanlocs(idx);

time = ga_yp.time;  % common time axis
time_ms = time * 1000;

%% ===================== PEAK DETECTION (GROUP LEVEL) ======================

% ===== Young (from personalised) =====
roi_yp = squeeze(mean(ga_yp.individual(:,channels,:),2));
mean_yp = mean(roi_yp,1);

idx0 = time_ms >= 0;
signal = mean_yp(idx0);
time_post = time_ms(idx0);

% N1
[neg,loc] = findpeaks(-signal);
[~,midx] = max(neg);
N1_y_time = time_post(loc(midx));

% P2
idx_after = time_post > N1_y_time;
[pks,locs] = findpeaks(signal(idx_after));
P2_y_time = time_post(idx_after);
P2_y_time = P2_y_time(locs(1));

% ===== Older (from personalised) =====
roi_op = squeeze(mean(ga_op.individual(:,channels,:),2));
mean_op = mean(roi_op,1);

signal = mean_op(idx0);

[neg,loc] = findpeaks(-signal);
[~,midx] = max(neg);
N1_o_time = time_post(loc(midx));

idx_after = time_post > N1_o_time;
[pks,locs] = findpeaks(signal(idx_after));
P2_o_time = time_post(idx_after);
P2_o_time = P2_o_time(locs(1));

%% ===================== FIND CLOSEST TIME INDEX ======================

[~, idx_yN1] = min(abs(time_ms - N1_y_time));
[~, idx_yP2] = min(abs(time_ms - P2_y_time));

[~, idx_oN1] = min(abs(time_ms - N1_o_time));
[~, idx_oP2] = min(abs(time_ms - P2_o_time));

%% ===================== TIME WINDOW (+/- 5 ms) ======================

win = 5; % ms

idx_yN1_win = find(time_ms >= (N1_y_time - win) & time_ms <= (N1_y_time + win));
idx_yP2_win = find(time_ms >= (P2_y_time - win) & time_ms <= (P2_y_time + win));

idx_oN1_win = find(time_ms >= (N1_o_time - win) & time_ms <= (N1_o_time + win));
idx_oP2_win = find(time_ms >= (P2_o_time - win) & time_ms <= (P2_o_time + win));

%% ===================== TOPO EXTRACTION (SINGLE TIME POINT) ======================

% Young control
topo_yc_N1 = squeeze(mean(mean(ga_yc.individual(:,:,idx_yN1_win),3),1));
topo_yc_P2 = squeeze(mean(mean(ga_yc.individual(:,:,idx_yP2_win),3),1));

% Young personalised
topo_yp_N1 = squeeze(mean(mean(ga_yp.individual(:,:,idx_yN1_win),3),1));
topo_yp_P2 = squeeze(mean(mean(ga_yp.individual(:,:,idx_yP2_win),3),1));

% Older control
topo_oc_N1 = squeeze(mean(mean(ga_oc.individual(:,:,idx_oN1_win),3),1));
topo_oc_P2 = squeeze(mean(mean(ga_oc.individual(:,:,idx_oP2_win),3),1));

% Older personalised
topo_op_N1 = squeeze(mean(mean(ga_op.individual(:,:,idx_oN1_win),3),1));
topo_op_P2 = squeeze(mean(mean(ga_op.individual(:,:,idx_oP2_win),3),1));

%% ===================== SAVE INDIVIDUAL TOPOPLOTS =====================

output_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\figures\topoplots\';

zlim = [-7 7];

%% -------- YC --------
figure('Color','w')
topoplot(topo_yc_N1,chanlocs,'maplimits',zlim,'electrodes','on','emarkersize',4, 'emarker2',{[6 7 106],'o','k',7,2})
exportgraphics(gcf, fullfile(output_folder,'YC_N1.png'),'Resolution',600)
close

figure('Color','w')
topoplot(topo_yc_P2,chanlocs,'maplimits',zlim,'electrodes','on','emarkersize',4, 'emarker2',{[6 7 106],'o','k',7,2})
exportgraphics(gcf, fullfile(output_folder,'YC_P2.png'),'Resolution',600)
close

%% -------- OC --------
figure('Color','w')
topoplot(topo_oc_N1,chanlocs,'maplimits',zlim,'electrodes','on','emarkersize',4, 'emarker2',{[6 7 106],'o','k',7,2})
exportgraphics(gcf, fullfile(output_folder,'OC_N1.png'),'Resolution',600)
close

figure('Color','w')
topoplot(topo_oc_P2,chanlocs,'maplimits',zlim,'electrodes','on','emarkersize',4, 'emarker2',{[6 7 106],'o','k',7,2})
exportgraphics(gcf, fullfile(output_folder,'OC_P2.png'),'Resolution',600)
close

%% -------- YP --------
figure('Color','w')
topoplot(topo_yp_N1,chanlocs,'maplimits',zlim,'electrodes','on','emarkersize',4, 'emarker2',{[6 7 106],'o','k',7,2})
exportgraphics(gcf, fullfile(output_folder,'YP_N1.png'),'Resolution',600)
close

figure('Color','w')
topoplot(topo_yp_P2,chanlocs,'maplimits',zlim,'electrodes','on','emarkersize',4, 'emarker2',{[6 7 106],'o','k',7,2})
exportgraphics(gcf, fullfile(output_folder,'YP_P2.png'),'Resolution',600)
close

%% -------- OP --------
figure('Color','w')
topoplot(topo_op_N1,chanlocs,'maplimits',zlim,'electrodes','on','emarkersize',4, 'emarker2',{[6 7 106],'o','k',7,2})
exportgraphics(gcf, fullfile(output_folder,'OP_N1.png'),'Resolution',600)
close

figure('Color','w')
topoplot(topo_op_P2,chanlocs,'maplimits',zlim,'electrodes','on','emarkersize',4, 'emarker2',{[6 7 106],'o','k',7,2})
exportgraphics(gcf, fullfile(output_folder,'OP_P2.png'),'Resolution',600)
close

%% ===================== SAVE COLORBAR =====================

figure('Color','w','Units','centimeters','Position',[1 1 10 10])
colormap(jet)
caxis(zlim)
cb = colorbar;
cb.Label.String = 'Amplitude (µV)';
cb.FontSize = 16;
cb.Label.FontSize = 16;
axis off

exportgraphics(gcf, fullfile(output_folder,'colorbar.png'),'Resolution',600)
close