%% ========================================================================
% STAGE 3A
% PART 1
% LOAD DATA + EXCLUDE PARTICIPANTS
%% ========================================================================

clear; clc; close all;

%% ========================================================================
% PATH
%% ========================================================================

folder = ...
'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\TF_results';

cd(folder)

%% ========================================================================
% LOAD DATA
%% ========================================================================

load('TF_metrics.mat')

fprintf('\n=========================================================\n');
fprintf('STAGE 3A : DESCRIPTIVE STATISTICS + ANOVA\n');
fprintf('=========================================================\n');

fprintf('\nLoaded TF_metrics.mat\n');

fprintf('Subjects before exclusion : %d\n',height(TF_metrics));

%% ========================================================================
% EXCLUDED SUBJECTS
%% ========================================================================

ExcludedSubjects = { ...
    'PL25'
    'PL41'
    'PLe11'
    'PLe13'
    };

fprintf('\nExcluded participants:\n');

disp(ExcludedSubjects)

%% ========================================================================
% REMOVE SUBJECTS
%% ========================================================================

idxExclude = ismember(TF_metrics.Subject,ExcludedSubjects);

ExcludedTable = TF_metrics(idxExclude,:);

TF = TF_metrics(~idxExclude,:);

%% ========================================================================
% SUMMARY
%% ========================================================================

fprintf('\n=========================================================\n');

fprintf('Original sample : %d\n',height(TF_metrics));

fprintf('Excluded        : %d\n',sum(idxExclude));

fprintf('Final sample    : %d\n',height(TF));

fprintf('=========================================================\n');

%% ========================================================================
% SHOW EXCLUDED SUBJECTS
%% ========================================================================

disp(' ')

disp('Excluded subjects')

disp(ExcludedTable(:,{'Subject','AgeLabel','GroupLabel'}))

%% ========================================================================
% GROUP COUNTS
%% ========================================================================

disp(' ')

disp('Participants remaining')

disp(groupsummary(TF,{'AgeLabel','GroupLabel'}))

%% ========================================================================
% CHECK
%% ========================================================================

assert(height(TF)==56,'ERROR: Final sample should be 56.')

disp(' ')

disp('✓ Participant exclusion successful.')


%% ========================================================================
% PART 2
% DESCRIPTIVE STATISTICS
%% ========================================================================

fprintf('\n');
fprintf('=========================================================\n');
fprintf('PART 2 : DESCRIPTIVE STATISTICS\n');
fprintf('=========================================================\n');

%% ========================================================================
% GROUP DEFINITIONS
%% ========================================================================

YC = strcmp(TF.AgeLabel,'Young') & strcmp(TF.GroupLabel,'Control');
YP = strcmp(TF.AgeLabel,'Young') & strcmp(TF.GroupLabel,'Personalised');

OC = strcmp(TF.AgeLabel,'Older') & strcmp(TF.GroupLabel,'Control');
OP = strcmp(TF.AgeLabel,'Older') & strcmp(TF.GroupLabel,'Personalised');

%% ========================================================================
% SAMPLE SIZE
%% ========================================================================

fprintf('\nSample size\n');

fprintf('Young Control      : %2d\n',sum(YC));
fprintf('Young Personalised : %2d\n',sum(YP));
fprintf('Older Control      : %2d\n',sum(OC));
fprintf('Older Personalised : %2d\n',sum(OP));

%% ========================================================================
% HELPER FUNCTION
%% ========================================================================

calcStats = @(x) [ ...
    numel(x), ...
    mean(x,'omitnan'), ...
    std(x,'omitnan'), ...
    std(x,'omitnan')/sqrt(numel(x)) ];

%% ========================================================================
% ITC
%% ========================================================================

ITCstats = [
    calcStats(TF.ITCmean(YC));
    calcStats(TF.ITCmean(YP));
    calcStats(TF.ITCmean(OC));
    calcStats(TF.ITCmean(OP));
];

