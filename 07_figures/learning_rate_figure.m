%% ============================================================
%   Figure: Age vs Learning & Performance
%% ============================================================

clear; clc;
load('C:\MyTemp\Personalised TEBC (2024-2025)\CR\CR_60s.mat') % learners only


%% ================= STYLE SETTINGS =================

FONT_NAME   = 'Arial';
FONT_SIZE   = 14;
AXIS_WIDTH  = 1.2;
LINE_WIDTH  = 2;
MARKER_SIZE = 7;

COLOR_YOUNG = [0 0 0];      % black
COLOR_OLDER = [1 0 0];      % red

Y_LIM_LR    = [0 55];
Y_LIM_BP    = [0 110];


%% ================= DATA =================

learning_rate    = CR(:,10);
best_performance = CR(:,11);

age_group = CR(:,8);   % 1 = young, 2 = older
age       = CR(:,12);  % age in years

young = age_group == 1;
older = age_group == 2;


%% ================= FIGURE =================

figure('Color','w','Position',[200 200 900 420])


%% ============================================================
%% PANEL A — AGE vs PEAK PERFORMANCE
%% ============================================================

subplot(1,2,1); hold on

% scatter
scatter(age(young), best_performance(young), MARKER_SIZE^2, ...
    'o','MarkerEdgeColor', COLOR_YOUNG,...
    'MarkerFaceColor','none','LineWidth',1.2)

scatter(age(older), best_performance(older), MARKER_SIZE^2, ...
    '^','MarkerEdgeColor', COLOR_OLDER,...
    'MarkerFaceColor','none','LineWidth',1.2)

% regression
p = polyfit(age, best_performance,1);
xfit = linspace(min(age), max(age), 100);
yfit = polyval(p,xfit);
plot(xfit, yfit, 'Color',[0.5 0.5 0.5], 'LineWidth',1.5)

% correlation
[r,pval] = corr(age, best_performance,'rows','complete');

if pval < 0.001
    ptxt = 'p < 0.001';
else
    ptxt = sprintf('p = %.3f',pval);
end

text(0.98,0.05,sprintf('r = %.2f, %s',r,ptxt),...
    'Units','normalized',...
    'HorizontalAlignment','right',...
    'VerticalAlignment','bottom',...
    'FontSize', FONT_SIZE,...
    'FontName', FONT_NAME)

%% -------- Mean ± SEM --------

meanY = mean(best_performance(young));
semY  = std(best_performance(young))/sqrt(sum(young));

meanO = mean(best_performance(older));
semO  = std(best_performance(older))/sqrt(sum(older));

xY = mean(age(young));
xO = mean(age(older));

% young (RED)
plot([xY xY],[meanY-semY meanY+semY], ...
    'Color',COLOR_OLDER,'LineWidth',1.2)

plot(xY, meanY,'_', ...
    'Color',COLOR_OLDER,'MarkerSize',18,'LineWidth',2)

% older (BLACK)
plot([xO xO],[meanO-semO meanO+semO], ...
    'Color',COLOR_YOUNG,'LineWidth',1.2)

plot(xO, meanO,'_', ...
    'Color',COLOR_YOUNG,'MarkerSize',18,'LineWidth',2)


xlabel('Age (years)')
ylabel('Peak performance (% CR)')
title('Age vs. peak performance','FontWeight','normal')

xlim([15 80])
ylim(Y_LIM_BP)

set(gca,'FontName',FONT_NAME,'FontSize',FONT_SIZE,'LineWidth',AXIS_WIDTH)
box off

text(-0.15,1.05,'A','Units','normalized',...
    'FontSize',FONT_SIZE+2,'FontWeight','bold')


%% ============================================================
%% PANEL B — AGE vs LEARNING RATE
%% ============================================================

subplot(1,2,2); hold on

scatter(age(young), learning_rate(young), MARKER_SIZE^2, ...
    'o','MarkerEdgeColor', COLOR_YOUNG,...
    'MarkerFaceColor','none','LineWidth',1.2)

scatter(age(older), learning_rate(older), MARKER_SIZE^2, ...
    '^','MarkerEdgeColor', COLOR_OLDER,...
    'MarkerFaceColor','none','LineWidth',1.2)

% regression
p = polyfit(age, learning_rate,1);
xfit = linspace(min(age), max(age), 100);
yfit = polyval(p,xfit);

plot(xfit, yfit, 'Color',[0.5 0.5 0.5], 'LineWidth',1.5)

% correlation
[r,pval] = corr(age, learning_rate,'rows','complete');

if pval < 0.001
    ptxt = 'p < 0.001';
else
    ptxt = sprintf('p = %.3f',pval);
end

text(0.98,0.05,sprintf('r = %.2f, %s',r,ptxt),...
    'Units','normalized',...
    'HorizontalAlignment','right',...
    'VerticalAlignment','bottom',...
    'FontSize', FONT_SIZE,...
    'FontName', FONT_NAME)

%% -------- Mean ± SEM --------

meanY = mean(learning_rate(young));
semY  = std(learning_rate(young))/sqrt(sum(young));

meanO = mean(learning_rate(older));
semO  = std(learning_rate(older))/sqrt(sum(older));

xY = mean(age(young));
xO = mean(age(older));

% young (RED)
plot([xY xY],[meanY-semY meanY+semY], ...
    'Color',COLOR_OLDER,'LineWidth',1.2)

plot(xY, meanY,'_', ...
    'Color',COLOR_OLDER,'MarkerSize',18,'LineWidth',2)

% older (BLACK)
plot([xO xO],[meanO-semO meanO+semO], ...
    'Color',COLOR_YOUNG,'LineWidth',1.2)

