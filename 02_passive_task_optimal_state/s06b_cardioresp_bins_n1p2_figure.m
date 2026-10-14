%% ================= Cardio–Resp Phase ERP (4 conditions, single figure) ================= %%
clear; clc; close all;

addpath('C:\MyTemp\Personalised TEBC (2024-2025)\matlab_code');
addpath('C:\MyTemp\fieldtrip-20251218');
ft_defaults;

%% ---------------------- Paths ---------------------- %%
resp_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\trials\resp';
ecg_folder  = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\trials\ecg';

resp_files = dir(fullfile(resp_folder, 'PL*.mat'));
ecg_files  = dir(fullfile(ecg_folder,  'PL*.mat'));

file_idx = 2;   % <<< choose subject here

%% ---------------------- Load Resp bins ---------------------- %%
resp_filename = fullfile(resp_folder, resp_files(file_idx).name);
load(resp_filename);     % loads: binMatrices
resp_bins = binMatrices;

%% ---------------------- Load ECG bins ---------------------- %%
ecg_filename = fullfile(ecg_folder, ecg_files(file_idx).name);
load(ecg_filename);      % loads: binMatrices
ecg_bins = binMatrices;

%% ---------------------- Match trials across Resp × ECG ---------------------- %%
ins_sys = {};
ins_dia = {};
exp_sys = {};
exp_dia = {};

num_resp_ins = length(resp_bins{1,1});
num_resp_exp = length(resp_bins{1,2});

% ---- Inspiration × Systole ----
for i = 1:length(ecg_bins{1,1})
    ecg_val = ecg_bins{1,1}{i};
    for j = 1:num_resp_ins
        if isequal(ecg_val, resp_bins{1,1}{j})
            ins_sys{end+1,1} = ecg_val;
        end
    end
end

% ---- Inspiration × Diastole ----
for i = 1:length(ecg_bins{1,2})
    ecg_val = ecg_bins{1,2}{i};
    for j = 1:num_resp_ins
        if isequal(ecg_val, resp_bins{1,1}{j})
            ins_dia{end+1,1} = ecg_val;
        end
    end
end

% ---- Expiration × Systole ----
for i = 1:length(ecg_bins{1,1})
    ecg_val = ecg_bins{1,1}{i};
    for j = 1:num_resp_exp
        if isequal(ecg_val, resp_bins{1,2}{j})
            exp_sys{end+1,1} = ecg_val;
        end
    end
end

% ---- Expiration × Diastole ----
for i = 1:length(ecg_bins{1,2})
    ecg_val = ecg_bins{1,2}{i};
    for j = 1:num_resp_exp
        if isequal(ecg_val, resp_bins{1,2}{j})
            exp_dia{end+1,1} = ecg_val;
        end
    end
end

fprintf('Trials: INS–SYS=%d | INS–DIA=%d | EXP–SYS=%d | EXP–DIA=%d\n', ...
    length(ins_sys), length(ins_dia), length(exp_sys), length(exp_dia));

%% ---------------------- ERP computation ---------------------- %%
load('C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\label.mat');

fs = 1000;
time_vector = linspace(-0.2, 1, 1200);

make_ft_struct = @(trials) struct( ...
    'trial',   {trials}, ...
    'fsample', fs, ...
    'label',   {label}, ...
    'time',    {repmat({time_vector},1,length(trials))} );

cfg = [];

ga_erp_ins_sys = ft_timelockanalysis(cfg, make_ft_struct(ins_sys));
ga_erp_ins_dia = ft_timelockanalysis(cfg, make_ft_struct(ins_dia));
ga_erp_exp_sys = ft_timelockanalysis(cfg, make_ft_struct(exp_sys));
ga_erp_exp_dia = ft_timelockanalysis(cfg, make_ft_struct(exp_dia));

%% ---------------------- Channel averaging ---------------------- %%
channels = [6 7 106];   % fronto-central

mean_ins_sys = mean(ga_erp_ins_sys.avg(channels,:),1);
mean_ins_dia = mean(ga_erp_ins_dia.avg(channels,:),1);
mean_exp_sys = mean(ga_erp_exp_sys.avg(channels,:),1);
mean_exp_dia = mean(ga_erp_exp_dia.avg(channels,:),1);

signals = {mean_ins_sys, mean_ins_dia, mean_exp_sys, mean_exp_dia};
names   = {'INS–SYS','INS–DIA','EXP–SYS','EXP–DIA'};
trial_counts = [length(ins_sys), length(ins_dia), length(exp_sys), length(exp_dia)];

%% ---------------------- Peak detection + figure ---------------------- %%
x_start = 200;
minDist = 75;   % ms

results_matrix = NaN(4,4);   % [a b c amp]

figure('Name','ERP Peaks: Cardio–Resp Phases','Position',[100 100 1300 850]);

for i = 1:4
    y = signals{i};

    subplot(2,2,i); hold on;
    plot(time_vector, y, 'LineWidth',1.8);

    % ---- Automatic peaks ----
    [pPos,lPos] = findpeaks(y(x_start:end), time_vector(x_start:end), ...
                            'MinPeakDistance', minDist/1000);
    [pNeg,lNeg] = findpeaks(-y(x_start:end), time_vector(x_start:end), ...
                            'MinPeakDistance', minDist/1000);
    pNeg = -pNeg;

    a = NaN; b = NaN; c = NaN; amp = NaN;
    locA = NaN; locB = NaN; locC = NaN;

    if ~isempty(pPos) && ~isempty(pNeg)
        a = pPos(1); locA = lPos(1);
        bIdx = find(lNeg > locA, 1);
        if ~isempty(bIdx)
            b = pNeg(bIdx); locB = lNeg(bIdx);
            cIdx = find(lPos > locB, 1);
            if ~isempty(cIdx)
                c = pPos(cIdx); locC = lPos(cIdx);
                amp = ((a-b)+(c-b))/2;
            end
        end
    end

    % ---- Plot markers ----
    if ~any(isnan([a b c]))
        plot([locA locB locC],[a b c],'ro', ...
             'MarkerFaceColor','r','MarkerSize',8);
        text(locA,a,sprintf('a=%.2f',a),'VerticalAlignment','bottom');
        text(locB,b,sprintf('b=%.2f',b),'VerticalAlignment','top');
        text(locC,c,sprintf('c=%.2f',c),'VerticalAlignment','bottom');
    end

    % ---- Cosmetics ----
    xlabel('Time (s)');
    ylabel('Amplitude (\muV)');
    title(sprintf('%s  (n=%d)', names{i}, trial_counts(i)));
    % grid on;

    % ---- Amplitude label ----
    ylims = ylim; xlims = xlim;
    text(xlims(2)*0.65, ylims(2)*0.9, ...
        sprintf('Amp = %.2f µV', amp), ...
        'FontSize',11,'Color','b');

    results_matrix(i,:) = [a b c amp];
end

%% ---------------------- Results table ---------------------- %%
T = table( ...
    names', ...
    results_matrix(:,1), ...
    results_matrix(:,2), ...
    results_matrix(:,3), ...
    results_matrix(:,4), ...
    trial_counts', ...
    'VariableNames', {'Condition','a','b','c','Amp','Ntrials'} );

disp('Cardio–Resp Phase ERP Peaks:');
disp(T);
