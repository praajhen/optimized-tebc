% TEBC TIME-FREQUENCY ANALYSIS (FINAL CORRECTED)

clear; clc; close all;

%% ========================================================================
% FIELDTRIP
%% ========================================================================

addpath('C:\toolboxes\fieldtrip-20251218');
ft_defaults;

addpath('C:\TEBC_project\matlab_code');

%% ========================================================================
% PATHS
%% ========================================================================

data_folder = ...
'C:\TEBC_project\intermediate_files\ICA_cleaned\TEBC';

save_folder = ...
'C:\TEBC_project\intermediate_files\TF_results';

if ~exist(save_folder,'dir')
    mkdir(save_folder);
end

%% ========================================================================
% FILE LIST (.set + .eeg)
%% ========================================================================

all_set = dir(fullfile(data_folder,'*_TEBC.set'));
all_eeg = dir(fullfile(data_folder,'*_TEBC.eeg'));

files = all_set;

for i = 1:length(all_eeg)

    eegname = all_eeg(i).name;
    [~,base,~] = fileparts(eegname);

    setname = [base '.set'];

    if ~any(strcmp({all_set.name},setname))
        files = [files; all_eeg(i)];
    end
end

[~,idx] = sort({files.name});
files = files(idx);

fprintf('\n====================================================\n');
fprintf('VALID SUBJECT FILES:\n');
disp({files.name}')
fprintf('TOTAL = %d\n',length(files));
fprintf('====================================================\n');

%% ========================================================================
% LOOP SUBJECTS
%% ========================================================================

for s = 1:length(files)

    clear data tf_data tf_roi ...
          freq_fourier freq_pow freq_evoked ...
          timelock ITC TOTAL EVOKED INDUCED META

    fname = files(s).name;
    full_name = fullfile(data_folder,fname);

    fprintf('\n=====================================================\n');
    fprintf('Processing %d / %d : %s\n',s,length(files),fname);
    fprintf('=====================================================\n');

    [~,subj,~] = fileparts(fname);

    %% ====================================================================
    % LOAD DATA
    %% ====================================================================
    cfg = [];
    cfg.dataset = full_name;
    data = ft_preprocessing(cfg);

    %% ====================================================================
    % DEFINE TRIALS
    %% ====================================================================
    cfg = [];
    cfg.dataset = full_name;
    cfg.trialfun = 'tebcerp';
    cfg.trialdef.prestim  = 1.0;
    cfg.trialdef.poststim = 1.0;
    cfg = ft_definetrial(cfg);

    tf_data = ft_redefinetrial(cfg,data);

    nTrials = length(tf_data.trial);

    %% ====================================================================
    % FILTERING
    % Bandpass 1-30 Hz
    % Notch 50 Hz
    %% ====================================================================
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq   = [1 30];

    cfg.bsfilter = 'yes';
    cfg.bsfreq   = [49 51];

    tf_data = ft_preprocessing(cfg,tf_data);

    %% ====================================================================
    % BASELINE REMOVE
    %% ====================================================================
    cfg = [];
    cfg.demean = 'yes';
    cfg.baselinewindow = [-0.30 -0.05];
    tf_data = ft_preprocessing(cfg,tf_data);

    %% ====================================================================
    % AVERAGE REFERENCE
    %% ====================================================================
    cfg = [];
    cfg.reref = 'yes';
    cfg.refmethod = 'avg';
    cfg.refchannel = 'all';
    tf_data = ft_preprocessing(cfg,tf_data);

    %% ====================================================================
    % ROI CHANNELS
    %% ====================================================================
    cfg = [];
    cfg.channel = {'E6','E7','E106'};
    tf_roi = ft_selectdata(cfg,tf_data);

    %% ====================================================================
    % TF SETTINGS
    %% ====================================================================
    foi   = 4:1:15;
    toi   = -0.30:0.01:0.50;
    width = 3;

    %% ====================================================================
    % FOURIER (ITC)
    %% ====================================================================
    cfg = [];
    cfg.method     = 'wavelet';
    cfg.output     = 'fourier';
    cfg.foi        = foi;
    cfg.toi        = toi;
    cfg.width      = width;
    cfg.keeptrials = 'yes';
    cfg.pad        = 'nextpow2';

    freq_fourier = ft_freqanalysis(cfg,tf_roi);

    %% ====================================================================
    % TOTAL POWER
    %% ====================================================================
    cfg.output = 'pow';
    freq_pow = ft_freqanalysis(cfg,tf_roi);

    %% ====================================================================
    % EVOKED POWER
    %% ====================================================================
    timelock = ft_timelockanalysis([],tf_roi);

    if isfield(timelock,'sampleinfo')
        timelock = rmfield(timelock,'sampleinfo');
    end

    cfg2 = [];
    cfg2.method = 'wavelet';
    cfg2.output = 'pow';
    cfg2.foi    = foi;
    cfg2.toi    = toi;
    cfg2.width  = width;
    cfg2.pad    = 'nextpow2';

    freq_evoked = ft_freqanalysis(cfg2,timelock);

    %% ====================================================================
    % ITC
    %% ====================================================================
    F = freq_fourier.fourierspctrm;

    phase_norm = F ./ (abs(F) + eps);

    itc_data = abs(squeeze(mean(phase_norm,1)));

    ITC = [];
    ITC.label = freq_fourier.label;
    ITC.freq  = freq_fourier.freq;
    ITC.time  = freq_fourier.time;
    ITC.dimord = 'chan_freq_time';
    ITC.powspctrm = itc_data;

    %% ====================================================================
    % TOTAL POWER
    %% ====================================================================
    totalpow = squeeze(mean(freq_pow.powspctrm,1));

    TOTAL = [];
    TOTAL.label = freq_pow.label;
    TOTAL.freq  = freq_pow.freq;
    TOTAL.time  = freq_pow.time;
    TOTAL.dimord = 'chan_freq_time';
    TOTAL.powspctrm = totalpow;

    %% ====================================================================
    % EVOKED POWER
    %% ====================================================================
    EVOKED = freq_evoked;

    %% ====================================================================
    % INDUCED POWER
    %% ====================================================================
    inducedpow = totalpow - freq_evoked.powspctrm;
    inducedpow(inducedpow < 0) = 0;

    INDUCED = freq_evoked;
    INDUCED.powspctrm = inducedpow;

    %% ====================================================================
    % META
    %% ====================================================================
    META = struct;
    META.subject_id   = subj;
    META.source_file  = fname;
    META.nTrials      = nTrials;
    META.foi          = foi;
    META.toi          = toi;
    META.width        = width;
    META.filter       = [1 30];
    META.notch        = 50;
    META.baseline     = [-0.30 -0.05];
    META.channels     = {'E6','E7','E106'};
    META.date_created = datestr(now);

    %% ====================================================================
    % SAVE
    %% ====================================================================
    save_name = fullfile(save_folder,[subj '_TF.mat']);

    save(save_name,...
        'ITC','TOTAL','EVOKED','INDUCED','META','-v7.3');

    fprintf('Saved --> %s\n',save_name);

end

%% ========================================================================
disp('=====================================================')
disp('ALL SUBJECTS COMPLETED')
disp('=====================================================')