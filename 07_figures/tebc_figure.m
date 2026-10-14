%% ============================================================
%   TEBC Acquisition Figure (Young vs Older)
%   Clean publication-style layout
% ============================================================

clear; clc;
load('C:\MyTemp\Personalised TEBC (2024-2025)\CR\CR.mat') %check only learners
%% ================= STYLE SETTINGS (EDIT HERE ONLY) =================

FONT_NAME   = 'Arial';
FONT_SIZE   = 14;
AXIS_WIDTH  = 1.2;
LINE_WIDTH  = 2.0;
MARKER_SIZE = 7;
ERROR_WIDTH = 1.2;
CAP_SIZE    = 6;      % smaller caps

COLOR_CTRL  = [0 0 0];     % black
COLOR_PERS  = [1 0 0];     % red

Y_LIM       = [0 100];

%% ================= DATA PREPARATION =================

% X positions with visual gaps
x = [1 3 4 5 6 7 9];
labels = {'CS alone','1','2','3','4','5','EXT'};

young = CR(:,8) == 1;
older = CR(:,8) == 2;

control = CR(:,9) == 1;
personalised = CR(:,9) == 2;

%% ================= COMPUTE MEANS & SEM =================

Yc = CR(young & control,1:7);
Yp = CR(young & personalised,1:7);

Oc = CR(older & control,1:7);
Op = CR(older & personalised,1:7);

Yc_mean = mean(Yc);  Yc_sem = std(Yc)./sqrt(size(Yc,1));
Yp_mean = mean(Yp);  Yp_sem = std(Yp)./sqrt(size(Yp,1));

Oc_mean = mean(Oc);  Oc_sem = std(Oc)./sqrt(size(Oc,1));
Op_mean = mean(Op);  Op_sem = std(Op)./sqrt(size(Op,1));

%% ================= SAMPLE SIZES =================

n_Yc = sum(young & control);
n_Yp = sum(young & personalised);

n_Oc = sum(older & control);
n_Op = sum(older & personalised);

%% ================= FIGURE =================

figure('Position',[200 200 1100 420])

%% ================= PANEL 1: YOUNG =================

subplot(1,2,1); hold on

h1 = errorbar(x, Yc_mean, Yc_sem, '-o');
h1.Color = COLOR_CTRL;
h1.LineWidth = LINE_WIDTH;
h1.MarkerSize = MARKER_SIZE;
h1.CapSize = CAP_SIZE;
h1.Bar.LineWidth = ERROR_WIDTH;

h2 = errorbar(x, Yp_mean, Yp_sem, '-o');
h2.Color = COLOR_PERS;
h2.LineWidth = LINE_WIDTH;
h2.MarkerSize = MARKER_SIZE;
h2.CapSize = CAP_SIZE;
h2.Bar.LineWidth = ERROR_WIDTH;

xline(2,'k:','LineWidth',1);
xline(8,'k:','LineWidth',1);

xticks(x)
xticklabels(labels)
xtickangle(0)

xlim([0 10])
ylim(Y_LIM)

title('Young','FontName',FONT_NAME,'FontSize',FONT_SIZE,'FontWeight', 'normal')
xlabel('TEBC Block','FontName',FONT_NAME,'FontSize',FONT_SIZE)
ylabel('% conditioned responding','FontName',FONT_NAME,'FontSize',FONT_SIZE)

legend({sprintf('Control (n = %d)', n_Yc), ...
        sprintf('Personalised (n = %d)', n_Yp)}, ...
        'FontName', FONT_NAME, ...
        'FontSize', FONT_SIZE-1, ...
        'Location', 'northwest');

set(gca,'FontName',FONT_NAME,...
        'FontSize',FONT_SIZE,...
        'LineWidth',AXIS_WIDTH)

box off

text(-0.15, 1.05, 'A', ...
    'Units','normalized', ...
    'FontName', FONT_NAME, ...
    'FontSize', FONT_SIZE+4, ...
    'FontWeight','bold')

%% ================= PANEL 2: OLDER =================

subplot(1,2,2); hold on

h3 = errorbar(x, Oc_mean, Oc_sem, '-o');
h3.Color = COLOR_CTRL;
h3.LineWidth = LINE_WIDTH;
h3.MarkerSize = MARKER_SIZE;
h3.CapSize = CAP_SIZE;
h3.Bar.LineWidth = ERROR_WIDTH;

h4 = errorbar(x, Op_mean, Op_sem, '-o');
h4.Color = COLOR_PERS;
h4.LineWidth = LINE_WIDTH;
h4.MarkerSize = MARKER_SIZE;
h4.CapSize = CAP_SIZE;
h4.Bar.LineWidth = ERROR_WIDTH;

xline(2,'k:','LineWidth',1);
xline(8,'k:','LineWidth',1);

xticks(x)
xticklabels(labels)
xtickangle(0)

xlim([0 10])
ylim(Y_LIM)

title('Older','FontName',FONT_NAME,'FontSize',FONT_SIZE,'FontWeight', 'normal')
xlabel('TEBC Block','FontName',FONT_NAME,'FontSize',FONT_SIZE)
ylabel('% conditioned responding','FontName',FONT_NAME,'FontSize',FONT_SIZE)

set(gca,'FontName',FONT_NAME,...
        'FontSize',FONT_SIZE,...
        'LineWidth',AXIS_WIDTH)

box off

legend({sprintf('Control (n = %d)', n_Oc), ...
        sprintf('Personalised (n = %d)', n_Op)}, ...
        'FontName', FONT_NAME, ...
        'FontSize', FONT_SIZE-1, ...
        'Location', 'northwest');

text(-0.15, 1.05, 'B', ...
    'Units','normalized', ...
    'FontName', FONT_NAME, ...
    'FontSize', FONT_SIZE+4, ...
    'FontWeight','bold')

exportgraphics(gcf, 'CR.png', 'Resolution', 600)