ITCtable = array2table(ITCstats,...
    'VariableNames',{'N','Mean','SD','SEM'},...
    'RowNames',{'Young_Control',...
                'Young_Personalised',...
                'Older_Control',...
                'Older_Personalised'});

disp(' ')
disp('ITC')
disp(ITCtable)

%% ========================================================================
% INDUCED POWER
%% ========================================================================

INDstats = [
    calcStats(TF.INDUCEDmean(YC));
    calcStats(TF.INDUCEDmean(YP));
    calcStats(TF.INDUCEDmean(OC));
    calcStats(TF.INDUCEDmean(OP));
];

INDtable = array2table(INDstats,...
    'VariableNames',{'N','Mean','SD','SEM'},...
    'RowNames',{'Young_Control',...
                'Young_Personalised',...
                'Older_Control',...
                'Older_Personalised'});

disp(' ')
disp('INDUCED POWER')
disp(INDtable)

%% ========================================================================
% PERCENTAGE CHANGE
%% ========================================================================

Young_ITC = ...
100*(ITCtable.Mean(2)-ITCtable.Mean(1))/ITCtable.Mean(1);

Older_ITC = ...
100*(ITCtable.Mean(4)-ITCtable.Mean(3))/ITCtable.Mean(3);

Young_IND = ...
100*(INDtable.Mean(2)-INDtable.Mean(1))/INDtable.Mean(1);

Older_IND = ...
100*(INDtable.Mean(4)-INDtable.Mean(3))/INDtable.Mean(3);

fprintf('\n');
fprintf('=========================================================\n');
fprintf('PERCENTAGE CHANGE (Personalised vs Control)\n');
fprintf('=========================================================\n');

fprintf('Young ITC              : %6.2f %%\n',Young_ITC);
fprintf('Older ITC              : %6.2f %%\n',Older_ITC);

fprintf('\n');

fprintf('Young Induced Power    : %6.2f %%\n',Young_IND);
fprintf('Older Induced Power    : %6.2f %%\n',Older_IND);

fprintf('=========================================================\n');

%% ========================================================================
% PART 3
% TWO-WAY ANOVA : ITC
%% ========================================================================

fprintf('\n');
fprintf('=========================================================\n');
fprintf('PART 3 : TWO-WAY ANOVA (ITC)\n');
fprintf('=========================================================\n');

%% ========================================================================
% PREPARE VARIABLES
%% ========================================================================

Y = TF.ITCmean;

Age = categorical(TF.AgeLabel);

Group = categorical(TF.GroupLabel);

%% ========================================================================
% TWO-WAY ANOVA
%% ========================================================================

[p,tbl,stats] = anovan( ...
    Y,...
    {Age Group},...
    'model',2,...
    'varnames',{'Age','Group'},...
    'display','on');

%% ========================================================================
% PRINT ANOVA TABLE
%% ========================================================================

disp(' ')
disp('ANOVA TABLE')
disp(tbl)

%% ========================================================================
% EFFECT SIZE (Partial Eta Squared)
%% ========================================================================

SS_age   = cell2mat(tbl(2,2));
SS_group = cell2mat(tbl(3,2));
SS_int   = cell2mat(tbl(4,2));
SS_error = cell2mat(tbl(5,2));

eta_age   = SS_age   /(SS_age   + SS_error);
eta_group = SS_group /(SS_group + SS_error);
eta_int   = SS_int   /(SS_int   + SS_error);

fprintf('\n');
fprintf('Partial Eta Squared\n');
fprintf('-------------------\n');

fprintf('Age         : %.3f\n',eta_age);
fprintf('Group       : %.3f\n',eta_group);
fprintf('Interaction : %.3f\n',eta_int);

%% ========================================================================
% FOLLOW-UP T TESTS
%% ========================================================================

fprintf('\n');
fprintf('=========================================================\n');
fprintf('POST HOC COMPARISONS (ITC)\n');
fprintf('=========================================================\n');

%% Young

[~,pY,~,statsY] = ttest2( ...
    TF.ITCmean(YC),...
    TF.ITCmean(YP));

