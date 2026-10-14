%% ============================================================
% TEBC Acquisition Figure (Final 45 Subjects)
%% ============================================================
clear all;
close all;
clc;


load('C:\MyTemp\Personalised TEBC (2024-2025)\CR\CR_all.mat')
load('C:\MyTemp\Personalised TEBC (2024-2025)\CR\CR_tables_strict.mat');
savepath = 'C:\MyTemp\Personalised TEBC (2024-2025)\figures\CR\';

%% ================= KEEP ONLY INCLUDED SUBJECTS =================

fprintf('\n');
fprintf('Young kept : %d\n',sum(keepY));
fprintf('Older kept : %d\n',sum(keepO));
fprintf('Total kept : %d\n\n',sum(keepY)+sum(keepO));

%% ================= UPDATE CR =================
CR_y = CR(CR(:,8)==1,:);
CR_o = CR(CR(:,8)==2,:);

CR_y = CR_y(keepY,:);
CR_o = CR_o(keepO,:);

%% ================= SPLIT GROUPS =================

Y_ctrl = Young(:,CR_y(:,9)==1);
Y_pers = Young(:,CR_y(:,9)==2);

O_ctrl = Older(:,CR_o(:,9)==1);
O_pers = Older(:,CR_o(:,9)==2);

fprintf('Young Control      : %d\n',size(Y_ctrl,2));
fprintf('Young Personalised : %d\n',size(Y_pers,2));
fprintf('Older Control      : %d\n',size(O_ctrl,2));
fprintf('Older Personalised : %d\n\n',size(O_pers,2));

%% ================= FIGURE SETTINGS =================

FONT_NAME   = 'Arial';
FONT_SIZE   = 18;
LINE_WIDTH  = 2;
MARKER_SIZE = 7;
CAP_SIZE    = 6;

COLOR_CTRL = [0 0 0];
COLOR_PERS = [1 0 0];

YLIM = [0 80];

main_bins = {
    1:5
    6:15
    16:25
    26:35
    36:45
    46:55
    56:60};

labels = {'CS alone','1','2','3','4','5','EXT'};
x = 1:7;

%% ================= COMPUTE FUNCTION =================

calc = @(X) deal( ...
    cellfun(@(b) mean(100*sum(X(b,:)==1,1)./sum(X(b,:)~=-1,1)), main_bins), ...
    cellfun(@(b) std(100*sum(X(b,:)==1,1)./sum(X(b,:)~=-1,1))/sqrt(size(X,2)), main_bins));

[Yc_mean,Yc_sem] = calc(Y_ctrl);
[Yp_mean,Yp_sem] = calc(Y_pers);

[Oc_mean,Oc_sem] = calc(O_ctrl);
[Op_mean,Op_sem] = calc(O_pers);

%% ============================================================
%% YOUNG
%% ============================================================

figure('Color','w','Position',[200 200 650 400]); hold on

errorbar(x,Yc_mean,Yc_sem,'-o',...
    'Color',COLOR_CTRL,...
    'LineWidth',LINE_WIDTH,...
    'MarkerSize',MARKER_SIZE,...
    'CapSize',CAP_SIZE);

errorbar(x,Yp_mean,Yp_sem,'-o',...
    'Color',COLOR_PERS,...
    'LineWidth',LINE_WIDTH,...
    'MarkerSize',MARKER_SIZE,...
    'CapSize',CAP_SIZE);

xline(1.5,'k:')
xline(6.5,'k:')

xticks(x)
xtickangle(0)
xticklabels(labels)

xlabel('TEBC block')
ylabel('% Conditioned responses')

ylim(YLIM)
xlim([0.8 7.2])

legend({sprintf('Control (n=%d)',size(Y_ctrl,2)),...
        sprintf('Personalised (n=%d)',size(Y_pers,2))},...
        'Location','northwest');

set(gca,...
    'FontName',FONT_NAME,...
    'FontSize',FONT_SIZE,...
    'LineWidth',1.2)

box off

% exportgraphics(gcf,fullfile(savepath,'Young_strict.png'),'Resolution',600)
%% ============================================================
%% OLDER
%% ============================================================

figure('Color','w','Position',[200 200 650 400]); hold on

errorbar(x,Oc_mean,Oc_sem,'-o',...
    'Color',COLOR_CTRL,...
    'LineWidth',LINE_WIDTH,...
    'MarkerSize',MARKER_SIZE,...
    'CapSize',CAP_SIZE);

errorbar(x,Op_mean,Op_sem,'-o',...
    'Color',COLOR_PERS,...
    'LineWidth',LINE_WIDTH,...
    'MarkerSize',MARKER_SIZE,...
    'CapSize',CAP_SIZE);

xline(1.5,'k:')
xline(6.5,'k:')

xticks(x)
xtickangle(0)
xticklabels(labels)

xlabel('TEBC block')
ylabel('% Conditioned responses')

ylim(YLIM)
xlim([0.8 7.2])

legend({sprintf('Control (n=%d)',size(O_ctrl,2)),...
        sprintf('Personalised (n=%d)',size(O_pers,2))},...
        'Location','northwest');

set(gca,...
    'FontName',FONT_NAME,...
    'FontSize',FONT_SIZE,...
    'LineWidth',1.2)

box off
% exportgraphics(gcf,fullfile(savepath,'Older_strict.png'),'Resolution',600)