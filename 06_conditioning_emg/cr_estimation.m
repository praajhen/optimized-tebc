%% ================= INITIALIZATION =================
clear; clc; close all;

addpath('C:\MyTemp\Personalised TEBC (2024-2025)\matlab_code')
addpath('C:\MyTemp\fieldtrip-20230427');
ft_defaults;

data_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\data\TEBC';
outdir = 'C:\MyTemp\Personalised TEBC (2024-2025)\CR';
if ~exist(outdir,'dir'), mkdir(outdir); end

dataset_files = dir(fullfile(data_folder, 'PL*.edf'));

% Subject-level summary table (for SPSS)
Results = table();

% Trial-level CR flags: rows = trials, columns = subjects
CR_FLAG_MATRIX = [];
SubjectIDs = {};

%% ================= LOOP OVER SUBJECTS =================
for f = 1:numel(dataset_files)

    close all; clc
    
    dataset_filename = fullfile(data_folder, dataset_files(f).name);
    disp(['Processing: ' dataset_filename]);

    % ----- Extract subject ID -----
    [~, subject_id, ~] = fileparts(dataset_files(f).name);

    %% ================= DEFINE TRIALS =================
    cfg = [];
    cfg.dataset  = dataset_filename;
    cfg.trialfun = 'emgtrial';   % your original trial function
    cfg = ft_definetrial(cfg);

    %% ================= EMG ENVELOPE =================
    % ---- High-pass at 60 Hz ----
    cfg.channel     = 'emg';
    cfg.hpfilter    = 'yes';
    cfg.hpfreq      = 60;
    cfg.hpfilttype  = 'but';
    cfg.hpfiltord   = 8;
    cfg.hpfiltdir   = 'twopass';
    emg_hp = ft_preprocessing(cfg);

    % ---- Rectify ----
    cfg = [];
    cfg.rectify = 'yes';
    emg_rect = ft_preprocessing(cfg, emg_hp);

    % ---- Low-pass at 20 Hz ----
    cfg = [];
    cfg.lpfilter    = 'yes';
    cfg.lpfreq      = 20;
    cfg.lpfilttype  = 'but';
    cfg.lpfiltord   = 8;
    cfg.lpfiltdir   = 'twopass';
    emg_env = ft_preprocessing(cfg, emg_rect);

    %% ================= EXTRACT TRIAL MATRIX =================
    nTrials = numel(emg_env.trial);
    nTime   = size(emg_env.trial{1},2);

    EMG = zeros(nTrials, nTime);
    for i = 1:nTrials
        EMG(i,:) = emg_env.trial{i};
    end

    % Time vector in ms
    t = linspace(-500, 1000, nTime);

  

    %% ================= DEFINE WINDOWS =================
    bsl_idx   = t >= -500 & t <= 0;      % baseline
    preCS_idx = t >= -200 & t <= 0;      % bad trial window
    CR_idx    = t >= 600  & t <= 800;    % CR window

    %% ================= BASELINE & THRESHOLD =================
    bsl_mean = mean(EMG(:, bsl_idx), 2);
    bsl_sd   = std(EMG(:, bsl_idx), [], 2);
    th       = bsl_mean + 2.5 .* bsl_sd;

    %% ================= CLASSIFY TRIALS (ALL 60) =================
    CRs_all   = [];
    noCRs_all = [];
    badTs_all = [];

    cr_flag = zeros(nTrials,1);   % 1 = CR, 0 = no CR, -1 = bad

    for i = 1:nTrials

        preCS_peak = max(EMG(i, preCS_idx));
        CR_peak    = max(EMG(i, CR_idx));

        if preCS_peak > th(i)
            cr_flag(i) = -1;   % bad trial
            badTs_all = [badTs_all; EMG(i,:)];
        elseif CR_peak > th(i)
            cr_flag(i) = 1;    % CR
            CRs_all = [CRs_all; EMG(i,:)];
        else
            cr_flag(i) = 0;    % no CR
            noCRs_all = [noCRs_all; EMG(i,:)];
        end
    end

    %% ================= STORE cr_flag FOR ALL 60 TRIALS =================
    if isempty(CR_FLAG_MATRIX)
        CR_FLAG_MATRIX = cr_flag;   % first subject
    else
        if size(CR_FLAG_MATRIX,1) ~= numel(cr_flag)
            error('Number of trials does not match across subjects.');
        end
        CR_FLAG_MATRIX = [CR_FLAG_MATRIX, cr_flag];  % append as new column
    end
    SubjectIDs = [SubjectIDs, subject_id];

    %% ================= SELECT ONLY CS+US TRIALS FOR PLOTTING =================
    CSUS_trials = 6:55;

    CRs   = EMG(CSUS_trials(cr_flag(CSUS_trials)==1), :);
    noCRs = EMG(CSUS_trials(cr_flag(CSUS_trials)==0), :);
    badTs = EMG(CSUS_trials(cr_flag(CSUS_trials)==-1), :);

    n_bad  = sum(cr_flag(CSUS_trials) == -1);
    n_noCR = sum(cr_flag(CSUS_trials) == 0);
    n_CR   = sum(cr_flag(CSUS_trials) == 1);
    n_good = sum(cr_flag(CSUS_trials) ~= -1);
    perc_CR = 100 * n_CR / n_good;

    %% ================= BASELINE-SUBTRACTED DATA (FOR FIGURE ONLY) =================
    if ~isempty(badTs)
        badTs_bs = badTs - mean(badTs(:, bsl_idx),2);
    else
        badTs_bs = [];
    end

    if ~isempty(noCRs)
        noCRs_bs = noCRs - mean(noCRs(:, bsl_idx),2);
    else
        noCRs_bs = [];
    end

    if ~isempty(CRs)
        CRs_bs = CRs - mean(CRs(:, bsl_idx),2);
    else
        CRs_bs = [];
    end

    %% ================= FINAL CR FIGURE (BASELINE-SUBTRACTED) =================
    figure('Color','w','Position',[100 100 900 500]);

    hold on
    if ~isempty(badTs_bs)
        plot(t, mean(badTs_bs,1), 'k--','LineWidth',1.5);
    end
    if ~isempty(noCRs_bs)
        plot(t, mean(noCRs_bs,1), 'k','LineWidth',1.5);
    end
    if ~isempty(CRs_bs)
        plot(t, mean(CRs_bs,1), 'r','LineWidth',1.5);
    end

    % ---- CS and US bars (1 unit height from x-axis) ----
    ybar = 1;
    rectangle('Position',[0   0   200 ybar],'FaceColor',[0 0 0],'EdgeColor','none');   % CS
    rectangle('Position',[800 0   100 ybar],'FaceColor',[0 0 0],'EdgeColor','none');   % US

    legend( ...
        ['bad trials, n = ' num2str(n_bad)], ...
        ['no CRs, n = ' num2str(n_noCR)], ...
        ['CRs, n = ' num2str(n_CR)], ...
        'Location','northwest');
    legend boxoff

    xlabel('Time (ms)');
    ylabel('EMG (baseline-corrected)');
    title(['CR detection: ' subject_id],'Interpreter','none');
    xticks(-500:100:1000);
    box off

    % Save figure
    figfile = fullfile(outdir, [subject_id '_CR_detection.png']);
    saveas(gcf, figfile);
    close(gcf);

    %% ================= STORE SUBJECT SUMMARY (BASED ON 6–55) =================
    newRow = table( ...
        {subject_id},  nTrials, n_bad, n_noCR, n_CR, perc_CR, ...
        'VariableNames', {'SubjectID','TotalTrials','BadTrials','NoCR','CR','PercentCR'});

    Results = [Results; newRow];

end

%% ================= EXPORT RESULTS =================

% Subject-level summary
outfile_summary = fullfile(outdir, 'CR_summary_table_young.csv');
writetable(Results, outfile_summary);

% Trial-level CR flags (subjects = columns, all 60 trials)
CR_table = array2table(CR_FLAG_MATRIX, 'VariableNames', SubjectIDs);
outfile_flags = fullfile(outdir, 'CR_flag_matrix_young.csv');
writetable(CR_table, outfile_flags);

disp(' ');
disp('============================================');
disp('Processing complete.');
disp(['Summary table saved: ' outfile_summary]);
disp(['CR flag matrix saved: ' outfile_flags]);
disp(['Figures saved in: ' outdir]);
disp('============================================');
