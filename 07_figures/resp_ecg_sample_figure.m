%% =========================================================
% CLEAN SIGNAL EXAMPLE FIGURE
% Panel A = ECG (5 s)
% Panel B = Respiration (10 s)
% Same participant: PL41_A
%% =========================================================

clear; clc; close all;

addpath('C:\toolboxes\fieldtrip-20251218');
ft_defaults;

file = 'C:\TEBC_project\data\auditory\PL41_A.edf';

fs = 1000;   % Hz

%% =========================================================
% ECG
%% =========================================================

cfg = [];
cfg.dataset  = file;
cfg.channel  = 'ecg';
cfg.bpfilter = 'yes';
cfg.bpfreq   = [1 40];
cfg.demean   = 'yes';

ecg = ft_preprocessing(cfg);

ECG = ecg.trial{1};
ECG = ECG(:)';

% take first 5 seconds
ECG = ECG(1:5000);

% normalize
ECG = (ECG - mean(ECG)) ./ std(ECG);

tECG = (0:length(ECG)-1)/fs;

%% =========================================================
% RESPIRATION
%% =========================================================

cfg = [];
cfg.dataset = file;
cfg.channel = 'Resp';
cfg.demean  = 'yes';
cfg.detrend = 'yes';

cfg.lpfilter   = 'yes';
cfg.lpfreq     = 1;
cfg.lpfilttype = 'firws';

resp = ft_preprocessing(cfg);

RESP = resp.trial{1};
RESP = RESP(:)';

% take first 10 seconds
RESP = RESP(1:10000);

% normalize
RESP = (RESP - mean(RESP)) ./ std(RESP);

tRESP = (0:length(RESP)-1)/fs;

%% =========================================================
% FIGURE
%% =========================================================

figure('Color','w','Position',[100 100 1180 430]);

set(groot,'defaultAxesFontName','Arial')
set(groot,'defaultAxesFontSize',16)
axisFont = 16;     % tick labels
labelFont = 18;    % x/y labels
titleFont = 18;    % titles

%% ---------------------------------------------------------
% PANEL A ECG
%% ---------------------------------------------------------

subplot(1,2,1)
plot(tECG,ECG,'k','LineWidth',2)

xlabel('Time (s)','FontSize',labelFont)
ylabel('Normalized amplitude','FontSize',labelFont)

% title('A. ECG signal (5 s)','FontWeight','bold')
set(gca,'FontSize',axisFont)
xlim([0 5])
box off

%% ---------------------------------------------------------
% PANEL B RESP
%% ---------------------------------------------------------

subplot(1,2,2)
plot(tRESP,RESP,'k','LineWidth',2)

xlabel('Time (s)','FontSize',labelFont)
ylabel('Normalized amplitude','FontSize',labelFont)
% title('B. Respiration signal (10 s)','FontWeight','bold')

set(gca,'FontSize',axisFont)
xlim([0 10])
box off

%% ---------------------------------------------------------
% EXPORT
%% ---------------------------------------------------------

exportgraphics(gcf,...
'PL41A_ECG5s_RESP10s.png',...
'Resolution',600);