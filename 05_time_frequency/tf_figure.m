%% ========================================================================
% MECHANISM FIGURE (PERCENT CHANGE)
% Answers:
% Is larger N1-P2 in Personalised group due to:
%   A) Higher ITC
%   B) Higher Evoked power
%   C) Higher Induced power
%
% Metric shown:
%   ((Personalised - Control) ./ abs(Control)) * 100
%
% Positive = Personalised larger
% Negative = Control larger
%% ========================================================================

clear; clc; close all;

%% ========================================================================
% FOLDER
%% ========================================================================
folder = ...
'C:\TEBC_project\intermediate_files\TF_results';

cd(folder)

load('TF_design.mat');

nSub = height(TF_design);

ITC_C = [];
ITC_P = [];

EV_C = [];
EV_P = [];

IN_C = [];
IN_P = [];

%% ========================================================================
% LOAD SUBJECTS
%% ========================================================================
for s = 1:nSub

    fname = TF_design.TFfile{s};

    if ~isfile(fname)
        continue
    end

    load(fname,'ITC','EVOKED','INDUCED');

    % ROI average across channels
    d1 = squeeze(mean(ITC.powspctrm,1));       % freq x time
    d2 = squeeze(mean(EVOKED.powspctrm,1));
    d3 = squeeze(mean(INDUCED.powspctrm,1));

    if TF_design.Group(s)==1
        ITC_C = cat(3,ITC_C,d1);
        EV_C  = cat(3,EV_C,d2);
        IN_C  = cat(3,IN_C,d3);
    else
        ITC_P = cat(3,ITC_P,d1);
        EV_P  = cat(3,EV_P,d2);
        IN_P  = cat(3,IN_P,d3);
    end

end

freq = ITC.freq;
time = ITC.time;

%% ========================================================================
% GROUP MEANS
%% ========================================================================
ITCctrl = mean(ITC_C,3,'omitnan');
ITCpers = mean(ITC_P,3,'omitnan');

EVctrl  = mean(EV_C,3,'omitnan');
EVpers  = mean(EV_P,3,'omitnan');

INctrl  = mean(IN_C,3,'omitnan');
INpers  = mean(IN_P,3,'omitnan');

%% ========================================================================
% PERCENT CHANGE
%% ========================================================================
epsv = 1e-9;

ITCchg = ((ITCpers - ITCctrl) ./ (abs(ITCctrl)+epsv)) * 100;
EVchg  = ((EVpers  - EVctrl ) ./ (abs(EVctrl )+epsv)) * 100;
INchg  = ((INpers  - INctrl ) ./ (abs(INctrl )+epsv)) * 100;

%% ========================================================================
% ROBUST COLOR LIMITS
%% ========================================================================
mx1 = max(abs(prctile(ITCchg(:),[5 95])));
mx2 = max(abs(prctile(EVchg(:), [5 95])));
mx3 = max(abs(prctile(INchg(:), [5 95])));

%% ========================================================================
% RED-WHITE-BLUE COLORMAP
%% ========================================================================
n = 256;
r = [(0:n/2-1)'/(n/2); ones(n/2,1)];
g = [(0:n/2-1)'/(n/2); flipud((0:n/2-1)'/(n/2))];
b = [ones(n/2,1); flipud((0:n/2-1)'/(n/2))];
cmap = [r g b];

%% ========================================================================
% FIGURE
%% ========================================================================
figure('Color','w','Position',[50 100 1550 480]);

DATA   = {ITCchg, EVchg, INchg};
LIMS   = {mx1, mx2, mx3};
TITLES = { ...
'ITC (% Change)', ...
'Evoked Power (% Change)', ...
'Induced Power (% Change)'};

for k = 1:3

    subplot(1,3,k)

    imagesc(time,freq,DATA{k});
    axis xy
    axis tight

    xlabel('Time (s)','FontSize',12)
    ylabel('Frequency (Hz)','FontSize',12)
    title(TITLES{k},'FontSize',14,'FontWeight','bold')

    xline(0,'k--','LineWidth',1.2)

    rectangle('Position',[0.08 4 0.22 8], ...
        'EdgeColor','k', ...
        'LineStyle','--', ...
        'LineWidth',1.8)

    colormap(gca,cmap)

    cb = colorbar;
    cb.Label.String = '% change from control';
    cb.FontSize = 10;

    caxis([-LIMS{k} LIMS{k}])

    set(gca,'FontSize',11,'LineWidth',1.2,...
        'Box','off','TickDir','out')

end

sgtitle(' Personalised vs. control (% Change)', ...
    'FontSize',18,'FontWeight','bold')

%% ========================================================================
% SAVE
%% ========================================================================
saveas(gcf,'Mechanism_PercentChange.png')



%% ========================================================================
% CLEAN CORRELATION FIGURES
% TEBC N1-P2 Composite vs TF Metrics
%
% Fixes:
% 1) Clear axis labels
% 2) Only ONE overall regression line
% 3) Young / Older colored separately
% 4) Nice formatting for PowerPoint
% 5) Shows r and p on figure
%% ========================================================================

