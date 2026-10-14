clear; clc; close all;

load('C:\TEBC_project\intermediate_files\TF_results\TF_metrics.mat');   % contains TF_metrics
load('C:\TEBC_project\intermediate_files\TEBC_compositie value.mat');        % contains variable a (60x1)

ERP = a(:);

vars = {'ITCmean','EVOKEDmean','INDUCEDmean'};

for i = 1:length(vars)

    X = TF_metrics.(vars{i});

    good = ~isnan(X) & ~isnan(ERP);

    x = X(good);
    y = ERP(good);

    [r,p] = corr(x,y,'type','Pearson');

    fprintf('\n=============================\n');
    fprintf('%s\n',vars{i});
    fprintf('r = %.3f\n',r);
    fprintf('p = %.4f\n',p);

    figure('Color','w');
    scatter(x,y,70,'filled'); hold on
    lsline
    xlabel(vars{i})
    ylabel('TEBC N1-P2 Composite')
    title(sprintf('%s : r=%.3f p=%.4f',vars{i},r,p))
    grid on

end


%%
% 1) Separate correlations: Young / Older
% 2) Multiple regression controlling Age
% 3) Standardized beta weights

clear; clc; close all;

%% ========================================================================
% LOAD DATA
%% ========================================================================
load('C:\TEBC_project\intermediate_files\TF_results\TF_metrics.mat');   % contains TF_metrics
load('C:\TEBC_project\intermediate_files\TEBC_compositie value.mat');        % contains variable a (60x1)

TF_metrics.N1P2 = a(:);

%% ========================================================================
% AGE LABELS
%% ========================================================================
Age   = categorical(TF_metrics.AgeLabel);
Group = categorical(TF_metrics.GroupLabel);

%% ========================================================================
% VARIABLES
%% ========================================================================
vars = {'ITCmean','EVOKEDmean','INDUCEDmean'};

%% ========================================================================
% PART 1: SEPARATE CORRELATIONS BY AGE
%% ========================================================================
for v = 1:length(vars)

    varname = vars{v};

    fprintf('\n====================================================\n');
    fprintf('%s\n',varname);
    fprintf('====================================================\n');

    for g = 1:2

        if g==1
            idx = Age=="Young";
            label = 'Young';
        else
            idx = Age=="Older";
            label = 'Older';
        end

        x = TF_metrics.(varname)(idx);
        y = TF_metrics.N1P2(idx);

        good = ~isnan(x) & ~isnan(y);

        x = x(good);
        y = y(good);

        [r,p] = corr(x,y,'type','Pearson');

        fprintf('%s: r = %.3f, p = %.4f\n',label,r,p);

        %% Scatter
        figure('Color','w','Position',[100 100 550 450]);
        scatter(x,y,70,'filled'); hold on
        lsline
        xlabel(varname)
        ylabel('TEBC N1-P2 Composite')
        title(sprintf('%s | %s : r=%.3f p=%.4f',label,varname,r,p))
        grid on

    end
end

%% ========================================================================
% PART 2: MULTIPLE REGRESSION
% N1P2 ~ ITC + EVOKED + INDUCED + Age
%% ========================================================================

disp('====================================================')
disp('MULTIPLE REGRESSION')
disp('====================================================')

tbl = table;

tbl.N1P2     = TF_metrics.N1P2;
tbl.ITC      = TF_metrics.ITCmean;
tbl.EVOKED   = TF_metrics.EVOKEDmean;
tbl.INDUCED  = TF_metrics.INDUCEDmean;
tbl.Age      = categorical(TF_metrics.AgeLabel);

mdl = fitlm(tbl,'N1P2 ~ ITC + EVOKED + INDUCED + Age');

disp(mdl)
disp(anova(mdl,'summary'))

%% ========================================================================
% PART 3: STANDARDIZED BETAS
%% ========================================================================

disp('====================================================')
disp('STANDARDIZED MODEL')
disp('====================================================')

zN1P2    = zscore(tbl.N1P2);
zITC     = zscore(tbl.ITC);
zEVOKED  = zscore(tbl.EVOKED);
zINDUCED = zscore(tbl.INDUCED);

tbl2 = table;
tbl2.N1P2    = zN1P2;
tbl2.ITC     = zITC;
tbl2.EVOKED  = zEVOKED;
tbl2.INDUCED = zINDUCED;
tbl2.Age     = tbl.Age;

mdl2 = fitlm(tbl2,'N1P2 ~ ITC + EVOKED + INDUCED + Age');

disp(mdl2)

%% ========================================================================
% OPTIONAL SIMPLE BAR OF BETAS
%% ========================================================================
coef = mdl2.Coefficients.Estimate(2:end-1); % skip intercept + one age dummy
names = mdl2.CoefficientNames(2:end-1);

figure('Color','w');
bar(coef)
xticklabels(names)
ylabel('Standardized Beta')
title('Predictors of TEBC N1-P2 Composite')
grid on