fprintf('\nYoung\n');
fprintf('t(%d) = %.3f\n',statsY.df,statsY.tstat);
fprintf('p      = %.4f\n',pY);

%% Older

[~,pO,~,statsO] = ttest2( ...
    TF.ITCmean(OC),...
    TF.ITCmean(OP));

fprintf('\nOlder\n');
fprintf('t(%d) = %.3f\n',statsO.df,statsO.tstat);
fprintf('p      = %.4f\n',pO);

%% ========================================================================
% COHEN'S d
%% ========================================================================

cohend = @(x,y) ...
    (mean(y)-mean(x))/ ...
    sqrt(((length(x)-1)*var(x)+(length(y)-1)*var(y))/ ...
    (length(x)+length(y)-2));

dYoung = cohend(TF.ITCmean(YC),TF.ITCmean(YP));
dOlder = cohend(TF.ITCmean(OC),TF.ITCmean(OP));

fprintf('\n');
fprintf('Cohen''s d\n');

fprintf('Young : %.3f\n',dYoung);
fprintf('Older : %.3f\n',dOlder);

%% ========================================================================
% MANUSCRIPT SUMMARY
%% ========================================================================

fprintf('\n');
fprintf('=========================================================\n');
fprintf('MANUSCRIPT SUMMARY (ITC)\n');
fprintf('=========================================================\n');

fprintf('Main effect of Age         : p = %.4f\n',p(1));
fprintf('Main effect of Group       : p = %.4f\n',p(2));
fprintf('Age x Group interaction    : p = %.4f\n',p(3));

fprintf('\n');

fprintf('Young Control vs Personalised : p = %.4f\n',pY);
fprintf('Older Control vs Personalised : p = %.4f\n',pO);

fprintf('=========================================================\n');


%% ========================================================================
% PART 4
% TWO-WAY ANOVA : INDUCED POWER
%% ========================================================================

fprintf('\n');
fprintf('=========================================================\n');
fprintf('PART 4 : TWO-WAY ANOVA (INDUCED POWER)\n');
fprintf('=========================================================\n');

%% ========================================================================
% PREPARE VARIABLES
%% ========================================================================

Y = TF.INDUCEDmean;

Age = categorical(TF.AgeLabel);
Group = categorical(TF.GroupLabel);

%% ========================================================================
% TWO-WAY ANOVA
%% ========================================================================

[p,tbl,stats] = anovan( ...
    Y,...
    {Age Group},...
    'model',2,...
    'varnames',{'Age','Group'},...
    'display','on');

%% ========================================================================
% PRINT ANOVA TABLE
%% ========================================================================

disp(' ')
disp('ANOVA TABLE')
disp(tbl)

%% ========================================================================
% EFFECT SIZE (Partial Eta Squared)
%% ========================================================================

SS_age   = cell2mat(tbl(2,2));
SS_group = cell2mat(tbl(3,2));
SS_int   = cell2mat(tbl(4,2));
SS_error = cell2mat(tbl(5,2));

eta_age   = SS_age   /(SS_age   + SS_error);
eta_group = SS_group /(SS_group + SS_error);
eta_int   = SS_int   /(SS_int   + SS_error);

fprintf('\n');
fprintf('Partial Eta Squared\n');
fprintf('-------------------\n');

fprintf('Age         : %.3f\n',eta_age);
fprintf('Group       : %.3f\n',eta_group);
fprintf('Interaction : %.3f\n',eta_int);

%% ========================================================================
% FOLLOW-UP T TESTS
%% ========================================================================

fprintf('\n');
fprintf('=========================================================\n');
fprintf('POST HOC COMPARISONS (INDUCED POWER)\n');
fprintf('=========================================================\n');

%% Young

[~,pY,~,statsY] = ttest2( ...
    TF.INDUCEDmean(YC),...
    TF.INDUCEDmean(YP));

fprintf('\nYoung\n');
fprintf('t(%d) = %.3f\n',statsY.df,statsY.tstat);
fprintf('p      = %.4f\n',pY);

%% Older

