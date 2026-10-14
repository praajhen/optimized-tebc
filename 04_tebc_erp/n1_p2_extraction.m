clear; clc;

%% ===================== SETUP FIELDTRIP =====================
addpath('C:\toolboxes\fieldtrip-20251218');
ft_defaults;

%% ===================== DATA FOLDER =========================
data_folder = 'C:\TEBC_project\intermediate_files\ERP';
cd(data_folder);

%% ===================== GROUP DEFINITIONS ===================
young_participants = 1:41;
older_participants = 1:19;

nYoung = numel(young_participants);
nOlder = numel(older_participants);

roi_channels = [6 7 106];   % ROI indices

%% ===================== LOAD YOUNG DATA =====================
A_young    = cell(1,nYoung);
TEBC_young = cell(1,nYoung);

for i = 1:nYoung
    p = young_participants(i);

    tmp = load(sprintf('PL%02d_A.mat',p));
    A_young{i} = tmp.(sprintf('PL%02d_A',p));

    tmp = load(sprintf('PL%02d_TEBC.mat',p));
    TEBC_young{i} = tmp.(sprintf('PL%02d_TEBC',p));
end

%% ===================== LOAD OLDER DATA =====================
A_older    = cell(1,nOlder);
TEBC_older = cell(1,nOlder);

for i = 1:nOlder
    p = older_participants(i);

    tmp = load(sprintf('PLe%02d_A.mat',p));
    A_older{i} = tmp.(sprintf('PLe%02d_A',p));

    tmp = load(sprintf('PLe%02d_TEBC.mat',p));
    TEBC_older{i} = tmp.(sprintf('PLe%02d_TEBC',p));
end

%% ===================== GRAND AVERAGES (TIME AXES) ==========
cfg = [];

ga_A_all    = ft_timelockgrandaverage(cfg, A_young{:}, A_older{:});
ga_TEBC_all = ft_timelockgrandaverage(cfg, TEBC_young{:}, TEBC_older{:});

time_A    = ga_A_all.time;      % -0.200 to 1.000 s
time_TEBC = ga_TEBC_all.time;   % -0.100 to 0.500 s

%% ===================== DEFINE TIME WINDOWS =================
% Based on inspection of mean ROI waveforms (Ch 6,7,106)

% ---------- AUDITORY ----------
N1_A_y_window = [0.080 0.110];   % Young
P2_A_y_window = [0.150 0.190];

N1_A_o_window = [0.085 0.110];   % Older
P2_A_o_window = [0.150 0.200];

% ---------- TEBC ----------
N1_T_y_window = [0.090 0.130];      % Young
P2_T_y_window = [0.170 0.220];

N1_T_o_window = [0.090 0.120];  % Older
P2_T_o_window = [0.170 0.230];

%% ===================== INDEXING ============================
idx.N1.A.y = time_A    >= N1_A_y_window(1) & time_A    <= N1_A_y_window(2);
idx.P2.A.y = time_A    >= P2_A_y_window(1) & time_A    <= P2_A_y_window(2);

idx.N1.A.o = time_A    >= N1_A_o_window(1) & time_A    <= N1_A_o_window(2);
idx.P2.A.o = time_A    >= P2_A_o_window(1) & time_A    <= P2_A_o_window(2);

idx.N1.T.y = time_TEBC >= N1_T_y_window(1) & time_TEBC <= N1_T_y_window(2);
idx.P2.T.y = time_TEBC >= P2_T_y_window(1) & time_TEBC <= P2_T_y_window(2);

idx.N1.T.o = time_TEBC >= N1_T_o_window(1) & time_TEBC <= N1_T_o_window(2);
idx.P2.T.o = time_TEBC >= P2_T_o_window(1) & time_TEBC <= P2_T_o_window(2);

%% ===================== EXTRACT: YOUNG ======================
N1_A_young = zeros(nYoung,1);
P2_A_young = zeros(nYoung,1);
N1_T_young = zeros(nYoung,1);
P2_T_young = zeros(nYoung,1);

for s = 1:nYoung
    N1_A_young(s) = mean(mean(A_young{s}.avg(roi_channels,idx.N1.A.y),2));
    P2_A_young(s) = mean(mean(A_young{s}.avg(roi_channels,idx.P2.A.y),2));

    N1_T_young(s) = mean(mean(TEBC_young{s}.avg(roi_channels,idx.N1.T.y),2));
    P2_T_young(s) = mean(mean(TEBC_young{s}.avg(roi_channels,idx.P2.T.y),2));
