%% ============================================================
% INPUT REQUIRED:
% CR_table_young  (60 x Nyoung, columns = PL01_TEBC, ...)
% CR_table_older  (60 x Nolder, columns = PLe01_TEBC, ...)
%% ============================================================

%% ---------------- SUBJECT GROUP ASSIGNMENT ----------------
cd ('C:\MyTemp\Personalised TEBC (2024-2025)\CR');

% ------------------ YOUNG ------------------
young_personalised_ids = [ ...
    1 2 3 6 9 11 13 15 17 20 ...
    21 23 24 26 29 30 31 36 37 38 41 ];

young_control_ids = [ ...
    4 5 7 8 10 12 14 16 18 19 ...
    22 25 27 28 32 33 34 35 39 40 ];

% ------------------ OLDER ------------------
older_personalised_ids = [ ...
    1 3 4 6 9 11 13 14 15 18 ];

older_control_ids = [ ...
    2 5 7 8 10 12 16 17 19 ];

%% ---------------- SETTINGS ----------------
binSize = 5;
nTrials = 60;

%% ===================== YOUNG =====================
dataY = table2array(CR_table_young);
sub_namesY = string(CR_table_young.Properties.VariableNames);
nSubY = length(sub_namesY);

% Subject IDs (PL01)
SubjectID_baseY = extractBefore(sub_namesY,"_TEBC")';

% Assign condition per subject
Cond_subY = strings(nSubY,1);
Group_subY = strings(nSubY,1);

Cond_subY(young_personalised_ids) = "Personalized";
Cond_subY(young_control_ids)      = "Control";

Group_subY(young_personalised_ids) = "PersonalizedSubject";
Group_subY(young_control_ids)      = "ControlSubject";

% reshape to long
TY = dataY';
TrialY = repmat((1:nTrials)', nSubY, 1);
CRY    = reshape(TY', [], 1);

SubjectIDY     = repelem(SubjectID_baseY, nTrials);
ConditionY     = repelem(Cond_subY, nTrials);
SubjectGroupY  = repelem(Group_subY, nTrials);
AgeGroupY      = repmat("Young", length(CRY), 1);

PhaseY = strings(length(CRY),1);
PhaseY(TrialY<=5) = "Baseline";
PhaseY(TrialY>=6 & TrialY<=55) = "Acquisition";
PhaseY(TrialY>=56) = "Extinction";

BlockY = ceil(TrialY/binSize);

LongYoung = table(SubjectIDY, AgeGroupY, ConditionY, SubjectGroupY, ...
                  TrialY, PhaseY, BlockY, CRY);

LongYoung.Properties.VariableNames = ...
{'SubjectID','AgeGroup','Condition','SubjectGroup','Trial','Phase','Block','CR'};

%% ===================== OLDER =====================
dataO = table2array(CR_table_older);
sub_namesO = string(CR_table_older.Properties.VariableNames);
nSubO = length(sub_namesO);

% Subject IDs (PLE01)
SubjectID_baseO = extractBefore(sub_namesO,"_TEBC")';

Cond_subO = strings(nSubO,1);
Group_subO = strings(nSubO,1);

Cond_subO(older_personalised_ids) = "Personalized";
Cond_subO(older_control_ids)      = "Control";

Group_subO(older_personalised_ids) = "PersonalizedSubject";
Group_subO(older_control_ids)      = "ControlSubject";

TO = dataO';
TrialO = repmat((1:nTrials)', nSubO, 1);
CRO    = reshape(TO', [], 1);

SubjectIDO     = repelem(SubjectID_baseO, nTrials);
ConditionO     = repelem(Cond_subO, nTrials);
SubjectGroupO  = repelem(Group_subO, nTrials);
AgeGroupO      = repmat("Older", length(CRO), 1);

PhaseO = strings(length(CRO),1);
PhaseO(TrialO<=5) = "Baseline";
PhaseO(TrialO>=6 & TrialO<=55) = "Acquisition";
PhaseO(TrialO>=56) = "Extinction";

BlockO = ceil(TrialO/binSize);

LongOlder = table(SubjectIDO, AgeGroupO, ConditionO, SubjectGroupO, ...
                  TrialO, PhaseO, BlockO, CRO);

LongOlder.Properties.VariableNames = ...
{'SubjectID','AgeGroup','Condition','SubjectGroup','Trial','Phase','Block','CR'};

%% ===================== MERGE =====================
LongAll = [LongYoung; LongOlder];

% Replace -1 with NaN
LongAll.CR(LongAll.CR == -1) = NaN;

%% ===================== CHECK =====================
disp(unique(LongAll.Condition))
disp(unique(LongAll.SubjectID))
LongAll.SubjectGroup = [];


%% ===================== SAVE =====================
writetable(LongAll,'CR_long_LMM.csv')
save('CR_long_LMM.mat','LongAll')