plot(xO, meanO,'_', ...
    'Color',COLOR_YOUNG,'MarkerSize',18,'LineWidth',2)

xlabel('Age (years)')
ylabel('Trial to 5th CR')
title('Age vs. learning rate','FontWeight','normal')

xlim([15 80])
ylim(Y_LIM_LR)

set(gca,'FontName',FONT_NAME,'FontSize',FONT_SIZE,'LineWidth',AXIS_WIDTH)
box off

text(-0.15,1.05,'B','Units','normalized',...
    'FontSize',FONT_SIZE+2,'FontWeight','bold')


%% ================= SAVE =================

exportgraphics(gcf,'learning_rate.png','Resolution',600)


%% if you want as separate figure use below code.
figure('Color','w','Position',[200 200 500 400]); hold on

% scatter
scatter(age(young), best_performance(young), MARKER_SIZE^2, ...
    'o','MarkerEdgeColor', COLOR_YOUNG,...
    'MarkerFaceColor','none','LineWidth',1.2)

scatter(age(older), best_performance(older), MARKER_SIZE^2, ...
    '^','MarkerEdgeColor', COLOR_OLDER,...
    'MarkerFaceColor','none','LineWidth',1.2)

% regression
p = polyfit(age, best_performance,1);
xfit = linspace(min(age), max(age), 100);
yfit = polyval(p,xfit);
plot(xfit, yfit, 'Color',[0.5 0.5 0.5], 'LineWidth',1.5)

% correlation
[r,pval] = corr(age, best_performance,'rows','complete');

if pval < 0.001
    ptxt = 'p < 0.001';
else
    ptxt = sprintf('p = %.3f',pval);
end

text(0.98,0.05,sprintf('r = %.2f, %s',r,ptxt),...
    'Units','normalized',...
    'HorizontalAlignment','right',...
    'VerticalAlignment','bottom',...
    'FontSize', FONT_SIZE,...
    'FontName', FONT_NAME)

% Mean ± SEM
meanY = mean(best_performance(young));
semY  = std(best_performance(young))/sqrt(sum(young));

meanO = mean(best_performance(older));
semO  = std(best_performance(older))/sqrt(sum(older));

xY = mean(age(young));
xO = mean(age(older));

plot([xY xY],[meanY-semY meanY+semY], 'Color',COLOR_OLDER,'LineWidth',1.2)
plot(xY, meanY,'_', 'Color',COLOR_OLDER,'MarkerSize',18,'LineWidth',2)

plot([xO xO],[meanO-semO meanO+semO], 'Color',COLOR_YOUNG,'LineWidth',1.2)
plot(xO, meanO,'_', 'Color',COLOR_YOUNG,'MarkerSize',18,'LineWidth',2)

xlabel('Age (years)')
ylabel('Peak performance (% CR)')
% title('Age vs. peak performance','FontWeight','normal')

xlim([15 80])
ylim(Y_LIM_BP)

set(gca,'FontName',FONT_NAME,'FontSize',FONT_SIZE,'LineWidth',AXIS_WIDTH)
box off

exportgraphics(gcf,'peak_performance.png','Resolution',600)



%%
figure('Color','w','Position',[200 200 500 400]); hold on

scatter(age(young), learning_rate(young), MARKER_SIZE^2, ...
    'o','MarkerEdgeColor', COLOR_YOUNG,...
    'MarkerFaceColor','none','LineWidth',1.2)

scatter(age(older), learning_rate(older), MARKER_SIZE^2, ...
    '^','MarkerEdgeColor', COLOR_OLDER,...
    'MarkerFaceColor','none','LineWidth',1.2)

% regression
p = polyfit(age, learning_rate,1);
xfit = linspace(min(age), max(age), 100);
yfit = polyval(p,xfit);
plot(xfit, yfit, 'Color',[0.5 0.5 0.5], 'LineWidth',1.5)

% correlation
[r,pval] = corr(age, learning_rate,'rows','complete');

if pval < 0.001
    ptxt = 'p < 0.001';
else
    ptxt = sprintf('p = %.3f',pval);
end

text(0.98,0.05,sprintf('r = %.2f, %s',r,ptxt),...
    'Units','normalized',...
    'HorizontalAlignment','right',...
    'VerticalAlignment','bottom',...
    'FontSize', FONT_SIZE,...
    'FontName', FONT_NAME)

% Mean ± SEM
meanY = mean(learning_rate(young));
semY  = std(learning_rate(young))/sqrt(sum(young));

meanO = mean(learning_rate(older));
semO  = std(learning_rate(older))/sqrt(sum(older));

xY = mean(age(young));
xO = mean(age(older));

plot([xY xY],[meanY-semY meanY+semY], 'Color',COLOR_OLDER,'LineWidth',1.2)
plot(xY, meanY,'_', 'Color',COLOR_OLDER,'MarkerSize',18,'LineWidth',2)

plot([xO xO],[meanO-semO meanO+semO], 'Color',COLOR_YOUNG,'LineWidth',1.2)
plot(xO, meanO,'_', 'Color',COLOR_YOUNG,'MarkerSize',18,'LineWidth',2)

xlabel('Age (years)')
ylabel('Trial to 5th CR')
% title('Age vs. learning rate','FontWeight','normal')

xlim([15 80])
ylim(Y_LIM_LR)

set(gca,'FontName',FONT_NAME,'FontSize',FONT_SIZE,'LineWidth',AXIS_WIDTH)
box off

exportgraphics(gcf,'learning_rate.png','Resolution',600)