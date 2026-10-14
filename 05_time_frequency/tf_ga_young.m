%% ========================================================================
% FULL GRAND AVERAGE REBUILD (YOUNG ONLY)
% Corrected version: no older-to-young matching
%
% Handles:
%   PL##_TF.mat
%   PL##_TEBC_TF.mat
%
% Outputs:
%   GA_young.mat
%% ========================================================================

clear; clc; close all;

%% ========================================================================
% FOLDER
%% ========================================================================

folder = ...
'C:\TEBC_project\intermediate_files\TF_results';

cd(folder)

files = dir('*_TF.mat');

load('TF_design.mat');

fprintf('\nFound %d TF files\n',length(files));

%% ========================================================================
% STORAGE
%% ========================================================================

YC_ITC=[]; YP_ITC=[];
YC_EV =[]; YP_EV =[];
YC_IN =[]; YP_IN =[];

freq = [];
time = [];

%% ========================================================================
% LOOP FILES
%% ========================================================================

for s = 1:length(files)

    fname = files(s).name;

    % skip older files directly
    if contains(fname,'PLe')
        continue
    end

    fprintf('\nProcessing %s\n',fname);

    load(fname,'ITC','EVOKED','INDUCED');

    if isempty(freq)
        freq = EVOKED.freq;
        time = EVOKED.time;
    end

    %% ---------------------------------------------------------------
    % Candidate names (NO PLe -> PL conversion!)
    %% ---------------------------------------------------------------

    cand = {};

    cand{end+1} = fname;
    cand{end+1} = erase(fname,'_TEBC');

    cand = unique(cand);

    %% ---------------------------------------------------------------
    % Match TF_design
    %% ---------------------------------------------------------------

    idx = false(height(TF_design),1);

    for k = 1:length(cand)

        idx = strcmp(TF_design.TFfile,cand{k});

        if any(idx)
            fprintf('Matched: %s\n',cand{k});
            break
        end
    end

    if ~any(idx)
        warning('No match for %s',fname);
        continue
    end

    age   = TF_design.AgeLabel{idx};
    group = TF_design.GroupLabel{idx};

    fprintf('Age=%s | Group=%s\n',age,group);

    % safety: only young accepted
    if ~strcmp(age,'Young')
        continue
    end

    %% ---------------------------------------------------------------
    % Mean over channels
    %% ---------------------------------------------------------------

    m1 = squeeze(mean(ITC.powspctrm,1,'omitnan'));
    m2 = squeeze(mean(EVOKED.powspctrm,1,'omitnan'));
    m3 = squeeze(mean(INDUCED.powspctrm,1,'omitnan'));

    %% ---------------------------------------------------------------
    % Store
    %% ---------------------------------------------------------------

    if strcmp(group,'Control')

        YC_ITC(:,:,end+1)=m1;
        YC_EV(:,:,end+1)=m2;
        YC_IN(:,:,end+1)=m3;

    elseif strcmp(group,'Personalised')

        YP_ITC(:,:,end+1)=m1;
        YP_EV(:,:,end+1)=m2;
        YP_IN(:,:,end+1)=m3;

    end

end

%% ========================================================================
% GRAND AVERAGE
%% ========================================================================

GA = struct;

GA.freq = freq;
GA.time = time;

GA.YC_ITC = mean(YC_ITC,3,'omitnan');
GA.YP_ITC = mean(YP_ITC,3,'omitnan');

GA.YC_EV = mean(YC_EV,3,'omitnan');
GA.YP_EV = mean(YP_EV,3,'omitnan');

GA.YC_IN = mean(YC_IN,3,'omitnan');
GA.YP_IN = mean(YP_IN,3,'omitnan');

%% ========================================================================
% SANITY CHECK
%% ========================================================================

disp('======================================')
disp('SANITY CHECK')
disp('======================================')

fprintf('Young Control subjects      : %d\n',size(YC_EV,3));
fprintf('Young Personalised subjects : %d\n',size(YP_EV,3));

fprintf('GA size: ');
disp(size(GA.YC_EV))

%% ========================================================================
% SAVE
%% ========================================================================

save('GA_young.mat','GA','-v7.3');

disp('======================================')
disp('GA_young.mat SAVED')
disp('======================================')