[~,pO,~,statsO] = ttest2( ...
    TF.INDUCEDmean(OC),...
    TF.INDUCEDmean(OP));

fprintf('\nOlder\n');
fprintf('t(%d) = %.3f\n',statsO.df,statsO.tstat);
fprintf('p      = %.4f\n',pO);

%% ========================================================================
% COHEN'S d
%% ========================================================================

cohend = @(x,y) ...
    (mean(y)-mean(x))/ ...
    sqrt(((length(x)-1)*var(x)+(length(y)-1)*var(y))/ ...
    (length(x)+length(y)-2));

dYoung = cohend(TF.INDUCEDmean(YC),TF.INDUCEDmean(YP));
dOlder = cohend(TF.INDUCEDmean(OC),TF.INDUCEDmean(OP));

fprintf('\n');
fprintf('Cohen''s d\n');

fprintf('Young : %.3f\n',dYoung);
fprintf('Older : %.3f\n',dOlder);

%% ========================================================================
% MANUSCRIPT SUMMARY
%% ========================================================================

fprintf('\n');
fprintf('=========================================================\n');
fprintf('MANUSCRIPT SUMMARY (INDUCED POWER)\n');
fprintf('=========================================================\n');

fprintf('Main effect of Age         : p = %.4f\n',p(1));
fprintf('Main effect of Group       : p = %.4f\n',p(2));
fprintf('Age x Group interaction    : p = %.4f\n',p(3));

fprintf('\n');

fprintf('Young Control vs Personalised : p = %.4f\n',pY);
fprintf('Older Control vs Personalised : p = %.4f\n',pO);

fprintf('\n');

fprintf('Partial Eta Squared\n');
fprintf('Age         : %.3f\n',eta_age);
fprintf('Group       : %.3f\n',eta_group);
fprintf('Interaction : %.3f\n',eta_int);

fprintf('=========================================================\n');

%% ========================================================================
% PART 5
% CORRELATION ANALYSIS
%% ========================================================================

fprintf('\n');
fprintf('=========================================================\n');
fprintf('PART 5 : CORRELATION ANALYSIS\n');
fprintf('=========================================================\n');

%% ========================================================================
% LOAD N1-P2
%% ========================================================================

load('C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\TEBC_compositie value.mat');   % variable = a

Amp = a(~idxExclude);

%% ========================================================================
% AGE NUMERIC
%% ========================================================================

AgeNum = double(strcmp(TF.AgeLabel,'Older'));

%% ========================================================================
% VARIABLES
%% ========================================================================

VarNames = { ...
    'N1P2 vs ITC'
    'N1P2 vs Induced'
    'Age vs ITC'
    'Age vs Induced'};

X = {
    Amp
    Amp
    AgeNum
    AgeNum};

Y = {
    TF.ITCmean
    TF.INDUCEDmean
    TF.ITCmean
    TF.INDUCEDmean};

%% ========================================================================
% LOOP
%% ========================================================================

fprintf('\n');

for k = 1:length(VarNames)

    [r,p] = corr(X{k},Y{k}, ...
        'Rows','complete', ...
        'Type','Pearson');

    fprintf('%-20s   r = %6.3f   p = %.4f\n', ...
        VarNames{k},r,p);

end

%% ========================================================================
% SCATTER FIGURES
%% ========================================================================

figure('Color','w','Position',[100 100 1000 800])

subplot(2,2,1)

scatter(Amp,TF.ITCmean,70,'filled')
lsline
grid on
xlabel('Composite N1-P2')
ylabel('ITC')
title('N1-P2 vs ITC')

subplot(2,2,2)

scatter(Amp,TF.INDUCEDmean,70,'filled')
lsline
grid on
xlabel('Composite N1-P2')
ylabel('Induced Power')
title('N1-P2 vs Induced')

subplot(2,2,3)

scatter(AgeNum,TF.ITCmean,70,'filled')
lsline
grid on
xlabel('Age (0=Young,1=Older)')
ylabel('ITC')
title('Age vs ITC')

subplot(2,2,4)

