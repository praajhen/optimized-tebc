clear
clc

T = readtable('C:\TEBC_project\intermediate_files\SplitHalfReliability_1.xlsx');

states = {'EXP-DIA','EXP-SYS','INS-DIA','INS-SYS'};

figure('Color','w','Position',[100 100 1200 900])

for s = 1:4

    switch s

        case 1
            x = T.EXP_DIA_H1;
            y = T.EXP_DIA_H2;

        case 2
            x = T.EXP_SYS_H1;
            y = T.EXP_SYS_H2;

        case 3
            x = T.INS_DIA_H1;
            y = T.INS_DIA_H2;

        case 4
            x = T.INS_SYS_H1;
            y = T.INS_SYS_H2;

    end

    subplot(2,2,s)

    scatter(x,y,70,'filled')

    hold on

    lsline

    [r,p] = corr(x,y,'Type','Pearson');

    title(sprintf('%s',states{s}))
    xlabel('Half 1')
    ylabel('Half 2')

    grid on

    text(min(x),max(y),...
        sprintf('r = %.3f\np = %.4f',r,p),...
        'FontWeight','bold')

    fprintf('\n%s\n',states{s});
    fprintf('r = %.3f\n',r);
    fprintf('p = %.5f\n',p);

end

x = [
T.EXP_DIA_H1
T.EXP_SYS_H1
T.INS_DIA_H1
T.INS_SYS_H1];
y = [
T.EXP_DIA_H2
T.EXP_SYS_H2
T.INS_DIA_H2
T.INS_SYS_H2];
[r,p] = corr(x,y);
figure
scatter(x,y,50,'filled')
lsline
xlabel('Half 1')
ylabel('Half 2')
title(sprintf('All physiological states\nr = %.3f   p = %.5f',r,p))



%% =====================================================
% SPLIT-HALF OPTIMAL STATE AGREEMENT - ALL 60
%% =====================================================

T = readtable( ...
    'C:\TEBC_project\intermediate_files\SplitHalfReliability_1.xlsx');

% Amplitudes for the four states
H1 = [T.EXP_DIA_H1, T.EXP_SYS_H1, T.INS_DIA_H1, T.INS_SYS_H1];
H2 = [T.EXP_DIA_H2, T.EXP_SYS_H2, T.INS_DIA_H2, T.INS_SYS_H2];

% Winner in each half
[~,winnerH1] = max(H1,[],2);
[~,winnerH2] = max(H2,[],2);

% Agreement
match = winnerH1 == winnerH2;

nTotal = numel(match);
nMatch = sum(match);
nMismatch = sum(~match);

fprintf('\n=============================================\n');
fprintf('SPLIT-HALF OPTIMAL STATE AGREEMENT\n');
fprintf('=============================================\n');

fprintf('Total participants : %d\n',nTotal);
fprintf('Same state         : %d (%.1f%%)\n',nMatch,100*nMatch/nTotal);
fprintf('Different state    : %d (%.1f%%)\n',nMismatch,100*nMismatch/nTotal);


%% Cohen's kappa

C = confusionmat(winnerH1,winnerH2);

N = sum(C(:));

Po = trace(C)/N;

rowTotals = sum(C,2);
colTotals = sum(C,1);

Pe = sum(rowTotals .* colTotals')/N^2;

kappa = (Po-Pe)/(1-Pe);

fprintf('Cohen''s kappa = %.3f\n',kappa);