clear; clc; close all;

%% ========================================================================
% LOAD DATA
%% ========================================================================
load('C:\TEBC_project\intermediate_files\TF_results\TF_metrics.mat');
load('C:\TEBC_project\intermediate_files\TEBC_compositie value.mat');

TF_metrics.N1P2 = a(:);

Age = categorical(TF_metrics.AgeLabel);

%% ========================================================================
% VARIABLES TO PLOT
%% ========================================================================
vars = {'ITCmean','EVOKEDmean','INDUCEDmean'};

titles = { ...
'ITC', ...
'Evoked Power', ...
'Induced Power'};

xlabels = { ...
'Inter-Trial Coherence (0-1)', ...
'Evoked TF Power (a.u.)', ...
'Induced TF Power (a.u.)'};

%% ========================================================================
% LOOP
%% ========================================================================
for v = 1:length(vars)

    %% --------------------------------------------------------------------
    % DATA
    %% --------------------------------------------------------------------
    x = TF_metrics.(vars{v});
    y = TF_metrics.N1P2;

    good = ~isnan(x) & ~isnan(y);

    x = x(good);
    y = y(good);
    Age2 = Age(good);

    idxY = Age2=="Young";
    idxO = Age2=="Older";

    %% --------------------------------------------------------------------
    % CORRELATION
    %% --------------------------------------------------------------------
    [r,p] = corr(x,y,'type','Pearson');

    %% --------------------------------------------------------------------
    % FIGURE
    %% --------------------------------------------------------------------
    figure('Color','w','Position',[100 100 760 560]); hold on

    % Young
    scatter(x(idxY),y(idxY),90,...
        'filled',...
        'MarkerFaceColor',[0 0.4470 0.7410],...
        'MarkerEdgeColor','k',...
        'LineWidth',0.6);

    % Older
    scatter(x(idxO),y(idxO),90,...
        'filled',...
        'MarkerFaceColor',[0.8500 0.3250 0.0980],...
        'MarkerEdgeColor','k',...
        'LineWidth',0.6);

    %% --------------------------------------------------------------------
    % SINGLE OVERALL REGRESSION LINE
    %% --------------------------------------------------------------------
    pfit = polyfit(x,y,1);

    xx = linspace(min(x),max(x),200);
    yy = polyval(pfit,xx);

    plot(xx,yy,'k-','LineWidth',2.5);

    %% --------------------------------------------------------------------
    % LABELS
    %% --------------------------------------------------------------------
    xlabel(xlabels{v},'FontSize',15,'FontWeight','bold')
    ylabel('TEBC N1-P2 Composite','FontSize',15,'FontWeight','bold')

    title(sprintf('%s vs TEBC N1-P2',titles{v}),...
        'FontSize',18,'FontWeight','bold')

    legend({'Young','Older','Overall Fit'},...
        'Location','best',...
        'FontSize',12)

    %% --------------------------------------------------------------------
    % STATS TEXT
    %% --------------------------------------------------------------------
    txt = sprintf('r = %.3f\np = %.4f\nn = %d',r,p,length(x));

    xloc = min(x) + 0.05*(max(x)-min(x));
    yloc = max(y) - 0.12*(max(y)-min(y));

    text(xloc,yloc,txt,...
        'FontSize',13,...
        'BackgroundColor','w',...
        'EdgeColor',[0.7 0.7 0.7],...
        'Margin',7)

    %% --------------------------------------------------------------------
    % STYLE
    %% --------------------------------------------------------------------
    grid on
    box off
    set(gca,...
        'FontSize',13,...
        'LineWidth',1.3,...
        'TickDir','out')

    %% --------------------------------------------------------------------
    % SAVE
    %% --------------------------------------------------------------------
    saveas(gcf,[vars{v} '_CleanScatter.png'])

end

disp('=================================================')
disp('DONE: Clean figures saved')
disp('=================================================')