clear; clc;

load ('C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\CardioResp_N1P2_allSubjects.mat');  % table: best

%% ================= remove CONTROL =================
isControl = best.ConditionGroup == 1;

phaseData = best(~isControl,:);

%% ================= counts =================
phase = categorical(phaseData.Condition);

counts = countcats(phase);
labels = categories(phase);

disp(table(labels,counts))

%% ================= Chi-square uniform =================
expected = mean(counts)*ones(size(counts));

chi2 = sum((counts-expected).^2 ./ expected);
df = length(counts)-1;
p = 1-chi2cdf(chi2,df);

fprintf('\nPhase distribution test\n')
fprintf('Chi2(%d) = %.3f, p = %.4f\n',df,chi2,p)

%% ================= AgeGroup × Phase =================

tbl = crosstab(phaseData.AgeGroup, phase);

disp('AgeGroup × Phase table:')
disp(tbl)

% Chi-square manually
expected = sum(tbl,2) * sum(tbl,1) / sum(tbl(:));

chi2 = sum((tbl - expected).^2 ./ expected,'all');
df = (size(tbl,1)-1)*(size(tbl,2)-1);

p = 1 - chi2cdf(chi2, df);

fprintf('\nAgeGroup x Phase\n')
fprintf('Chi2(%d) = %.3f, p = %.4f\n',df,chi2,p)