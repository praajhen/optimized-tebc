clear; clc;
close all;
rng('shuffle')      % Different random split every run
%% =====================================================
% SETTINGS
%% =====================================================
addpath('C:\toolboxes\fieldtrip-20251218');
ft_defaults;
% 
% PERSONALISED = [
%     "PL01", "PL02", "PL03", "PL06", "PL09", "PL11", "PL13",
%     "PL15", "PL17", "PL20", "PL21", "PL23", "PL24", "PL26",
%     "PL29", "PL30", "PL31", "PL36", "PL37", "PL38", "PL41",
%     "PLe01", "PLe03", "PLe04", "PLe06", "PLe09", "PLe11",
%     "PLe13", "PLe14", "PLe15", "PLe18"
% ]

%Control = ["PL04_A", "PL05_A", "PL07_A", "PL08_A", "PL10_A", "PL12_A", "PL14_A", 
% "PL16_A", "PL18_A", "PL19_A", "PL22_A", "PL25_A", "PL27_A", "PL28_A", "PL32_A", 
% "PL33_A", "PL34_A", "PL35_A", "PL39_A", "PL40_A", "PLe02_A", "PLe05_A", "PLe07_A", 
% "PLe08_A", "PLe10_A", "PLe12_A", "PLe16_A", "PLe17_A", "PLe19_A"]


 SUBJECT = 'PL12_A';

BASE = 'C:\TEBC_project\intermediate_files\trials';

EEG_DIR  = BASE;
ECG_DIR  = fullfile(BASE,'ecg');
RESP_DIR = fullfile(BASE,'resp');

ROI = [6 7 106];
channels = [6 7 106];


%% =====================================================
% LOAD EEG
%% =====================================================

tmp = load(fullfile(EEG_DIR,[SUBJECT '.mat']));

trials = tmp.trials;

fprintf('Trials loaded : %d channels\n',length(trials));

%% =====================================================
% LOAD ECG
%% =====================================================

tmp = load(fullfile(ECG_DIR,[SUBJECT '.mat']));
ecg_bins = tmp.binMatrices;

%% =====================================================
% LOAD RESP
%% =====================================================

tmp = load(fullfile(RESP_DIR,[SUBJECT '.mat']));
resp_bins = tmp.binMatrices;

%% =====================================================
% RECOVER ECG TRIAL INDICES
%% =====================================================

fprintf('\nFinding ECG trial indices...\n')

ecg_idx = cell(size(ecg_bins));

for b=1:numel(ecg_bins)

    ecg_idx{b}=zeros(length(ecg_bins{b}),1);

    for i=1:length(ecg_bins{b})

        target = ecg_bins{b}{i};

        for t=1:size(trials{1},1)

            if isequal(target(ROI(1),:),trials{ROI(1)}(t,:)) && ...
               isequal(target(ROI(2),:),trials{ROI(2)}(t,:)) && ...
               isequal(target(ROI(3),:),trials{ROI(3)}(t,:))

                ecg_idx{b}(i)=t;
                break

            end

        end

    end

end

fprintf('Done.\n');

%% =====================================================
% RECOVER RESP TRIAL INDICES
%% =====================================================

fprintf('\nFinding RESP trial indices...\n')

resp_idx = cell(size(resp_bins));

for b=1:numel(resp_bins)

    resp_idx{b}=zeros(length(resp_bins{b}),1);

    for i=1:length(resp_bins{b})

        target = resp_bins{b}{i};

        for t=1:size(trials{1},1)

            if isequal(target(ROI(1),:),trials{ROI(1)}(t,:)) && ...
               isequal(target(ROI(2),:),trials{ROI(2)}(t,:)) && ...
               isequal(target(ROI(3),:),trials{ROI(3)}(t,:))

                resp_idx{b}(i)=t;
                break

            end

        end

    end

end

fprintf('Done.\n');

%% =====================================================
% FOUR PHYSIOLOGICAL STATES
%% =====================================================

INS_SYS = intersect(ecg_idx{1},resp_idx{1});
INS_DIA = intersect(ecg_idx{2},resp_idx{1});

EXP_SYS = intersect(ecg_idx{1},resp_idx{2});
EXP_DIA = intersect(ecg_idx{2},resp_idx{2});

%% =====================================================
% STATES
%% =====================================================

states_idx = {EXP_DIA, EXP_SYS, INS_DIA, INS_SYS};

states = {'EXP-DIA','EXP-SYS','INS-DIA','INS-SYS'};


fprintf('\n');
fprintf('EXP-DIA : %d\n',length(EXP_DIA));
fprintf('EXP-SYS : %d\n',length(EXP_SYS));
fprintf('INS-DIA : %d\n',length(INS_DIA));
fprintf('INS-SYS : %d\n',length(INS_SYS));

%% =====================================================
% RANDOM SPLIT INTO HALF1 / HALF2
%% =====================================================

half1 = cell(1,4);
half2 = cell(1,4);

