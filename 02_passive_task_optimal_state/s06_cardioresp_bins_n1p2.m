clear; clc;
close all;
addpath('C:\TEBC_project\matlab_code')
addpath('C:\toolboxes\fieldtrip-20230427');
ft_defaults;


% Initialize output cell arrays for inspiration and expiration
ins_sys = {{}};
ins_dia = {{}};
exp_sys = {{}};
exp_dia = {{}};

folder = 'C:\TEBC_project\intermediate_files\trials\resp';  % Folder containing your datasets
files = dir(fullfile(folder, 'PL*.mat')); 

file_idx = 22;

 % List all .edf files in the folder
filename = fullfile(folder, files(file_idx).name)% segment only correctly responds trials
load(filename); %load accepted trials for averaging
resp_bins = binMatrices;

ecg_folder = 'C:\TEBC_project\intermediate_files\trials\ecg';  % Folder containing your datasets
files = dir(fullfile(ecg_folder, 'PL*.mat'));  % List all .edf files in the folder
filename = fullfile(ecg_folder, files(file_idx).name)% segment only correctly responds trials
load(filename); %load accepted trials for averaging
ecg_bins = binMatrices;

% Get the number of cells in ecg_bins and resp_bins
num_resp_bins_1 = length(resp_bins{1, 1}); % Number of elements in first Respiration bin
num_resp_bins_2 = length(resp_bins{1, 2}); % Number of elements in second Respiration bin

% Inspiration phase comparisons (comparing with resp_bins{1,1})
num_ecg_bins_sys = length(ecg_bins{1, 1});
for i = 1:num_ecg_bins_sys
    ecg_value = ecg_bins{1, 1}{i};
    for j = 1:num_resp_bins_1
        resp_value = resp_bins{1, 1}{j};
        if isequal(ecg_value, resp_value)
            ins_sys{1, 1}{end + 1, 1} = ecg_value;
        end
    end
end

num_ecg_bins_dia = length(ecg_bins{1, 2});
for i = 1:num_ecg_bins_dia
    ecg_value = ecg_bins{1, 2}{i};
    for j = 1:num_resp_bins_1
        resp_value = resp_bins{1, 1}{j};
        if isequal(ecg_value, resp_value)
            ins_dia{1, 1}{end + 1, 1} = ecg_value;
        end
    end
end



% Expiration phase comparisons (comparing with resp_bins{1,2})
num_ecg_bins_sys = length(ecg_bins{1, 1});
for i = 1:num_ecg_bins_sys
    ecg_value = ecg_bins{1, 1}{i};
    for j = 1:num_resp_bins_2
        resp_value = resp_bins{1, 2}{j};
        if isequal(ecg_value, resp_value)
            exp_sys{1, 1}{end + 1, 1} = ecg_value;
        end
    end
end

num_ecg_bins_dia = length(ecg_bins{1, 2});
for i = 1:num_ecg_bins_dia
    ecg_value = ecg_bins{1, 2}{i};
    for j = 1:num_resp_bins_2
        resp_value = resp_bins{1, 2}{j};
        if isequal(ecg_value, resp_value)
            exp_dia{1, 1}{end + 1, 1} = ecg_value;
        end
    end
end



exp_dia = exp_dia{1, 1}';
exp_sys = exp_sys{1, 1}';
ins_dia = ins_dia{1, 1}';
ins_sys = ins_sys{1, 1}';




%%
load('C:\TEBC_project\intermediate_files\label.mat')

bin1.trial = exp_sys;
bin1.fsample = 1000;
bin1.time = {};
bin1.time{1, 1} = linspace(-0.2, 1, 1200);
for k = 1: length(bin1.trial)
    bin1.time{1, k} = bin1.time{1, 1};
end
bin1.label = label;

cfg= [];
ga_erp_exp_sys=ft_timelockanalysis(cfg,bin1);




bin1.trial = exp_dia;
bin1.fsample = 1000;
bin1.time = {};
bin1.time{1, 1} = linspace(-0.2, 1, 1200);
for k = 1: length(bin1.trial)
    bin1.time{1, k} = bin1.time{1, 1};
end
bin1.label = label;

cfg= [];
ga_erp_exp_dia=ft_timelockanalysis(cfg,bin1);


bin1.trial = ins_sys;
bin1.fsample = 1000;
bin1.time = {};
bin1.time{1, 1} = linspace(-0.2, 1, 1200);
for k = 1: length(bin1.trial)
    bin1.time{1, k} = bin1.time{1, 1};
end
bin1.label = label;

cfg= [];
ga_erp_ins_sys=ft_timelockanalysis(cfg,bin1);




bin1.trial = ins_dia;
bin1.fsample = 1000;
bin1.time = {};
bin1.time{1, 1} = linspace(-0.2, 1, 1200);
for k = 1: length(bin1.trial)
    bin1.time{1, k} = bin1.time{1, 1};
end
bin1.label = label;

cfg= [];
ga_erp_ins_dia=ft_timelockanalysis(cfg,bin1);


%%plot

