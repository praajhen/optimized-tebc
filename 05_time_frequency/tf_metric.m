%% ========================================================================
% STAGE 2
% EXTRACT SUBJECT-LEVEL TIME-FREQUENCY METRICS
%
% Manuscript:
%   ROI            : E6 E7 E106
%   Frequency band : 5–10 Hz
%   Time window    : 80–300 ms
%
% Metrics:
%   ITC
%   Evoked Power
%   Induced Power
%
% Outputs:
%   TF_metrics.mat
%   TF_metrics.xlsx
%% ========================================================================

clear; clc; close all;

%% ========================================================================
% PATH
%% ========================================================================

folder = ...
'C:\TEBC_project\intermediate_files\TF_results';

cd(folder)

%% ========================================================================
% LOAD DESIGN TABLE
%% ========================================================================

load('TF_design.mat')

nSub = height(TF_design);

fprintf('\n=====================================================\n');
fprintf('STAGE 2 : EXTRACT TF METRICS\n');
fprintf('=====================================================\n');
fprintf('Subjects : %d\n\n',nSub);

%% ========================================================================
% MANUSCRIPT WINDOW
%% ========================================================================

freq_window = [5 10];      % Hz
time_window = [0.08 0.30]; % seconds

%% ========================================================================
% PREALLOCATE
%% ========================================================================

ITCmean     = nan(nSub,1);
EVOKEDmean  = nan(nSub,1);
INDUCEDmean = nan(nSub,1);

UsedFile = strings(nSub,1);

%% ========================================================================
% LOOP SUBJECTS
%% ========================================================================

for s = 1:nSub

    %% ------------------------------------------------------------
    % File name
    %% ------------------------------------------------------------

    fname = TF_design.TFfile{s};

    if ~isfile(fname)

        alt = strrep(fname,'_TF.mat','_TEBC_TF.mat');

        if isfile(alt)
            fname = alt;
        else
            warning('%s not found.',fname)
            continue
        end

    end

    UsedFile(s) = string(fname);

    fprintf('%2d/%2d  %s\n',s,nSub,fname);

    %% ------------------------------------------------------------
    % Load
    %% ------------------------------------------------------------

    load(fname,'ITC','EVOKED','INDUCED');

    %% ------------------------------------------------------------
    % Frequency indices
    %% ------------------------------------------------------------

    fidx = ITC.freq >= freq_window(1) & ...
           ITC.freq <= freq_window(2);

    %% ------------------------------------------------------------
    % Time indices
    %% ------------------------------------------------------------

    tidx = ITC.time >= time_window(1) & ...
           ITC.time <= time_window(2);

    %% ------------------------------------------------------------
    % Average CHANNELS
    %
    % 3 x freq x time
    % ->
    % freq x time
    %% ------------------------------------------------------------

    ITC_roi = squeeze(mean(ITC.powspctrm,1,'omitnan'));

    EV_roi  = squeeze(mean(EVOKED.powspctrm,1,'omitnan'));

    IN_roi  = squeeze(mean(INDUCED.powspctrm,1,'omitnan'));

    %% ------------------------------------------------------------
    % Average FREQUENCIES
    %
    % freq x time
    % ->
    % 1 x time
    %% ------------------------------------------------------------

    ITC_theta = mean(ITC_roi(fidx,:),1,'omitnan');

    EV_theta  = mean(EV_roi(fidx,:),1,'omitnan');

    IN_theta  = mean(IN_roi(fidx,:),1,'omitnan');

    %% ------------------------------------------------------------
    % Average TIME
    %% ------------------------------------------------------------

    ITCmean(s) = mean(ITC_theta(tidx),'omitnan');

    EVOKEDmean(s) = mean(EV_theta(tidx),'omitnan');

    INDUCEDmean(s) = mean(IN_theta(tidx),'omitnan');

end

%% ========================================================================
% BUILD TABLE
%% ========================================================================

TF_metrics = table;

TF_metrics.Subject      = TF_design.Subject;
TF_metrics.AgeLabel     = TF_design.AgeLabel;
TF_metrics.GroupLabel   = TF_design.GroupLabel;

TF_metrics.ITCmean      = ITCmean;
TF_metrics.EVOKEDmean   = EVOKEDmean;
TF_metrics.INDUCEDmean  = INDUCEDmean;

TF_metrics.UsedFile     = UsedFile;

%% ========================================================================
% SAVE
%% ========================================================================

save('TF_metrics.mat','TF_metrics');

writetable(TF_metrics,'TF_metrics.xlsx');

%% ========================================================================
% SANITY CHECK
%% ========================================================================

fprintf('\n=====================================================\n');
fprintf('SANITY CHECK\n');
fprintf('=====================================================\n');

fprintf('Valid ITC      : %d/%d\n',sum(~isnan(ITCmean)),nSub);
fprintf('Valid Evoked   : %d/%d\n',sum(~isnan(EVOKEDmean)),nSub);
fprintf('Valid Induced  : %d/%d\n',sum(~isnan(INDUCEDmean)),nSub);

fprintf('\n');

disp(summary(TF_metrics(:,{'ITCmean','EVOKEDmean','INDUCEDmean'})))

%% ========================================================================
% DESCRIPTIVE STATISTICS
%% ========================================================================

fprintf('\n=====================================================\n');
fprintf('GROUP DESCRIPTIVE STATISTICS\n');
fprintf('=====================================================\n');

disp(groupsummary(TF_metrics,...
    ["AgeLabel","GroupLabel"],...
    ["mean","std"],...
    ["ITCmean","EVOKEDmean","INDUCEDmean"]))

%% ========================================================================
% SIMPLE GROUP TESTS
%% ========================================================================

gC = strcmp(TF_metrics.GroupLabel,'Control');
gP = strcmp(TF_metrics.GroupLabel,'Personalised');

[~,pITC] = ttest2(TF_metrics.ITCmean(gC),...
                  TF_metrics.ITCmean(gP));

[~,pEV] = ttest2(TF_metrics.EVOKEDmean(gC),...
                 TF_metrics.EVOKEDmean(gP));

[~,pIN] = ttest2(TF_metrics.INDUCEDmean(gC),...
                 TF_metrics.INDUCEDmean(gP));

fprintf('\n=====================================================\n');
fprintf('CONTROL vs PERSONALISED\n');
fprintf('=====================================================\n');

fprintf('ITC      : p = %.5f\n',pITC);
fprintf('Evoked   : p = %.5f\n',pEV);
fprintf('Induced  : p = %.5f\n',pIN);

%% ========================================================================
% QUICK VISUAL CHECK
%% ========================================================================

figure('Color','w','Position',[100 100 1200 360])

g = categorical(TF_metrics.GroupLabel);

subplot(1,3,1)
boxchart(g,TF_metrics.ITCmean,'MarkerStyle','.')
ylabel('Mean ITC')
title('ITC')
grid on

subplot(1,3,2)
boxchart(g,TF_metrics.EVOKEDmean,'MarkerStyle','.')
ylabel('Mean Evoked Power')
title('Evoked')
grid on

subplot(1,3,3)
boxchart(g,TF_metrics.INDUCEDmean,'MarkerStyle','.')
ylabel('Mean Induced Power')
title('Induced')
grid on

sgtitle('Stage 2 : Subject-Level TF Metrics')

fprintf('\n=====================================================\n');
fprintf('STAGE 2 COMPLETED SUCCESSFULLY\n');
fprintf('=====================================================\n');