for s = 1:4

    idx = states_idx{s};

    % Random order
    idx = idx(randperm(length(idx)));

    nHalf = floor(length(idx)/2);

    half1{s} = idx(1:nHalf);

    half2{s} = idx(nHalf+1:end);

end

%% =====================================================
% ERP OF HALF 1 AND HALF 2
%% =====================================================


ERP_half1 = cell(1,4);
ERP_half2 = cell(1,4);

for s = 1:4

    %% ---------- Half 1 ----------

    erp = zeros(128,1200);

    for ch = 1:128
        erp(ch,:) = mean(trials{ch}(half1{s},:),1);
    end

    ERP_half1{s} = erp;

    %% ---------- Half 2 ----------

    erp = zeros(128,1200);

    for ch = 1:128
        erp(ch,:) = mean(trials{ch}(half2{s},:),1);
    end

    ERP_half2{s} = erp;

end

%% =====================================================
% ROI
%% =====================================================

signals1 = cell(1,4);
signals2 = cell(1,4);

for s = 1:4

    signals1{s} = mean(ERP_half1{s}(channels,:),1);

    signals2{s} = mean(ERP_half2{s}(channels,:),1);

end

%% =====================================================
% COMPOSITE N1-P2 (MANUAL VERIFICATION VERSION)
%% =====================================================

time_vector = linspace(-0.2,1,1200);

x_start = 200;
minDist = 75;



amp_half1 = NaN(1,4);
amp_half2 = NaN(1,4);

figure('Color','w',...
       'Position',[100 50 1300 900]);

for s = 1:4

    %% =====================================================
    % HALF 1
    %% =====================================================

    y = signals1{s};

    subplot(4,2,2*s-1)
    hold on

    plot(time_vector,y,'k','LineWidth',2)

    xlim([-0.05 0.30])
    ylim auto

    xlabel('Time (s)')
    ylabel('\muV')

    title([states{s} '   Half 1'])

    [pPos,lPos] = findpeaks(y(x_start:end),...
        time_vector(x_start:end),...
        'MinPeakDistance',minDist/1000);

    [pNeg,lNeg] = findpeaks(-y(x_start:end),...
        time_vector(x_start:end),...
        'MinPeakDistance',minDist/1000);

    pNeg = -pNeg;

    amp = NaN;

    if ~isempty(pPos) && ~isempty(pNeg)

        a = pPos(1);
        locA = lPos(1);

        idxB = find(lNeg>locA,1);

        if ~isempty(idxB)

            b = pNeg(idxB);
            locB = lNeg(idxB);

            idxC = find(lPos>locB,1);

            if ~isempty(idxC)

                c = pPos(idxC);
                locC = lPos(idxC);

                amp=((a-b)+(c-b))/2;

                plot(locA,a,'ro','MarkerFaceColor','r')
                plot(locB,b,'bo','MarkerFaceColor','b')
                plot(locC,c,'go','MarkerFaceColor','g')

                text(locA,a,' a')
                text(locB,b,' b')
                text(locC,c,' c')

            end
        end
    end

    %% ---------------------------------------------
% MANUAL CHECK
%% ---------------------------------------------

reply = input(sprintf('\n%s Half 1 OK? (y/n): ',states{s}),'s');

if strcmpi(reply,'n')

    fprintf('\nClick:\n');
    fprintf('1) First positive peak (a)\n');
    fprintf('2) Negative peak (b)\n');
    fprintf('3) Second positive peak (c)\n');

    [x,yclick] = ginput(3);

    a = yclick(1);
    b = yclick(2);
    c = yclick(3);

    amp=((a-b)+(c-b))/2;

    plot(x(1),a,'ms','MarkerFaceColor','m','MarkerSize',10)
    plot(x(2),b,'ms','MarkerFaceColor','m','MarkerSize',10)
    plot(x(3),c,'ms','MarkerFaceColor','m','MarkerSize',10)

    text(x(1),a,' manual')
    text(x(2),b,' manual')
    text(x(3),c,' manual')

end

amp_half1(s)=amp;

    text(0.18,7,...
        sprintf('Amp = %.2f',amp),...
        'FontWeight','bold');



    %% =====================================================
    % HALF 2
    %% =====================================================

    y = signals2{s};

    subplot(4,2,2*s)

    hold on

    plot(time_vector,y,'k','LineWidth',2)

    xlim([-0.05 0.30])
    ylim auto

    xlabel('Time (s)')
    ylabel('\muV')

    title([states{s} '   Half 2'])

    [pPos,lPos] = findpeaks(y(x_start:end),...
        time_vector(x_start:end),...
        'MinPeakDistance',minDist/1000);

    [pNeg,lNeg] = findpeaks(-y(x_start:end),...
        time_vector(x_start:end),...
        'MinPeakDistance',minDist/1000);

    pNeg = -pNeg;

    amp = NaN;

    if ~isempty(pPos) && ~isempty(pNeg)

        a = pPos(1);
        locA = lPos(1);

        idxB = find(lNeg>locA,1);

        if ~isempty(idxB)

            b = pNeg(idxB);
            locB = lNeg(idxB);

            idxC = find(lPos>locB,1);

            if ~isempty(idxC)

                c = pPos(idxC);
                locC = lPos(idxC);

                amp=((a-b)+(c-b))/2;

                plot(locA,a,'ro','MarkerFaceColor','r')
                plot(locB,b,'bo','MarkerFaceColor','b')
                plot(locC,c,'go','MarkerFaceColor','g')

                text(locA,a,' a')
                text(locB,b,' b')
                text(locC,c,' c')

            end
        end
    end

    %% ---------------------------------------------
