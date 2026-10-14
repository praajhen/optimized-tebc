
%% ============================================================

clear; clc; close all

load('C:\MyTemp\Personalised TEBC (2024-2025)\CR\cr_table_young.mat')
load('C:\MyTemp\Personalised TEBC (2024-2025)\CR\cr_table_older.mat')

%% ================= PARAMETERS =================
threshold = 30;      % % bad trials cutoff (Step 2)
CSUS_trials = 6:55;  % 50 conditioning trials
minCR = 5;           % learner criterion
nBlocks = 5;
CS_pre_trials  = 1:5;      % CS-alone before conditioning
CS_post_trials = 56:60;   % CS-alone after conditioning


%% ============================================================
%% ================= STEP 2: BAD TRIAL EXCLUSION ===============
%% ============================================================

disp('================= STEP 2: BAD TRIAL PERCENT =================');

% ---------- YOUNG ----------
CR_FLAG_MATRIX = table2array(CR_table_young);
SubjectIDs_Y = CR_table_young.Properties.VariableNames';
nSubjects = size(CR_FLAG_MATRIX,2);
nTrials   = size(CR_FLAG_MATRIX,1);

BadTrialPercent_Y = zeros(nSubjects,1);
Exclude_Y = false(nSubjects,1);

for s = 1:nSubjects
    cr_flag = CR_FLAG_MATRIX(:,s);
    n_bad = sum(cr_flag == -1);
    BadTrialPercent_Y(s) = (n_bad / nTrials) * 100;
    if BadTrialPercent_Y(s) > threshold
        Exclude_Y(s) = true;
    end
end

Step2_Young = table(SubjectIDs_Y, BadTrialPercent_Y, Exclude_Y, ...
    'VariableNames', {'SubjectID','BadTrialPercent','Excluded_GT30percent'});

disp('----- YOUNG -----');
disp(Step2_Young);


% ---------- OLDER ----------
CR_FLAG_MATRIX = table2array(CR_table_older);
SubjectIDs_O = CR_table_older.Properties.VariableNames';
nSubjects = size(CR_FLAG_MATRIX,2);
nTrials   = size(CR_FLAG_MATRIX,1);

BadTrialPercent_O = zeros(nSubjects,1);
Exclude_O = false(nSubjects,1);

for s = 1:nSubjects
    cr_flag = CR_FLAG_MATRIX(:,s);
    n_bad = sum(cr_flag == -1);
    BadTrialPercent_O(s) = (n_bad / nTrials) * 100;
    if BadTrialPercent_O(s) > threshold
        Exclude_O(s) = true;
    end
end

Step2_Older = table(SubjectIDs_O, BadTrialPercent_O, Exclude_O, ...
    'VariableNames', {'SubjectID','BadTrialPercent','Excluded_GT30percent'});

disp('----- OLDER -----');
disp(Step2_Older);


%% ============================================================
%% ================= STEP 3: LEARNER vs NON-LEARNER ============
%% ============================================================

disp('================= STEP 3: LEARNER CLASSIFICATION =================');

% ---------- YOUNG ----------
CR_FLAG_MATRIX = table2array(CR_table_young);
SubjectIDs_Y = CR_table_young.Properties.VariableNames';
nSubjects = size(CR_FLAG_MATRIX,2);

NumCR_Y = zeros(nSubjects,1);
IsLearner_Y = false(nSubjects,1);

for s = 1:nSubjects
    cr_csus = CR_FLAG_MATRIX(CSUS_trials,s);
    NumCR_Y(s) = sum(cr_csus == 1);
    if NumCR_Y(s) >= minCR
        IsLearner_Y(s) = true;
    end
end

LearnerTable_Young = table(SubjectIDs_Y, NumCR_Y, IsLearner_Y, ...
    'VariableNames', {'SubjectID','NumCR_50Trials','IsLearner'});

disp('----- YOUNG -----');
disp(LearnerTable_Young);


% ---------- OLDER ----------
CR_FLAG_MATRIX = table2array(CR_table_older);
SubjectIDs_O = CR_table_older.Properties.VariableNames';
nSubjects = size(CR_FLAG_MATRIX,2);

NumCR_O = zeros(nSubjects,1);
IsLearner_O = false(nSubjects,1);

for s = 1:nSubjects
    cr_csus = CR_FLAG_MATRIX(CSUS_trials,s);
    NumCR_O(s) = sum(cr_csus == 1);
    if NumCR_O(s) >= minCR
        IsLearner_O(s) = true;
    end
end

LearnerTable_Older = table(SubjectIDs_O, NumCR_O, IsLearner_O, ...
    'VariableNames', {'SubjectID','NumCR_50Trials','IsLearner'});

disp('----- OLDER -----');
disp(LearnerTable_Older);


disp('================= STEP 4: BLOCK-WISE CR% =================');

%% ================= PARAMETERS =================
nBlocks = 5;            % number of learning blocks
trialsPerBlock = 10;   % trials per block


