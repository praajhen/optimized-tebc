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

all_result = [];

for file_idx = 20:22 %:length(resp_files);   % <<< choose subject here

%% ---------------------- Load Resp bins ---------------------- %%
resp_filename = fullfile(resp_folder, resp_files(file_idx).name);
load(resp_filename);     % loads: binMatrices
resp_bins = binMatrices;

%% ---------------------- Load ECG bins ---------------------- %%
ecg_filename = fullfile(ecg_folder, ecg_files(file_idx).name);
load(ecg_filename);      % loads: binMatrices
ecg_bins = binMatrices;

subjID = resp_files(file_idx).name;
subjID = erase(subjID,'.mat');


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

computeERP = @(trials) ...
    ft_timelockanalysis(cfg, make_ft_struct(trials));

if isempty(ins_sys)
    ga_erp_ins_sys = [];
else
    ga_erp_ins_sys = computeERP(ins_sys);
end

if isempty(ins_dia)
    ga_erp_ins_dia = [];
else
    ga_erp_ins_dia = computeERP(ins_dia);
end

if isempty(exp_sys)
    ga_erp_exp_sys = [];
else
    ga_erp_exp_sys = computeERP(exp_sys);
end

if isempty(exp_dia)
    ga_erp_exp_dia = [];
else
    ga_erp_exp_dia = computeERP(exp_dia);
end

%% ---------------------- Channel averaging ---------------------- %%
channels = [6 7 106];   % fronto-central

getMean = @(x) mean(x.avg(channels,:),1);

if isempty(ga_erp_ins_sys)
    mean_ins_sys = NaN(1,length(time_vector));
else
    mean_ins_sys = getMean(ga_erp_ins_sys);
end

if isempty(ga_erp_ins_dia)
    mean_ins_dia = NaN(1,length(time_vector));
else
    mean_ins_dia = getMean(ga_erp_ins_dia);
end

if isempty(ga_erp_exp_sys)
    mean_exp_sys = NaN(1,length(time_vector));
else
    mean_exp_sys = getMean(ga_erp_exp_sys);
end

if isempty(ga_erp_exp_dia)
    mean_exp_dia = NaN(1,length(time_vector));
else
    mean_exp_dia = getMean(ga_erp_exp_dia);
end

signals = {mean_ins_sys, mean_ins_dia, mean_exp_sys, mean_exp_dia};
names   = {'INS–SYS','INS–DIA','EXP–SYS','EXP–DIA'};
trial_counts = [length(ins_sys), length(ins_dia), length(exp_sys), length(exp_dia)];

%% ---------------------- Interactive Peak detection ---------------------- %%
x_start = 200;
minDist = 75;

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

    % ---- plot automatic ----
    if ~any(isnan([a b c]))
        plot([locA locB locC],[a b c],'ro','MarkerFaceColor','r','MarkerSize',8);
    end

    xlabel('Time (s)');
    ylabel('Amplitude (\muV)');
    title(sprintf('%s  (n=%d)', names{i}, trial_counts(i)));
    grid on;

    drawnow;

    % -------- ASK USER ----------
    reply = input(sprintf('%s : Are peaks correct? (y/n): ', names{i}), 's');

    % -------- MANUAL FIX ----------
    if strcmpi(reply,'n')

        disp('Click 3 points: a (positive), b (negative), c (positive)');
        [x_click,y_click] = ginput(3);

        locA = x_click(1);  a = y_click(1);
        locB = x_click(2);  b = y_click(2);
        locC = x_click(3);  c = y_click(3);

        amp = ((a-b)+(c-b))/2;

        cla; hold on;
        plot(time_vector, y, 'LineWidth',1.8);
        plot([locA locB locC],[a b c],'go','MarkerFaceColor','g','MarkerSize',8);

        title(sprintf('%s  (n=%d) [MANUAL]', names{i}, trial_counts(i)));
        grid on;
    end

    % ---- amplitude label ----
    ylims = ylim; xlims = xlim;
    text(xlims(2)*0.65, ylims(2)*0.9, ...
        sprintf('Amp = %.2f µV', amp), ...
        'FontSize',11,'Color','b');

    results_matrix(i,:) = [a b c amp];

end


%% ---------------------- Find largest condition ---------------------- %%
[bestAmp, bestIdx] = max(results_matrix(:,4));

bestCondition = names{bestIdx};

fprintf('\nSubject: %s\n', subjID);
fprintf('Largest amplitude: %s  (%.2f µV)\n', bestCondition, bestAmp);

%% ---------------------- Results table ---------------------- %%
T = table( ...
    repmat({subjID},4,1), ...
    names', ...
    results_matrix(:,1), ...
    results_matrix(:,2), ...
    results_matrix(:,3), ...
    results_matrix(:,4), ...
    trial_counts', ...
    'VariableNames', {'Subject','Condition','a','b','c','Amp','Ntrials'} );

disp(T);
all_result = [all_result; T];
end

% save('CardioResp_N1P2_allSubjects.mat','all_result')
% writetable(all_results,'CardioResp_N1P2_allSubjects.csv')


subjects = unique(all_result.Subject);

best = table;

for s = 1:length(subjects)

    subj = subjects{s};

    sub = all_result(strcmp(all_result.Subject,subj),:);

    [amp,idx] = max(sub.Amp);

    best.Subject{s,1}   = subj;
    best.Condition{s,1} = sub.Condition{idx};
    best.Amp(s,1)       = amp;

end




subjects = unique(all_result.Subject);

assigned = table('Size',[length(subjects) 3], ...
                 'VariableTypes',{'string','string','double'}, ...
                 'VariableNames',{'Subject','Condition','Amp'});

for s = 1:length(subjects)

    idx = strcmp(all_result.Subject, subjects{s});
    sub = all_result(idx,:);

    [maxAmp, i] = max(sub.Amp);

    assigned.Subject(s)   = string(subjects{s});
    assigned.Condition(s) = string(sub.Condition{i});
    assigned.Amp(s)       = maxAmp;

end

figure
boxplot(assigned.Amp, assigned.Condition)

ylabel('N1–P2 amplitude (µV)')
xlabel('Assigned cardiorespiratory phase')
title('N1–P2 amplitude used for individualized phase assignment')
title('N1–P2 amplitude used for individualized phase assignment')


%% ================= FIX AMP FOR CONDITIONGROUP = 1 ================= %%

for i = 1:height(best)

    if best.ConditionGroup(i) == 1

        subj = best.Subject{i};

        % Find EXP-DIA row in all_result for that subject
        idx = strcmp(all_result.Subject, subj) & ...
              strcmp(all_result.Condition, 'EXP-DIA');

        if any(idx)
            best.Amp(i) = all_result.Amp(idx);
            best.Condition{i} = 'EXP-DIA'; % optional: update label
        end

    end

end