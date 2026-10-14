clear
clc
close all

%% ==========================================================
% Load data
%% ==========================================================

load('C:\TEBC_project\intermediate_files\CardioResp_N1P2_allSubjects.mat')

%% ==========================================================
% Create participant-level average across ALL passive-task trials
%% ==========================================================

subjects = unique(all_result.Subject);

N = numel(subjects);

Subject        = cell(N,1);
MeanAmp        = nan(N,1);
AgeGroup       = nan(N,1);
ConditionGroup = nan(N,1);

for i = 1:N

    subj = subjects{i};

    idx = strcmp(all_result.Subject,subj);
    tmp = all_result(idx,:);

    % Weighted average across all trials
    MeanAmp(i) = sum(tmp.Amp .* tmp.Ntrials) ./ sum(tmp.Ntrials);

    Subject{i} = subj;

    idx2 = strcmp(best.Subject,subj);

    AgeGroup(i)       = best.AgeGroup(idx2);
    ConditionGroup(i) = best.ConditionGroup(idx2);

end

overall = table(Subject,MeanAmp,AgeGroup,ConditionGroup);
subjects = unique(all_result.Subject);

best_true = table();

for i = 1:numel(subjects)

    idx = strcmp(all_result.Subject,subjects{i});
    tmp = all_result(idx,:);

    [~,k] = max(tmp.Amp);

    best_true.Subject{i,1}        = subjects{i};
    best_true.Condition{i,1}      = tmp.Condition{k};
    best_true.Amp(i,1)            = tmp.Amp(k);

    idx2 = strcmp(best.Subject,subjects{i});

    best_true.AgeGroup(i,1)       = best.AgeGroup(idx2);
    best_true.ConditionGroup(i,1) = best.ConditionGroup(idx2);

end
%% ==========================================================
% Figure settings
%% ==========================================================

fontName = 'Arial';
fontSize = 16;
lineW    = 1.8;

youngCol = [0 0 0];
olderCol = [0.85 0 0];

offset = 0.18;

figure('Color','w','Position',[100 100 1200 520]);

t = tiledlayout(1,2,'TileSpacing','compact','Padding','loose');

%% ==========================================================
%% PANEL A
%% ==========================================================

nexttile
hold on

states = {'EXP–DIA','EXP–SYS','INS–DIA','INS–SYS'};

for s = 1:4

    %% ---------------- Young ----------------

    idx = best_true.AgeGroup==1 & strcmp(best_true.Condition,states{s});
    y = best_true.Amp(idx);

    x = s-offset + (rand(size(y))-0.5)*0.06;

    scatter(x,y,65,...
        'o',...
        'MarkerEdgeColor',youngCol,...
        'MarkerFaceColor','none',...
        'LineWidth',1.4);

    m   = mean(y);
    sem = std(y)/sqrt(numel(y));

    errorbar(s-offset,m,sem,...
        'Color',youngCol,...
        'LineWidth',lineW,...
        'CapSize',8,...
        'LineStyle','none');

    line([s-offset-0.08 s-offset+0.08],[m m],...
        'Color',youngCol,...
        'LineWidth',3);

    %% ---------------- Older ----------------

    idx = best_true.AgeGroup==2 & strcmp(best_true.Condition,states{s});
    y = best_true.Amp(idx);

    x = s+offset + (rand(size(y))-0.5)*0.06;

    scatter(x,y,65,...
        'o',...
        'MarkerEdgeColor',olderCol,...
        'MarkerFaceColor','none',...
        'LineWidth',1.4);

    m   = mean(y);
    sem = std(y)/sqrt(numel(y));

    errorbar(s+offset,m,sem,...
        'Color',olderCol,...
        'LineWidth',lineW,...
        'CapSize',8,...
        'LineStyle','none');

    line([s+offset-0.08 s+offset+0.08],[m m],...
        'Color',olderCol,...
        'LineWidth',3);

end

xlim([0.5 4.5])
ylim([0 10])

xticks(1:4)
xticklabels(states)
xtickangle(0)

ylabel({'Composite N1-P2';'amplitude (\muV)'},...
    'FontName',fontName,...
    'FontSize',fontSize,...
    'FontWeight','normal')