%% ================= YOUNG GROUP =================
CR_FLAG_MATRIX = table2array(CR_table_young);
SubjectIDs_Y = CR_table_young.Properties.VariableNames';
nSubjects = size(CR_FLAG_MATRIX,2);

CR_Block_Young = nan(nSubjects, nBlocks);
CR_PreCS_Young = nan(nSubjects,1);
CR_PostCS_Young = nan(nSubjects,1);

for s = 1:nSubjects
    cr_all = CR_FLAG_MATRIX(:,s);

    % ----- CS-alone BEFORE conditioning -----
    pre_trials = cr_all(CS_pre_trials);
    good_pre = pre_trials(pre_trials ~= -1);
    if ~isempty(good_pre)
        CR_PreCS_Young(s) = 100 * sum(good_pre == 1) / numel(good_pre);
    end

    % ----- CS–US BLOCKS -----
    cr_csus = cr_all(CSUS_trials);
    for b = 1:nBlocks
        idx = (b-1)*trialsPerBlock + (1:trialsPerBlock);
        block_trials = cr_csus(idx);
        good_trials = block_trials(block_trials ~= -1);
        if ~isempty(good_trials)
            CR_Block_Young(s,b) = 100 * sum(good_trials == 1) / numel(good_trials);
        end
    end

    % ----- CS-alone AFTER conditioning -----
    post_trials = cr_all(CS_post_trials);
    good_post = post_trials(post_trials ~= -1);
    if ~isempty(good_post)
        CR_PostCS_Young(s) = 100 * sum(good_post == 1) / numel(good_post);
    end
end

Mean_Young = mean(CR_Block_Young,1,'omitnan');
SEM_Young  = std(CR_Block_Young,0,1,'omitnan') ./ sqrt(sum(~isnan(CR_Block_Young),1));

Mean_PreCS_Young  = mean(CR_PreCS_Young,'omitnan');
SEM_PreCS_Young   = std(CR_PreCS_Young,'omitnan') ./ sqrt(sum(~isnan(CR_PreCS_Young)));

Mean_PostCS_Young = mean(CR_PostCS_Young,'omitnan');
SEM_PostCS_Young  = std(CR_PostCS_Young,'omitnan') ./ sqrt(sum(~isnan(CR_PostCS_Young)));

%% ================= OLDER GROUP =================
CR_FLAG_MATRIX = table2array(CR_table_older);
SubjectIDs_O = CR_table_older.Properties.VariableNames';
nSubjects = size(CR_FLAG_MATRIX,2);

CR_Block_Older = nan(nSubjects, nBlocks);
CR_PreCS_Older = nan(nSubjects,1);
CR_PostCS_Older = nan(nSubjects,1);

for s = 1:nSubjects
    cr_all = CR_FLAG_MATRIX(:,s);

    % ----- CS-alone BEFORE conditioning -----
    pre_trials = cr_all(CS_pre_trials);
    good_pre = pre_trials(pre_trials ~= -1);
    if ~isempty(good_pre)
        CR_PreCS_Older(s) = 100 * sum(good_pre == 1) / numel(good_pre);
    end

    % ----- CS–US BLOCKS -----
    cr_csus = cr_all(CSUS_trials);
    for b = 1:nBlocks
        idx = (b-1)*trialsPerBlock + (1:trialsPerBlock);
        block_trials = cr_csus(idx);
        good_trials = block_trials(block_trials ~= -1);
        if ~isempty(good_trials)
            CR_Block_Older(s,b) = 100 * sum(good_trials == 1) / numel(good_trials);
        end
    end

    % ----- CS-alone AFTER conditioning -----
    post_trials = cr_all(CS_post_trials);
    good_post = post_trials(post_trials ~= -1);
    if ~isempty(good_post)
        CR_PostCS_Older(s) = 100 * sum(good_post == 1) / numel(good_post);
    end
end

Mean_Older = mean(CR_Block_Older,1,'omitnan');
SEM_Older  = std(CR_Block_Older,0,1,'omitnan') ./ sqrt(sum(~isnan(CR_Block_Older),1));

Mean_PreCS_Older  = mean(CR_PreCS_Older,'omitnan');
SEM_PreCS_Older   = std(CR_PreCS_Older,'omitnan') ./ sqrt(sum(~isnan(CR_PreCS_Older)));

Mean_PostCS_Older = mean(CR_PostCS_Older,'omitnan');
SEM_PostCS_Older  = std(CR_PostCS_Older,'omitnan') ./ sqrt(sum(~isnan(CR_PostCS_Older)));

%% ================= PLOT LEARNING CURVES =================
figure('Color','w','Position',[200 200 800 450]); hold on

% X positions (with spacing)
x_pre    = 1;                 % CS-alone before
x_blocks = 2:(nBlocks+1);     % Block 1..5
x_post   = nBlocks + 2;      % CS-alone after (EXT)

x_all = [x_pre x_blocks x_post];

% Concatenate means and SEMs
Y_young = [Mean_PreCS_Young Mean_Young Mean_PostCS_Young];
E_young = [SEM_PreCS_Young  SEM_Young  SEM_PostCS_Young];