% Extract relevant data
channels = [6, 7, 106];  % interested channel indices
ins_sys_c = ga_erp_ins_sys.avg(channels, :);  % systole
ins_dia_c = ga_erp_ins_dia.avg(channels, :);  % early diastole
exp_sys_c = ga_erp_exp_sys.avg(channels, :);  % systole
exp_dia_c = ga_erp_exp_dia.avg(channels, :);  % early diastole


% Calculate means
mean_sys = mean(ins_sys_c, 1);
mean_dia = mean(ins_dia_c, 1);
mean_exp_sys = mean(exp_sys_c, 1);
mean_exp_dia = mean(exp_dia_c, 1);



% Plotting
figure (5);
plot(linspace(-0.2, 1, 1200),mean_sys, 'LineWidth', 2, 'Color', 'b');  % Blue line for systole
hold on;
plot(linspace(-0.2, 1, 1200),mean_dia, 'LineWidth', 2, 'Color', 'r');  % Red line for early diastole 
plot(linspace(-0.2, 1, 1200),mean_exp_sys, 'LineWidth', 2, 'Color', 'k');  % Blue line for systole
plot(linspace(-0.2, 1, 1200),mean_exp_dia, 'LineWidth', 2, 'Color', 'g');  % Red line for early diastole 

% Add labels and title
xlabel('Time (ms)');
ylabel('Amplitude (µV)');
title('Mean of electrodes 6,7,106:INS-SYS, INS-DIA, EXP-SYS, EXP-DIA');

% Add legend for clarity
legend({'ins sys', 'ins dia', 'exp sys', 'exp dia'}, 'Location', 'Best');

%%
%% Settings
x_start = 200;
minDist = 75;   % minimum distance between peaks

signals = {mean_sys, mean_dia, mean_exp_sys, mean_exp_dia};
names   = {'ins_sys', 'ins_dia', 'exp_sys', 'exp_dia'};

results = struct();         % store a, b, c and amplitude for each condition
amplitudes = NaN(1,length(signals));  % matrix to store amplitude of each condition

%% Loop through each signal with amplitude on figure
trial_counts = [length(ins_sys), length(ins_dia), length(exp_sys), length(exp_dia)];

for i = 1:length(signals)
    y = signals{i};
    figure(i); clf; hold on;
    plot(y);

    % Peaks
    [pPos,lPos] = findpeaks(y(x_start:end), x_start:length(y), 'MinPeakDistance', minDist);
    [pNeg,lNeg] = findpeaks(-y(x_start:end), x_start:length(y), 'MinPeakDistance', minDist); 
    pNeg = -pNeg;

    % Initialize
    a = NaN; b = NaN; c = NaN; amp = NaN;

    if ~isempty(pPos) && ~isempty(pNeg)
        a = pPos(1); locA = lPos(1);
        bIdx = find(lNeg > locA,1);
        if ~isempty(bIdx)
            b = pNeg(bIdx); locB = lNeg(bIdx);
            cIdx = find(lPos > locB,1);
            if ~isempty(cIdx)
                c = pPos(cIdx); locC = lPos(cIdx);
                amp = ((a-b)+(c-b))/2;

                % Plot markers and a,b,c values
                plot([locA locB locC],[a b c],'o','MarkerFaceColor','r','MarkerSize',8);
                text(locA,a,sprintf('a=%.2f',a),'VerticalAlignment','bottom');
                text(locB,b,sprintf('b=%.2f',b),'VerticalAlignment','top');
                text(locC,c,sprintf('c=%.2f',c),'VerticalAlignment','bottom');
            end
        end
    end

    % Store results
    results.(names{i}) = struct('a',a,'b',b,'c',c,'amplitude',amp);
    amplitudes(i) = amp;

    % Title with trial count
    title(sprintf('%s (n=%d)', names{i}, trial_counts(i)), 'Interpreter','none');

    % Add amplitude on figure (top-right corner)
    ylims = ylim;
    xlims = xlim;
    text(xlims(2)*0.7, ylims(2)*0.9, sprintf('Amp=%.2f', amp), 'FontSize', 12, 'Color', 'b');
end

% Display amplitude table
amplitudes_table = array2table(amplitudes, 'VariableNames', names);
disp('Amplitudes for each condition:');
disp(amplitudes_table);



%%
plot(mean_sys)
a = 0.20;
b = -2.74;
c = 0.44;
ins_sys_amplitude = ((a - b) + (c - b)) / 2

plot(mean_dia)
a = 0.53;
b = -2.607;
c = 0.71;
ins_dia_amplitude = ((a - b) + (c - b)) / 2

plot(mean_exp_sys)
a = 1.58;
b = -4.54;
c = 2.73;
exp_sys_amplitude = ((a - b) + (c - b)) / 2

plot(mean_exp_dia)
a = 0.14;
b = -2.75;
c = 0.912;
exp_dia_amplitude = ((a - b) + (c - b)) / 2

amplitude (1,1) = ins_sys_amplitude;
amplitude (1,2) = ins_dia_amplitude;
amplitude (1,3) = exp_sys_amplitude;
amplitude (1,4) = exp_dia_amplitude;