% MANUAL CHECK
%% ---------------------------------------------

reply = input(sprintf('\n%s Half 2 OK? (y/n): ',states{s}),'s');

if strcmpi(reply,'n')

    fprintf('\nClick:\n');
    fprintf('1) First positive peak (a)\n');
    fprintf('2) Negative peak (b)\n');
    fprintf('3) Second positive peak (c)\n');

    [x,yclick] = ginput(3);

    a = yclick(1);
    b = yclick(2);
    c = yclick(3);

    amp=((a-b)+(c-b))/2;

    plot(x(1),a,'ms','MarkerFaceColor','m','MarkerSize',10)
    plot(x(2),b,'ms','MarkerFaceColor','m','MarkerSize',10)
    plot(x(3),c,'ms','MarkerFaceColor','m','MarkerSize',10)

    text(x(1),a,' manual')
    text(x(2),b,' manual')
    text(x(3),c,' manual')

end

amp_half2(s)=amp;

    text(0.18,7,...
        sprintf('Amp = %.2f',amp),...
        'FontWeight','bold');

end

%% =====================================================
% WINNER MARGIN
%% =====================================================

% ---------- Half 1 ----------
sorted1 = sort(amp_half1,'descend');

margin1 = sorted1(1) - sorted1(2);

% ---------- Half 2 ----------
sorted2 = sort(amp_half2,'descend');

margin2 = sorted2(1) - sorted2(2);

fprintf('\n');
fprintf('Winner margin Half1 : %.3f uV\n',margin1);
fprintf('Winner margin Half2 : %.3f uV\n',margin2);

% THRESHOLD = 0.20;      % 0.2 uV
% 
% if margin1 < THRESHOLD
%     fprintf('Half1 : AMBIGUOUS (Top two states almost equal)\n');
% else
%     fprintf('Half1 : CLEAR WINNER\n');
% end
% 
% if margin2 < THRESHOLD
%     fprintf('Half2 : AMBIGUOUS (Top two states almost equal)\n');
% else
%     fprintf('Half2 : CLEAR WINNER\n');
% end

%% =====================================================
% WINNER
%% =====================================================

[~,winner1]=max(amp_half1);
[~,winner2]=max(amp_half2);

fprintf('\n');
fprintf('--------------------------------------\n');
fprintf('Half 1 winner : %s\n',states{winner1});
fprintf('Half 2 winner : %s\n',states{winner2});
fprintf('--------------------------------------\n');

if winner1==winner2

    fprintf('MATCH ✓\n');

else

    fprintf('NO MATCH ✗\n');

end

disp(table(states', amp_half1', amp_half2', ...
    'VariableNames', {'State','Half1','Half2'}))

[~,winner1] = max(amp_half1);
[~,winner2] = max(amp_half2);

fprintf('Winner1 = %s\n', states{winner1});
fprintf('Winner2 = %s\n', states{winner2});

% %% =====================================================
% % SAVE / APPEND RESULTS
% %% =====================================================
% 
outfile = 'C:\TEBC_project\intermediate_files\SplitHalfReliability_1.xlsx';
% 
NewRow = table( ...
    {SUBJECT}, ...
    {states{winner1}}, ...
    {states{winner2}}, ...
    winner1==winner2, ...
    margin1, ...
    margin2, ...
    amp_half1(1), amp_half2(1), ...
    amp_half1(2), amp_half2(2), ...
    amp_half1(3), amp_half2(3), ...
    amp_half1(4), amp_half2(4), ...
    'VariableNames',{ ...
    'Subject',...
    'WinnerHalf1',...
    'WinnerHalf2',...
    'Match',...
    'MarginHalf1',...
    'MarginHalf2',...
    'EXP_DIA_H1','EXP_DIA_H2',...
    'EXP_SYS_H1','EXP_SYS_H2',...
    'INS_DIA_H1','INS_DIA_H2',...
    'INS_SYS_H1','INS_SYS_H2'});

if exist(outfile,'file')

    Results = readtable(outfile);

    %-----------------------------------------
    % If subject already exists, replace row
    %-----------------------------------------
    idx = strcmp(Results.Subject,SUBJECT);

    if any(idx)

        Results(idx,:) = NewRow;

    else

        Results = [Results; NewRow];

    end

else

    Results = NewRow;

end

writetable(Results,outfile);

fprintf('\n');
fprintf('=========================================\n');
fprintf('Results saved to:\n');
fprintf('%s\n',outfile);
fprintf('Current number of subjects = %d\n',height(Results));
fprintf('=========================================\n');