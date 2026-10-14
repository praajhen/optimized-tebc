clear; clc; close all

%% ================= LOAD DATA =================
load('C:\TEBC_project\CR\cr_table_young.mat')
load('C:\TEBC_project\CR\cr_table_older.mat')

%% ================= PARAMETERS =================
CSUS_trials = 6:55;     % conditioning trials
CS_pre_trials  = 1:5;   % CS-alone before
CS_post_trials = 56:60; % CS-alone after
nBlocks = 5;
trialsPerBlock = 10;

%% ================= GROUP DEFINITIONS =================

% ----- Young -----
young_control = {'PL04_TEBC','PL05_TEBC','PL07_TEBC','PL08_TEBC','PL10_TEBC','PL12_TEBC','PL14_TEBC','PL16_TEBC','PL18_TEBC','PL19_TEBC', ...
                 'PL22_TEBC','PL25_TEBC','PL27_TEBC','PL28_TEBC','PL32_TEBC','PL33_TEBC','PL34_TEBC','PL35_TEBC','PL39_TEBC','PL40_TEBC'};

young_personalised = {'PL01_TEBC','PL02_TEBC','PL03_TEBC','PL06_TEBC','PL09_TEBC','PL11_TEBC','PL13_TEBC','PL15_TEBC','PL17_TEBC','PL20_TEBC', ...
                      'PL21_TEBC','PL23_TEBC','PL24_TEBC','PL26_TEBC','PL29_TEBC','PL30_TEBC','PL31_TEBC','PL36_TEBC','PL37_TEBC','PL38_TEBC','PL41_TEBC'};

% ----- Older -----
older_personalised = {'PLe01_TEBC','PLe03_TEBC','PLe04_TEBC','PLe06_TEBC','PLe09_TEBC','PLe11_TEBC','PLe13_TEBC','PLe14_TEBC','PLe15_TEBC','PLe18_TEBC'};
older_control      = {'PLe02_TEBC','PLe05_TEBC','PLe07_TEBC','PLe08_TEBC','PLe10_TEBC','PLe12_TEBC','PLe16_TEBC','PLe17_TEBC','PLe19_TEBC'};

%% ================= YOUNG: COMPUTE CR =================
CR_FLAG_MATRIX = table2array(CR_table_young);
SubjectIDs_Y = CR_table_young.Properties.VariableNames';
nSubjects = size(CR_FLAG_MATRIX,2);

CR_Block_Young = nan(nSubjects, nBlocks);
CR_Pre_Young   = nan(nSubjects,1);
CR_Post_Young  = nan(nSubjects,1);

for s = 1:nSubjects
    cr_all = CR_FLAG_MATRIX(:,s);

    % ---- Pre-CS ----
    pre_trials = cr_all(CS_pre_trials);
    good_pre = pre_trials(pre_trials ~= -1);
    if ~isempty(good_pre)
        CR_Pre_Young(s) = 100 * sum(good_pre == 1) / numel(good_pre);
    end

    % ---- Blocks ----
    cr_csus = cr_all(CSUS_trials);
    for b = 1:nBlocks
        idx = (b-1)*trialsPerBlock + (1:trialsPerBlock);
        block_trials = cr_csus(idx);
        good_trials = block_trials(block_trials ~= -1);
        if ~isempty(good_trials)
            CR_Block_Young(s,b) = 100 * sum(good_trials == 1) / numel(good_trials);
        end
    end

    % ---- Post-CS / EXT ----
    post_trials = cr_all(CS_post_trials);
    good_post = post_trials(post_trials ~= -1);
    if ~isempty(good_post)
        CR_Post_Young(s) = 100 * sum(good_post == 1) / numel(good_post);
    end
end

%% ================= OLDER: COMPUTE CR =================
CR_FLAG_MATRIX = table2array(CR_table_older);
SubjectIDs_O = CR_table_older.Properties.VariableNames';
nSubjects = size(CR_FLAG_MATRIX,2);

CR_Block_Older = nan(nSubjects, nBlocks);
CR_Pre_Older   = nan(nSubjects,1);
CR_Post_Older  = nan(nSubjects,1);

for s = 1:nSubjects
    cr_all = CR_FLAG_MATRIX(:,s);

    % ---- Pre-CS ----
    pre_trials = cr_all(CS_pre_trials);
    good_pre = pre_trials(pre_trials ~= -1);
    if ~isempty(good_pre)
        CR_Pre_Older(s) = 100 * sum(good_pre == 1) / numel(good_pre);
    end

    % ---- Blocks ----
    cr_csus = cr_all(CSUS_trials);
    for b = 1:nBlocks
        idx = (b-1)*trialsPerBlock + (1:trialsPerBlock);
        block_trials = cr_csus(idx);
        good_trials = block_trials(block_trials ~= -1);
        if ~isempty(good_trials)
            CR_Block_Older(s,b) = 100 * sum(good_trials == 1) / numel(good_trials);
        end
    end

    % ---- Post-CS / EXT ----
    post_trials = cr_all(CS_post_trials);
    good_post = post_trials(post_trials ~= -1);
    if ~isempty(good_post)
        CR_Post_Older(s) = 100 * sum(good_post == 1) / numel(good_post);
    end
