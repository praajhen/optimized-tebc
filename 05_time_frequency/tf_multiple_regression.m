%% ========================================================================
% MULTIPLE REGRESSION FIGURE
% Predictors of TEBC N1-P2 Composite
%
% Model:
% N1P2 ~ ITC + EVOKED + INDUCED + Age
%
% Outputs:
% 1) Clean regression summary
% 2) Standardized beta plot
% 3) Predicted vs Observed plot
%% ========================================================================

clear; clc; close all;

%% ========================================================================
% LOAD DATA
%% ========================================================================
load('C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\TF_results\TF_metrics.mat');
load('C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\TEBC_compositie value.mat');

TF_metrics.N1P2 = a(:);

%% ========================================================================
% BUILD TABLE
%% ========================================================================
tbl = table;

tbl.N1P2    = TF_metrics.N1P2;
tbl.ITC     = TF_metrics.ITCmean;
tbl.EVOKED  = TF_metrics.EVOKEDmean;
tbl.INDUCED = TF_metrics.INDUCEDmean;
tbl.Age     = categorical(TF_metrics.AgeLabel);

%% ========================================================================
% REMOVE MISSING
%% ========================================================================
good = ~isnan(tbl.N1P2) & ...
       ~isnan(tbl.ITC) & ...
       ~isnan(tbl.EVOKED) & ...
       ~isnan(tbl.INDUCED);

tbl = tbl(good,:);

%% ========================================================================
% FIT MODEL
%% ========================================================================
mdl = fitlm(tbl,'N1P2 ~ ITC + EVOKED + INDUCED + Age');

disp(mdl)

%% ========================================================================
% STANDARDIZED MODEL
%% ========================================================================
tblZ = table;

tblZ.N1P2    = zscore(tbl.N1P2);
tblZ.ITC     = zscore(tbl.ITC);
tblZ.EVOKED  = zscore(tbl.EVOKED);
tblZ.INDUCED = zscore(tbl.INDUCED);
tblZ.Age     = tbl.Age;

mdlZ = fitlm(tblZ,'N1P2 ~ ITC + EVOKED + INDUCED + Age');

disp(mdlZ)

%% ========================================================================
% EXTRACT BETAS
%% ========================================================================
coefNames = mdlZ.CoefficientNames;
coefVals  = mdlZ.Coefficients.Estimate;
coefP     = mdlZ.Coefficients.pValue;

% keep only predictors of interest
keep = ismember(coefNames,{'ITC','EVOKED','INDUCED'});

names = coefNames(keep);
betas = coefVals(keep);
pvals = coefP(keep);

%% ========================================================================
% FIGURE 1: STANDARDIZED BETAS
%% ========================================================================
figure('Color','w','Position',[100 100 760 520]);

b = bar(betas,0.65,'FaceColor',[0.2 0.5 0.8]);
hold on

yline(0,'k-','LineWidth',1.2)

xticks(1:length(names))
xticklabels(names)

ylabel('Standardized Beta','FontSize',15,'FontWeight','bold')
title('Independent Predictors of TEBC N1-P2', ...
    'FontSize',18,'FontWeight','bold')

grid on
box off
set(gca,'FontSize',13,'LineWidth',1.2)

% add p-values
for i = 1:length(betas)

    txt = sprintf('p=%.3f',pvals(i));

    if betas(i)>=0
        y = betas(i)+0.03;
    else
        y = betas(i)-0.06;
    end

    text(i,y,txt,...
        'HorizontalAlignment','center',...
        'FontSize',11)

end

% R2 text
txt2 = sprintf('R^2 = %.2f',mdl.Rsquared.Ordinary);
text(length(names)-0.2,max(betas)*0.9,txt2,'FontSize',12)

% saveas(gcf,'Regression_Betas.png')

%% ========================================================================
% FIGURE 2: OBSERVED VS PREDICTED
%% ========================================================================
yObs  = tbl.N1P2;
yPred = predict(mdl,tbl);

[r2,p2] = corr(yObs,yPred);

figure('Color','w','Position',[120 120 760 520]); hold on

scatter(yObs,yPred,90,...
    'filled',...
    'MarkerFaceColor',[0 0.45 0.74],...
    'MarkerEdgeColor','k');

% unity line
mn = min([yObs; yPred]);
mx = max([yObs; yPred]);

plot([mn mx],[mn mx],'k--','LineWidth',2)

xlabel('Observed N1-P2 Composite','FontSize',15,'FontWeight','bold')
ylabel('Predicted N1-P2 Composite','FontSize',15,'FontWeight','bold')

title('Regression Model Performance', ...
    'FontSize',18,'FontWeight','bold')

txt = sprintf('r = %.3f\nR^2 = %.2f',r2,mdl.Rsquared.Ordinary);

text(mn+0.05*(mx-mn),mx-0.15*(mx-mn),txt,...
    'FontSize',13,...
    'BackgroundColor','w',...
    'Margin',6)

grid on
box off
set(gca,'FontSize',13,'LineWidth',1.2)

% saveas(gcf,'Regression_Performance.png')

%% ========================================================================
disp('=================================================')
disp('DONE: Regression figures saved')
disp('=================================================')