text(0.03,1,'○ Young',...
    'Units','normalized',...
    'Color',youngCol,...
    'FontWeight','bold',...
    'FontSize',fontSize,...
    'VerticalAlignment','top');

text(0.03,0.94,'○ Older',...
    'Units','normalized',...
    'Color',olderCol,...
    'FontWeight','bold',...
    'FontSize',fontSize,...
    'VerticalAlignment','top');

set(gca,...
    'FontName',fontName,...
    'FontSize',18,...
    'LineWidth',1.2,...
    'TickDir','out',...
    'Box','off');

ax = gca;
ax.Position = [0.16 0.13 0.35 0.80];
%% ==========================================================
%% PANEL B : Overall passive auditory N1-P2 amplitude
%% ==========================================================

nexttile
hold on

groups = {'Control','Personalised'};

for g = 1:2

    %% ---------------- Young ----------------
    idx = overall.ConditionGroup==g & overall.AgeGroup==1;

    y = overall.MeanAmp(idx);

    x = g-offset + (rand(size(y))-0.5)*0.06;

    scatter(x,y,65,...
        'o',...
        'MarkerEdgeColor',youngCol,...
        'MarkerFaceColor','none',...
        'LineWidth',1.4);

    m = mean(y);
    sem = std(y)/sqrt(numel(y));

    errorbar(g-offset,m,sem,...
        'Color',youngCol,...
        'LineWidth',lineW,...
        'CapSize',8,...
        'LineStyle','none');

    line([g-offset-0.08 g-offset+0.08],[m m],...
        'Color',youngCol,...
        'LineWidth',3);

    %% ---------------- Older ----------------
    idx = overall.ConditionGroup==g & overall.AgeGroup==2;

    y = overall.MeanAmp(idx);

    x = g+offset + (rand(size(y))-0.5)*0.06;

    scatter(x,y,65,...
        'o',...
        'MarkerEdgeColor',olderCol,...
        'MarkerFaceColor','none',...
        'LineWidth',1.4);

    m = mean(y);
    sem = std(y)/sqrt(numel(y));

    errorbar(g+offset,m,sem,...
        'Color',olderCol,...
        'LineWidth',lineW,...
        'CapSize',8,...
        'LineStyle','none');

    line([g+offset-0.08 g+offset+0.08],[m m],...
        'Color',olderCol,...
        'LineWidth',3);

end

xlim([0.5 2.5])
ylim([0 10])

xticks(1:2)
xticklabels(groups)

set(gca,...
    'FontName',fontName,...
    'FontSize',18,...
    'LineWidth',1.2,...
    'TickDir','out',...
    'Box','off');

%% ==========================================================
% Save
%% ==========================================================

%% ==========================================================
% Save Panel A
%% ==========================================================

ax = findall(gcf,'Type','axes');
ax = flipud(ax);   % Now ax(1)=Panel A, ax(2)=Panel B

figA = figure('Color','w','Position',[100 100 700 500]);

newAx = copyobj(ax(1),figA);

set(newAx,...
    'Units','normalized',...
    'Position',[0.18 0.16 0.75 0.75]);

% exportgraphics(figA,'n1_p2_distribution_a.png','Resolution',600);

%% ==========================================================
% Save Panel B
%% ==========================================================

figB = figure('Color','w','Position',[100 100 600 500]);

newAx = copyobj(ax(2),figB);

set(newAx,...
    'Units','normalized',...
    'Position',[0.18 0.16 0.75 0.75]);

% exportgraphics(figB,'n1_p2_distribution_b.png','Resolution',600);


% exportgraphics(gcf,'n1_p2_distribution.png','Resolution',600);


%% ==========================================================
% B(i): MAXIMAL N1-P2
% Age × Optimal physiological state
%% ==========================================================

[p,tbl,stats] = anovan( ...
    best_true.Amp, ...
    {best_true.AgeGroup, best_true.Condition}, ...
    'model','interaction', ...
    'varnames',{'Age','State'}, ...
    'display','off');

disp(tbl)


%% ==========================================================
% B(ii): MEAN N1-P2
% Age × Training group
%% ==========================================================

[p,tbl,stats] = anovan( ...
    overall.MeanAmp, ...
    {overall.AgeGroup, overall.ConditionGroup}, ...
    'model','interaction', ...
    'varnames',{'Age','Group'}, ...
    'display','off');

disp(tbl)