end

%% ================= SPLIT: PERSONALISED vs CONTROL =================

% ----- Young -----
isY_P = ismember(SubjectIDs_Y, young_personalised);
isY_C = ismember(SubjectIDs_Y, young_control);

CR_Y_P = CR_Block_Young(isY_P,:);
CR_Y_C = CR_Block_Young(isY_C,:);

Mean_Y_P = mean(CR_Y_P,1,'omitnan');
SEM_Y_P  = std(CR_Y_P,0,1,'omitnan') ./ sqrt(sum(~isnan(CR_Y_P),1));
Mean_Y_C = mean(CR_Y_C,1,'omitnan');
SEM_Y_C  = std(CR_Y_C,0,1,'omitnan') ./ sqrt(sum(~isnan(CR_Y_C),1));

Mean_Pre_Y_P  = mean(CR_Pre_Young(isY_P),'omitnan');
SEM_Pre_Y_P   = std(CR_Pre_Young(isY_P),'omitnan') ./ sqrt(sum(~isnan(CR_Pre_Young(isY_P))));
Mean_Post_Y_P = mean(CR_Post_Young(isY_P),'omitnan');
SEM_Post_Y_P  = std(CR_Post_Young(isY_P),'omitnan') ./ sqrt(sum(~isnan(CR_Post_Young(isY_P))));

Mean_Pre_Y_C  = mean(CR_Pre_Young(isY_C),'omitnan');
SEM_Pre_Y_C   = std(CR_Pre_Young(isY_C),'omitnan') ./ sqrt(sum(~isnan(CR_Pre_Young(isY_C))));
Mean_Post_Y_C = mean(CR_Post_Young(isY_C),'omitnan');
SEM_Post_Y_C  = std(CR_Post_Young(isY_C),'omitnan') ./ sqrt(sum(~isnan(CR_Post_Young(isY_C))));

% ----- Older -----
isO_P = ismember(SubjectIDs_O, older_personalised);
isO_C = ismember(SubjectIDs_O, older_control);

CR_O_P = CR_Block_Older(isO_P,:);
CR_O_C = CR_Block_Older(isO_C,:);

Mean_O_P = mean(CR_O_P,1,'omitnan');
SEM_O_P  = std(CR_O_P,0,1,'omitnan') ./ sqrt(sum(~isnan(CR_O_P),1));
Mean_O_C = mean(CR_O_C,1,'omitnan');
SEM_O_C  = std(CR_O_C,0,1,'omitnan') ./ sqrt(sum(~isnan(CR_O_C),1));

Mean_Pre_O_P  = mean(CR_Pre_Older(isO_P),'omitnan');
SEM_Pre_O_P   = std(CR_Pre_Older(isO_P),'omitnan') ./ sqrt(sum(~isnan(CR_Pre_Older(isO_P))));
Mean_Post_O_P = mean(CR_Post_Older(isO_P),'omitnan');
SEM_Post_O_P  = std(CR_Post_Older(isO_P),'omitnan') ./ sqrt(sum(~isnan(CR_Post_Older(isO_P))));

Mean_Pre_O_C  = mean(CR_Pre_Older(isO_C),'omitnan');
SEM_Pre_O_C   = std(CR_Pre_Older(isO_C),'omitnan') ./ sqrt(sum(~isnan(CR_Pre_Older(isO_C))));
Mean_Post_O_C = mean(CR_Post_Older(isO_C),'omitnan');
SEM_Post_O_C  = std(CR_Post_Older(isO_C),'omitnan') ./ sqrt(sum(~isnan(CR_Post_Older(isO_C))));

%% ================= LEARNING CURVES (CS → BLOCKS → EXT, WITH BREAKS) =================

% ----- YOUNG -----
figure('Color','w','Position',[200 200 800 450]); hold on

% X positions (with spacing)
x_pre    = 1;                 
x_blocks = 2:(nBlocks+1);     
x_post   = nBlocks + 2;       

x_all = [x_pre x_blocks x_post];

% Concatenate means and SEMs
Y_P = [Mean_Pre_Y_P  Mean_Y_P  Mean_Post_Y_P];
E_P = [SEM_Pre_Y_P   SEM_Y_P   SEM_Post_Y_P];

