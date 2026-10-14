%% ================= LEARNING RATE ANALYSIS =================
% Learning rate = conditioning trial number at which 5th CR occurred
% Conditioning trials = 6–55 (50 trials)

cd('C:\MyTemp\Personalised TEBC (2024-2025)\CR');

CSUS_trials = 6:55;
minCR = 5;

%% ================= YOUNG GROUP =================

CR_FLAG_Y = table2array(CR_table_young);   % 60 x 41
SubjectIDs_Y = CR_table_young.Properties.VariableNames';
nSubjects_Y = size(CR_FLAG_Y,2);

LearningRate_Y = nan(nSubjects_Y,1);   % NaN = did not reach 5 CRs

for s = 1:nSubjects_Y
    
    cr_csus = CR_FLAG_Y(CSUS_trials,s);   % 50 conditioning trials
    
    CR_positions = find(cr_csus == 1);    % positions of CRs
    
    if numel(CR_positions) >= minCR
        LearningRate_Y(s) = CR_positions(minCR);   % trial of 5th CR (1–50 scale)
    end
    
end

LearningRateTable_Young = table(SubjectIDs_Y, LearningRate_Y, ...
    'VariableNames', {'SubjectID','TrialOf5thCR'});

disp('----- LEARNING RATE: YOUNG -----');
disp(LearningRateTable_Young);


%% ================= OLDER GROUP =================

CR_FLAG_O = table2array(CR_table_older);   % 60 x 19
SubjectIDs_O = CR_table_older.Properties.VariableNames';
nSubjects_O = size(CR_FLAG_O,2);

LearningRate_O = nan(nSubjects_O,1);

for s = 1:nSubjects_O
    
    cr_csus = CR_FLAG_O(CSUS_trials,s);
    
    CR_positions = find(cr_csus == 1);
    
    if numel(CR_positions) >= minCR
        LearningRate_O(s) = CR_positions(minCR);
    end
    
end

LearningRateTable_Older = table(SubjectIDs_O, LearningRate_O, ...
    'VariableNames', {'SubjectID','TrialOf5thCR'});

disp('----- LEARNING RATE: OLDER -----');
disp(LearningRateTable_Older);

mean_Y = mean(LearningRate_Y,'omitnan');
sem_Y  = std(LearningRate_Y,'omitnan') / sqrt(sum(~isnan(LearningRate_Y)));

mean_O = mean(LearningRate_O,'omitnan');
sem_O  = std(LearningRate_O,'omitnan') / sqrt(sum(~isnan(LearningRate_O)));

disp(table(mean_Y, sem_Y, mean_O, sem_O, ...
    'VariableNames', {'Mean_Young','SEM_Young','Mean_Older','SEM_Older'}));


%% ================= PLOT LEARNING RATE =================

figure('Color','w','Position',[300 300 450 450]); hold on

% Remove non-learners (NaNs)
LR_Y = LearningRate_Y(~isnan(LearningRate_Y));
LR_O = LearningRate_O(~isnan(LearningRate_O));

% Jitter for visibility
jitter = 0.08;
xY = 1 + (rand(size(LR_Y))-0.5)*jitter;
xO = 2 + (rand(size(LR_O))-0.5)*jitter;

% Individual points
plot(xY, LR_Y, 'k.', 'MarkerSize', 14);
plot(xO, LR_O, 'r.', 'MarkerSize', 14);

% Mean ± SEM
mean_Y = mean(LR_Y);
sem_Y  = std(LR_Y)/sqrt(numel(LR_Y));

mean_O = mean(LR_O);
sem_O  = std(LR_O)/sqrt(numel(LR_O));

errorbar(1, mean_Y, sem_Y, 'k', 'LineWidth', 2, 'CapSize', 12);
errorbar(2, mean_O, sem_O, 'r', 'LineWidth', 2, 'CapSize', 12);

% Formatting
xlim([0.5 2.5]);
ylim([0 50]);   % 50 conditioning trials
xticks([1 2]);
xticklabels({'Young','Older'});
ylabel('Trial of 5th CR (Learning Rate)');
title('Learning Rate: Young vs Older');
box off;


figure('Color','w','Position',[300 300 600 400]);

histogram(LR_Y, 'BinWidth',5);
hold on
histogram(LR_O, 'BinWidth',5);

xlabel('Trial of 5th CR');
ylabel('Number of Participants');
title('Distribution of Learning Rate');
legend({'Young','Older'});
box off;