scatter(AgeNum,TF.INDUCEDmean,70,'filled')
lsline
grid on
xlabel('Age (0=Young,1=Older)')
ylabel('Induced Power')
title('Age vs Induced')

sgtitle('Correlation Analysis')

%% ========================================================================
% PART 6
% MULTIPLE REGRESSION
%
% N1P2 ~ ITC + Induced
%% ========================================================================

fprintf('\n');
fprintf('=========================================================\n');
fprintf('PART 6 : MULTIPLE REGRESSION\n');
fprintf('=========================================================\n');

%% ========================================================================
% BUILD TABLE
%% ========================================================================

tbl = table;

tbl.N1P2 = Amp;
tbl.ITC = TF.ITCmean;
tbl.Induced = TF.INDUCEDmean;

%% ========================================================================
% FIT MODEL
%% ========================================================================

mdl = fitlm(tbl,'N1P2 ~ ITC + Induced');

disp(mdl)

%% ========================================================================
% ANOVA
%% ========================================================================

disp(' ')
disp('Regression ANOVA')

anovaTbl = anova(mdl,'summary');

disp(anovaTbl)

%% ========================================================================
% MODEL SUMMARY
%% ========================================================================

fprintf('\n');
fprintf('Model Summary\n');
fprintf('-------------\n');

fprintf('R²          : %.3f\n',mdl.Rsquared.Ordinary);
fprintf('Adjusted R² : %.3f\n',mdl.Rsquared.Adjusted);


fprintf('Model p = %.6f\n',mdl.ModelFitVsNullModel.Pvalue);

%% ========================================================================
% COEFFICIENT TABLE
%% ========================================================================

disp(' ')
disp('Regression Coefficients')

disp(mdl.Coefficients)

%% ========================================================================
% STANDARDIZED BETAS
%% ========================================================================

tblZ = table;

tblZ.N1P2 = zscore(tbl.N1P2);
tblZ.ITC = zscore(tbl.ITC);
tblZ.Induced = zscore(tbl.Induced);

mdlZ = fitlm(tblZ,'N1P2 ~ ITC + Induced');

disp(' ')
disp('Standardized Betas')

disp(mdlZ.Coefficients)

%% ========================================================================
% PREDICTED VALUES
%% ========================================================================

Pred = predict(mdl,tbl);

[r,p] = corr(tbl.N1P2,Pred);

fprintf('\n');
fprintf('Observed vs Predicted\n');
fprintf('---------------------\n');

fprintf('r = %.3f\n',r);
fprintf('p = %.6f\n',p);

%% ========================================================================
% FIGURE
%% ========================================================================

figure('Color','w','Position',[100 100 650 550])

scatter(tbl.N1P2,Pred,80,'filled')

hold on

mn = min([tbl.N1P2;Pred]);
mx = max([tbl.N1P2;Pred]);

plot([mn mx],[mn mx],'k--','LineWidth',2)

grid on

xlabel('Observed N1-P2')
ylabel('Predicted N1-P2')

title('Multiple Regression')

txt = sprintf('R^2 = %.2f\nr = %.2f', ...
    mdl.Rsquared.Ordinary,r);

text(mn+0.05*(mx-mn),...
     mx-0.15*(mx-mn),...
     txt,...
     'FontSize',12,...
     'BackgroundColor','w')

%% ========================================================================
% MANUSCRIPT SUMMARY
%% ========================================================================

fprintf('\n');
fprintf('=========================================================\n');
fprintf('MANUSCRIPT SUMMARY\n');
fprintf('=========================================================\n');

fprintf('Regression\n');

fprintf('R² = %.3f\n',mdl.Rsquared.Ordinary);

fprintf('Adjusted R² = %.3f\n',mdl.Rsquared.Adjusted);

fprintf('F = %.3f\n',mdl.ModelFitVsNullModel.Fstat);

fprintf('Model p = %.6f\n',mdl.ModelFitVsNullModel.Pvalue);

disp(' ')

disp(mdl.Coefficients)

fprintf('=========================================================\n');