Y_C = [Mean_Pre_Y_C  Mean_Y_C  Mean_Post_Y_C];
E_C = [SEM_Pre_Y_C   SEM_Y_C   SEM_Post_Y_C];

% ----- Personalised (one connected line) -----
errorbar(x_all, Y_P, E_P, '-o', 'LineWidth', 2);

% ----- Control (one connected line) -----
errorbar(x_all, Y_C, E_C, '-o', 'LineWidth', 2);

xlabel('Training Phase');
ylabel('Conditioned Responses (%)');
title('Young: Personalised vs Control');

% X-axis labels
xticks(x_all);
xticklabels({'CS-alone','Block 1','Block 2','Block 3','Block 4','Block 5','EXT'});

ylim([0 100]);
xlim([0.5 x_post+0.5]);   % space so CS-alone is not on y-axis

legend({'Personalised','Control'}, 'Location','northwest');
box off;

% ----- OLDER -----
figure('Color','w','Position',[200 200 800 450]); hold on

% X positions (with spacing)
x_pre    = 1;                 
x_blocks = 2:(nBlocks+1);     
x_post   = nBlocks + 2;       

x_all = [x_pre x_blocks x_post];

% Concatenate means and SEMs
Y_P = [Mean_Pre_O_P  Mean_O_P  Mean_Post_O_P];
E_P = [SEM_Pre_O_P   SEM_O_P   SEM_Post_O_P];

Y_C = [Mean_Pre_O_C  Mean_O_C  Mean_Post_O_C];
E_C = [SEM_Pre_O_C   SEM_O_C   SEM_Post_O_C];

% ----- Personalised -----
errorbar(x_all, Y_P, E_P, '-o', 'LineWidth', 2);

% ----- Control -----
errorbar(x_all, Y_C, E_C, '-o', 'LineWidth', 2);

xlabel('Training Phase');
ylabel('Conditioned Responses (%)');
title('Older: Personalised vs Control');

xticks(x_all);
xticklabels({'CS-alone','Block 1','Block 2','Block 3','Block 4','Block 5','EXT'});

ylim([0 100]);
xlim([0.5 x_post+0.5]);

legend({'Personalised','Control'}, 'Location','northwest');
box off;

%% ================= BEST PERFORMANCE (DOTS ONLY) =================

Best_Young = max(CR_Block_Young(:,3:5),[],2,'omitnan');
Best_Older = max(CR_Block_Older(:,3:5),[],2,'omitnan');

% ----- YOUNG -----
Best_Y_P = Best_Young(isY_P);
Best_Y_C = Best_Young(isY_C);

figure('Color','w','Position',[300 300 450 450]); hold on
jitter = 0.08;
plot(1 + (rand(size(Best_Y_P))-0.5)*jitter, Best_Y_P, 'k.', 'MarkerSize', 14);
plot(2 + (rand(size(Best_Y_C))-0.5)*jitter, Best_Y_C, 'r.', 'MarkerSize', 14);

errorbar(1, mean(Best_Y_P,'omitnan'), std(Best_Y_P,'omitnan')/sqrt(sum(~isnan(Best_Y_P))), 'k', 'LineWidth', 2, 'CapSize', 12);
errorbar(2, mean(Best_Y_C,'omitnan'), std(Best_Y_C,'omitnan')/sqrt(sum(~isnan(Best_Y_C))), 'k', 'LineWidth', 2, 'CapSize', 12);

xlim([0.5 2.5]); ylim([0 100]);
xticks([1 2]); xticklabels({'Personalised','Control'});
ylabel('Best Performance (CR %)');
title('Young: Best Conditioned Responding (Blocks 3–5)');
box off;

% ----- OLDER -----
Best_O_P = Best_Older(isO_P);
Best_O_C = Best_Older(isO_C);

figure('Color','w','Position',[300 300 450 450]); hold on
plot(1 + (rand(size(Best_O_P))-0.5)*jitter, Best_O_P, 'k.', 'MarkerSize', 14);
plot(2 + (rand(size(Best_O_C))-0.5)*jitter, Best_O_C, 'r.', 'MarkerSize', 14);

errorbar(1, mean(Best_O_P,'omitnan'), std(Best_O_P,'omitnan')/sqrt(sum(~isnan(Best_O_P))), 'k', 'LineWidth', 2, 'CapSize', 12);
errorbar(2, mean(Best_O_C,'omitnan'), std(Best_O_C,'omitnan')/sqrt(sum(~isnan(Best_O_C))), 'k', 'LineWidth', 2, 'CapSize', 12);

xlim([0.5 2.5]); ylim([0 100]);
xticks([1 2]); xticklabels({'Personalised','Control'});
ylabel('Best Performance (CR %)');
title('Older: Best Conditioned Responding (Blocks 3–5)');
box off;