end

%% ===================== EXTRACT: OLDER ======================
N1_A_older = zeros(nOlder,1);
P2_A_older = zeros(nOlder,1);
N1_T_older = zeros(nOlder,1);
P2_T_older = zeros(nOlder,1);

for s = 1:nOlder
    N1_A_older(s) = mean(mean(A_older{s}.avg(roi_channels,idx.N1.A.o),2));
    P2_A_older(s) = mean(mean(A_older{s}.avg(roi_channels,idx.P2.A.o),2));

    N1_T_older(s) = mean(mean(TEBC_older{s}.avg(roi_channels,idx.N1.T.o),2));
    P2_T_older(s) = mean(mean(TEBC_older{s}.avg(roi_channels,idx.P2.T.o),2));
end

%% ===================== QUICK SANITY CHECK ==================
fprintf('\n--- YOUNG ---\n');
fprintf('N1 Auditory: %.2f ± %.2f µV\n', mean(N1_A_young), std(N1_A_young));
fprintf('N1 TEBC    : %.2f ± %.2f µV\n', mean(N1_T_young), std(N1_T_young));
fprintf('P2 Auditory: %.2f ± %.2f µV\n', mean(P2_A_young), std(P2_A_young));
fprintf('P2 TEBC    : %.2f ± %.2f µV\n', mean(P2_T_young), std(P2_T_young));

fprintf('\n--- OLDER ---\n');
fprintf('N1 Auditory: %.2f ± %.2f µV\n', mean(N1_A_older), std(N1_A_older));
fprintf('N1 TEBC    : %.2f ± %.2f µV\n', mean(N1_T_older), std(N1_T_older));
fprintf('P2 Auditory: %.2f ± %.2f µV\n', mean(P2_A_older), std(P2_A_older));
fprintf('P2 TEBC    : %.2f ± %.2f µV\n', mean(P2_T_older), std(P2_T_older));


%% ===================== SANITY CHECK: ROI WAVEFORMS =========
% This block is for visual inspection ONLY

roi = [6 7 106];

cfg = [];
ga_A_y    = ft_timelockgrandaverage(cfg, A_young{:});
ga_TEBC_y = ft_timelockgrandaverage(cfg, TEBC_young{:});

cfg = [];
ga_A_o    = ft_timelockgrandaverage(cfg, A_older{:});
ga_TEBC_o = ft_timelockgrandaverage(cfg, TEBC_older{:});


% --- ROI means ---
a_y    = mean(ga_A_y.avg(roi,:), 1);
tebc_y = mean(ga_TEBC_y.avg(roi,:), 1);

a_o    = mean(ga_A_o.avg(roi,:), 1);
tebc_o = mean(ga_TEBC_o.avg(roi,:), 1);

% --- Time axes from FieldTrip ---
t_A    = ga_A_y.time * 1000;      % ms
t_TEBC = ga_TEBC_y.time * 1000;   % ms

% --- Plot ---
figure('Color','w','Position',[200 200 900 600]);

subplot(2,2,1)
plot(t_A, a_y, 'k', 'LineWidth', 1.5); grid on
xline(0,'--');
title('Auditory – Young');
xlabel('Time (ms)'); ylabel('µV');
xlim([-200 500]);

subplot(2,2,2)
plot(t_TEBC, tebc_y, 'k', 'LineWidth', 1.5); grid on
xline(0,'--');
title('TEBC – Young');
xlabel('Time (ms)'); ylabel('µV');
xlim([-100 500]);

subplot(2,2,3)
plot(t_A, a_o, 'k', 'LineWidth', 1.5); grid on
xline(0,'--');
title('Auditory – Older');
xlabel('Time (ms)'); ylabel('µV');
xlim([-200 500]);

subplot(2,2,4)
plot(t_TEBC, tebc_o, 'k', 'LineWidth', 1.5); grid on
xline(0,'--');
title('TEBC – Older');
xlabel('Time (ms)'); ylabel('µV');
xlim([-100 500]);

sgtitle('Sanity check: ROI ERP (Ch 6, 7, 106)');