Y_older = [Mean_PreCS_Older Mean_Older Mean_PostCS_Older];
E_older = [SEM_PreCS_Older  SEM_Older  SEM_PostCS_Older];

% ----- Young (one connected line) -----
errorbar(x_all, Y_young, E_young, '-o', 'LineWidth', 2);

% ----- Older (one connected line) -----
errorbar(x_all, Y_older, E_older, '-o', 'LineWidth', 2);

xlabel('Training Phase');
ylabel('Conditioned Responses (%)');
title('Learning Curves: Young vs Older');

% X-axis labels
xticks(x_all);
xticklabels({'CS-alone','Block 1','Block 2','Block 3','Block 4','Block 5','EXT'});

ylim([0 100]);
xlim([0.5 x_post+0.5]);   % give space so CS-alone is not on y-axis

legend({'Young','Older'}, 'Location','northwest');

box off;


%% ============================================================
%% ================= STEP 5: BEST PERFORMANCE =================
%% ============================================================

disp('================= STEP 5: BEST PERFORMANCE =================');

% Best performance = max of Blocks 3–5
BestPerf_Young = max(CR_Block_Young(:,3:5), [], 2, 'omitnan');
BestPerf_Older = max(CR_Block_Older(:,3:5), [], 2, 'omitnan');

mean_Y = mean(BestPerf_Young, 'omitnan');
sem_Y  = std(BestPerf_Young, 'omitnan') / sqrt(sum(~isnan(BestPerf_Young)));

mean_O = mean(BestPerf_Older, 'omitnan');
sem_O  = std(BestPerf_Older, 'omitnan') / sqrt(sum(~isnan(BestPerf_Older)));

disp(table(mean_Y, sem_Y, mean_O, sem_O, ...
    'VariableNames', {'Mean_Young','SEM_Young','Mean_Older','SEM_Older'}));


%% ================= PLOT BEST PERFORMANCE =================

figure('Color','w','Position',[300 300 450 450]); hold on

% ---- Individual points ----
jitter = 0.08;
xY = 1 + (rand(size(BestPerf_Young))-0.5)*jitter;
xO = 2 + (rand(size(BestPerf_Older))-0.5)*jitter;

plot(xY, BestPerf_Young, 'k.', 'MarkerSize', 14);
plot(xO, BestPerf_Older, 'r.', 'MarkerSize', 14);

% ---- Mean ± SEM ----
errorbar(1, mean_Y, sem_Y, 'k', 'LineWidth', 2, 'CapSize', 12);
errorbar(2, mean_O, sem_O, 'r', 'LineWidth', 2, 'CapSize', 12);

% ---- Formatting ----
xlim([0.5 2.5]);
ylim([0 100]);
xticks([1 2]);
xticklabels({'Young (n =39)','Older (n = 17)'});
ylabel('Best Performance (CR %)');
title('Best Conditioned Responding (Max of Blocks 3–5)');
box off; 


%% ============================================================
%% CHECK EXCESSIVE PRE-CONDITIONING BLINKS (>2 OF 5 CS-ALONE)
%% ============================================================

disp(' ');
disp('================ PRE-CONDITIONING BLINK SCREEN =================');

% Convert percentages back to blink counts
PreBlinkCount_Young = round(CR_PreCS_Young / 20);
PreBlinkCount_Older = round(CR_PreCS_Older / 20);

ExcludePreBlink_Young = PreBlinkCount_Young > 2;
ExcludePreBlink_Older = PreBlinkCount_Older > 2;

PreBlinkTable_Young = table( ...
    SubjectIDs_Y, ...
    PreBlinkCount_Young, ...
    ExcludePreBlink_Young, ...
    'VariableNames', {'SubjectID','PreCS_Blinks','Exclude_GT2'});

PreBlinkTable_Older = table( ...
    SubjectIDs_O, ...
    PreBlinkCount_Older, ...
    ExcludePreBlink_Older, ...
    'VariableNames', {'SubjectID','PreCS_Blinks','Exclude_GT2'});

disp('----- YOUNG -----');
disp(PreBlinkTable_Young);

disp('----- OLDER -----');
disp(PreBlinkTable_Older);

fprintf('\nYoung excluded (>2 blinks): %d/%d\n', ...
    sum(ExcludePreBlink_Young), numel(ExcludePreBlink_Young));

fprintf('Older excluded (>2 blinks): %d/%d\n', ...
    sum(ExcludePreBlink_Older), numel(ExcludePreBlink_Older));


keepY = ~Exclude_Y & IsLearner_Y & ~ExcludePreBlink_Young;
keepO = ~Exclude_O & IsLearner_O & ~ExcludePreBlink_Older;

fprintf('Young kept : %d\n', sum(keepY));
fprintf('Older kept : %d\n', sum(keepO));
fprintf('Total kept : %d\n', sum(keepY)+sum(keepO));

%% Convert tables to matrices
Young = table2array(CR_table_young);
Older = table2array(CR_table_older);

% save('C:\MyTemp\Personalised TEBC (2024-2025)\CR\CR_tables_strict.mat', ...
%     'Young','Older','keepY','keepO');