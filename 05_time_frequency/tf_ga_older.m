%% ========================================================================
% REBUILD GA_older.mat  (FINAL CLEAN VERSION)
% OLDER ADULTS ONLY
% Control vs Personalised
%
% Uses SAME METHOD as GA_young:
% mean across available channels directly
%
% Outputs:
%   GA.OC_EV   GA.OP_EV
%   GA.OC_ITC  GA.OP_ITC
%   GA.OC_IN   GA.OP_IN
%   GA.OC_TOT  GA.OP_TOT
%
% Saves:
%   GA.freq
%   GA.time
%% ========================================================================

clear; clc; close all;

%% ========================================================================
% PATH
%% ========================================================================

tf_folder = ...
'C:\TEBC_project\intermediate_files\TF_results';

cd(tf_folder)

files = dir('*_TF.mat');

%% ========================================================================
% GROUP IDS
%% ========================================================================

older_personalised = [1 3 4 6 9 11 13 14 15 18];
older_control      = [2 5 7 8 10 12 16 17 19];

%% ========================================================================
% STORAGE
%% ========================================================================

OC_EV=[]; OP_EV=[];
OC_IT=[]; OP_IT=[];
OC_IN=[]; OP_IN=[];
OC_TO=[]; OP_TO=[];

freq = [];
time = [];

%% ========================================================================
% LOOP FILES
%% ========================================================================

for k = 1:length(files)

    fname = files(k).name;

    % only older participants
    if ~contains(fname,'PLe')
        continue
    end

    fprintf('\nLoading %s\n',fname)

    load(fname,'EVOKED','ITC','INDUCED','TOTAL');

    %% ------------------------------------------------------------
    % subject number
    %% ------------------------------------------------------------

    subj = extractBefore(fname,'_TF');
    num  = str2double(regexprep(subj,'[^0-9]',''));

    %% ------------------------------------------------------------
    % axes
    %% ------------------------------------------------------------

    if isempty(freq)
        freq = EVOKED.freq;
        time = EVOKED.time;
    end

    %% ------------------------------------------------------------
    % check dimensions
    %% ------------------------------------------------------------

    sz = size(EVOKED.powspctrm);

    if length(sz) ~= 3
        warning('%s bad dimensions',fname)
        continue
    end

    %% ------------------------------------------------------------
    % IMPORTANT:
    % same logic as young GA
    % mean across channels directly
    % dims: chan x freq x time -> freq x time
    %% ------------------------------------------------------------

    ev = squeeze(mean(EVOKED.powspctrm,1,'omitnan'));
    it = squeeze(mean(ITC.powspctrm,1,'omitnan'));
    in = squeeze(mean(INDUCED.powspctrm,1,'omitnan'));
    to = squeeze(mean(TOTAL.powspctrm,1,'omitnan'));

    %% ------------------------------------------------------------
    % assign group
    %% ------------------------------------------------------------

    if ismember(num,older_control)

        OC_EV(:,:,end+1) = ev;
        OC_IT(:,:,end+1) = it;
        OC_IN(:,:,end+1) = in;
        OC_TO(:,:,end+1) = to;

        fprintf(' -> Older Control\n')

    elseif ismember(num,older_personalised)

        OP_EV(:,:,end+1) = ev;
        OP_IT(:,:,end+1) = it;
        OP_IN(:,:,end+1) = in;
        OP_TO(:,:,end+1) = to;

        fprintf(' -> Older Personalised\n')

    else
        warning('Subject %d not assigned',num)
    end

end

%% ========================================================================
% SANITY CHECK
%% ========================================================================

disp(' ')
disp('======================================')
disp('SANITY CHECK')
disp('======================================')

fprintf('Older Control subjects      : %d\n',size(OC_EV,3));
fprintf('Older Personalised subjects : %d\n',size(OP_EV,3));

%% ========================================================================
% GRAND AVERAGE
%% ========================================================================

GA = struct;

GA.freq = freq;
GA.time = time;

GA.OC_EV  = mean(OC_EV,3,'omitnan');
GA.OP_EV  = mean(OP_EV,3,'omitnan');

GA.OC_ITC = mean(OC_IT,3,'omitnan');
GA.OP_ITC = mean(OP_IT,3,'omitnan');

GA.OC_IN  = mean(OC_IN,3,'omitnan');
GA.OP_IN  = mean(OP_IN,3,'omitnan');

GA.OC_TOT = mean(OC_TO,3,'omitnan');
GA.OP_TOT = mean(OP_TO,3,'omitnan');

%% ========================================================================
% SAVE
%% ========================================================================

save('GA_older.mat','GA','-v7.3');

disp(' ')
disp('======================================')
disp('GA_older.mat SAVED')
disp('======================================')

%% ========================================================================
% FINAL CHECK
%% ========================================================================

disp('Size GA.OC_EV:')
disp(size(GA.OC_EV))

disp('First 10 freq bins:')
disp(GA.freq(1:10))

fprintf('Mean OC_EV = %.3f\n',mean(GA.OC_EV(:),'omitnan'));
fprintf('Max  OC_EV = %.3f\n',max(GA.OC_EV(:)));

%% ========================================================================
% QUICK PREVIEW
%% ========================================================================

figure('Color','w','Position',[200 200 1100 420])

subplot(1,2,1)
imagesc(GA.time*1000,GA.freq,GA.OC_EV)
axis xy
xlabel('Time (ms)')
ylabel('Hz')
title('Older Control Evoked')
colorbar

subplot(1,2,2)
imagesc(GA.time*1000,GA.freq,GA.OP_EV)
axis xy
xlabel('Time (ms)')
ylabel('Hz')
title('Older Personalised Evoked')
colorbar