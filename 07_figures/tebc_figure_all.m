%% ============================================================
%   TEBC Acquisition Figure
%% ============================================================

clear; clc;

%% ============================================================
% LOAD DATA
%% ============================================================

load('C:\TEBC_project\CR\CR_all.mat')
load('C:\TEBC_project\CR\CR_table_young.mat')
load('C:\TEBC_project\CR\CR_table_older.mat')

savepath = 'C:\TEBC_project\figures\CR\';

%% ================= STYLE =================

FONT_NAME   = 'Arial';
FONT_SIZE   = 18;
AXIS_WIDTH  = 1.2;
LINE_WIDTH  = 2;
MARKER_SIZE = 7;
CAP_SIZE    = 6;

COLOR_CTRL  = [0 0 0];
COLOR_PERS  = [1 0 0];

Y_LIM = [0 80];

%% ============================================================
% REMOVE EXCLUDED SUBJECTS
%
% CR already contains ONLY the final included 56 subjects.
% Remove the same excluded participants from the CR tables so
% the column order matches CR.
%% ============================================================

% young_remove = {'PL25_TEBC','PL41_TEBC'};
% older_remove = {'PLe11_TEBC','PLe13_TEBC'};
% 
% CR_table_young(:,young_remove) = [];
% CR_table_older(:,older_remove) = [];

%% ============================================================
% QUALITY CHECK
%% ============================================================

fprintf('\n');
fprintf('Young table : %d subjects\n',width(CR_table_young));
fprintf('Older table : %d subjects\n',width(CR_table_older));

%% ============================================================
% CONVERT TABLES TO MATRICES
%% ============================================================

CR_table_young = table2array(CR_table_young);
CR_table_older = table2array(CR_table_older);

%% ============================================================
% DEFINE GROUPS FROM CR
%% ============================================================

young_idx = CR(:,8)==1;
older_idx = CR(:,8)==2;

control = CR(:,9)==1;
personalised = CR(:,9)==2;

young_control = control(young_idx);
young_pers    = personalised(young_idx);

older_control = control(older_idx);
older_pers    = personalised(older_idx);

%% ============================================================
% SPLIT TABLES
%% ============================================================

Y_ctrl = CR_table_young(:,young_control);
Y_pers = CR_table_young(:,young_pers);

O_ctrl = CR_table_older(:,older_control);
O_pers = CR_table_older(:,older_pers);

%% ============================================================
% SAMPLE SIZE CHECK
%% ============================================================

fprintf('\n');
fprintf('Young Control       : %d\n',size(Y_ctrl,2));
fprintf('Young Personalised  : %d\n',size(Y_pers,2));
fprintf('Older Control       : %d\n',size(O_ctrl,2));
fprintf('Older Personalised  : %d\n',size(O_pers,2));



%% ================= MAIN BINS =================

main_bins = {
    1:5
    6:15
    16:25
    26:35
    36:45
    46:55
    56:60
};

labels_main = {'CS alone','1','2','3','4','5','EXT'};
x_main = 1:7;

%% ================= INSET BINS =================

inset_bins = {
    6:7
    8:9
    10:11
    12:13
    14:15
};

labels_inset = {'1–2','3–4','5–6','7–8','9–10'};
x_inset = 1:5;

%% ================= GROUP INDEX =================

young_idx = CR(:,8)==1;
older_idx = CR(:,8)==2;

control = CR(:,9)==1;
personalised = CR(:,9)==2;

young_control = control(young_idx);
young_pers    = personalised(young_idx);

older_control = control(older_idx);
older_pers    = personalised(older_idx);

%% ================= SPLIT =================

Y_ctrl = CR_table_young(:, young_control);
Y_pers = CR_table_young(:, young_pers);

O_ctrl = CR_table_older(:, older_control);
O_pers = CR_table_older(:, older_pers);

%% ================= COMPUTE =================

compute = @(tbl,bins) deal( ...
    cellfun(@(b) mean(tbl(b,:)==1,'all')*100 , bins), ...
    cellfun(@(b) std(mean(tbl(b,:)==1,1))*100/sqrt(size(tbl,2)) , bins) ...
    );

[Yc_mean, Yc_sem] = compute(Y_ctrl, main_bins);
[Yp_mean, Yp_sem] = compute(Y_pers, main_bins);

[Oc_mean, Oc_sem] = compute(O_ctrl, main_bins);
[Op_mean, Op_sem] = compute(O_pers, main_bins);

[Yc_i_mean, Yc_i_sem] = compute(Y_ctrl, inset_bins);
[Yp_i_mean, Yp_i_sem] = compute(Y_pers, inset_bins);

[Oc_i_mean, Oc_i_sem] = compute(O_ctrl, inset_bins);
[Op_i_mean, Op_i_sem] = compute(O_pers, inset_bins);

%% ================= SAMPLE SIZE =================

n_Yc = size(Y_ctrl,2);
n_Yp = size(Y_pers,2);

n_Oc = size(O_ctrl,2);
n_Op = size(O_pers,2);

%% ============================================================
%% YOUNG MAIN
%% ============================================================

figure('Color','w','Position',[200 200 650 400]); hold on

errorbar(x_main,Yc_mean,Yc_sem,'-o','Color',COLOR_CTRL,...
    'LineWidth',LINE_WIDTH,'MarkerSize',MARKER_SIZE,'CapSize',CAP_SIZE)

errorbar(x_main,Yp_mean,Yp_sem,'-o','Color',COLOR_PERS,...
    'LineWidth',LINE_WIDTH,'MarkerSize',MARKER_SIZE,'CapSize',CAP_SIZE)

xline(1.5,'k:')
xline(6.5,'k:')

xticks(x_main)
xticklabels(labels_main)

ylim(Y_LIM)
xlim([0.8 7.2])
xtickangle(0)

xlabel('TEBC block')
ylabel('% conditioned responding')

legend({sprintf('Control (n=%d)',n_Yc),...
        sprintf('Personalised (n=%d)',n_Yp)},...
        'Location','northwest')

set(gca,'FontName',FONT_NAME,'FontSize',FONT_SIZE,'LineWidth',AXIS_WIDTH)
box off

% exportgraphics(gcf,fullfile(savepath,'Young_main_all.png'),'Resolution',300)


%% ============================================================
%% OLDER MAIN
%% ============================================================

figure('Color','w','Position',[200 200 650 400]); hold on

errorbar(x_main,Oc_mean,Oc_sem,'-o','Color',COLOR_CTRL,...
    'LineWidth',LINE_WIDTH,'MarkerSize',MARKER_SIZE,'CapSize',CAP_SIZE)

errorbar(x_main,Op_mean,Op_sem,'-o','Color',COLOR_PERS,...
    'LineWidth',LINE_WIDTH,'MarkerSize',MARKER_SIZE,'CapSize',CAP_SIZE)

xline(1.5,'k:')
xline(6.5,'k:')

xticks(x_main)
xticklabels(labels_main)
xtickangle(0)

ylim(Y_LIM)
xlim([0.8 7.2])

xlabel('TEBC block')
ylabel('% conditioned responding')

legend({sprintf('Control (n=%d)',n_Oc),...
        sprintf('Personalised (n=%d)',n_Op)},...
        'Location','northwest')

set(gca,'FontName',FONT_NAME,'FontSize',FONT_SIZE,'LineWidth',AXIS_WIDTH)
box off

% exportgraphics(gcf,fullfile(savepath,'Older_main_all.png'),'Resolution',300)