
load('C:\TEBC_project\intermediate_files\CardioResp_N1P2_allSubjects.mat');


% Best state for each participant


subjects = unique(all_result.Subject);

best = table();

for i = 1:numel(subjects)

    T = all_result(strcmp(all_result.Subject,subjects{i}),:);

    [bestAmp,idx] = max(T.Amp);

    best.Subject(i,1)   = subjects(i);
    best.Condition(i,1) = T.Condition(idx);
    best.Amp(i,1)       = bestAmp;
    % Relative maximum (%)
best.RelativeMax(i,1) = bestAmp / mean(T.Amp) * 100;

    % Young = PLxx_A
    % Older = PLexx_A
    best.AgeGroup(i,1) = startsWith(subjects{i},"PLe") + 1;

end

disp(best)


% Overall distribution


fprintf('\n=================================================\n');
fprintf('OVERALL DISTRIBUTION\n');
fprintf('=================================================\n');

overall = groupsummary(best,"Condition");
disp(overall(:,{'Condition','GroupCount'}))


% Mean ± SD


fprintf('\n=================================================\n');
fprintf('MAXIMUM N1-P2 AMPLITUDE\n');
fprintf('=================================================\n');

states = unique(best.Condition);

Summary = table();

for i = 1:numel(states)

    idx = strcmp(best.Condition,states{i});

    Summary.Condition{i,1} = states{i};
    Summary.N(i,1)         = sum(idx);
    Summary.Mean(i,1)      = mean(best.Amp(idx));
    Summary.SD(i,1)        = std(best.Amp(idx));

end

disp(Summary)


% Chi-square goodness-of-fit


Observed = overall.GroupCount;
Expected = repmat(mean(Observed),size(Observed));

chi2 = sum((Observed-Expected).^2 ./ Expected);
df   = numel(Observed)-1;
p    = 1-chi2cdf(chi2,df);

fprintf('\nChi-square goodness-of-fit\n');
fprintf('Chi-square = %.3f\n',chi2);
fprintf('df = %d\n',df);
fprintf('p = %.5f\n',p);


% Young vs Older


young = best(best.AgeGroup==1,:);
older = best(best.AgeGroup==2,:);

fprintf('\n=================================================\n');
fprintf('YOUNG vs OLDER\n');
fprintf('=================================================\n');

counts = zeros(2,numel(states));

for i = 1:numel(states)

    counts(1,i) = sum(strcmp(young.Condition,states{i}));
    counts(2,i) = sum(strcmp(older.Condition,states{i}));

end

disp(array2table(counts,...
    'VariableNames',states,...
    'RowNames',{'Young','Older'}))

%% Chi-square test of independence

rowTot = sum(counts,2);
colTot = sum(counts,1);
grand  = sum(counts(:));

Expected = rowTot*colTot/grand;

chi2 = sum(sum((counts-Expected).^2 ./ Expected));
df   = (size(counts,1)-1)*(size(counts,2)-1);
p    = 1-chi2cdf(chi2,df);

fprintf('\nYoung vs Older\n');
fprintf('Chi-square = %.3f\n',chi2);
fprintf('df = %d\n',df);
fprintf('p = %.5f\n',p);


% Goodness-of-fit within each age group


groups = {young,older};
names  = {'Young','Older'};

for g = 1:2

    fprintf('\n=================================================\n');
    fprintf('%s\n',upper(names{g}));
    fprintf('=================================================\n');

    S = groupsummary(groups{g},"Condition");

    disp(S(:,{'Condition','GroupCount'}))

    Observed = S.GroupCount;
    Expected = repmat(mean(Observed),size(Observed));

    chi2 = sum((Observed-Expected).^2 ./ Expected);
    df   = numel(Observed)-1;
    p    = 1-chi2cdf(chi2,df);

    fprintf('Chi-square = %.3f\n',chi2);
    fprintf('df = %d\n',df);
    fprintf('p = %.5f\n',p);

end


%% ==========================================================
% Relative maximum (%)
%% ==========================================================

fprintf('\n=================================================\n');
fprintf('RELATIVE MAXIMUM (%%)\n');
fprintf('=================================================\n');

young = best(best.AgeGroup==1,:);
older = best(best.AgeGroup==2,:);

fprintf('Young (n=%d): %.2f ± %.2f %%\n', ...
    height(young), ...
    mean(young.RelativeMax), ...
    std(young.RelativeMax));

fprintf('Older (n=%d): %.2f ± %.2f %%\n', ...
    height(older), ...
    mean(older.RelativeMax), ...
    std(older.RelativeMax));

%% Independent t-test

[~,p,~,stats] = ttest2(young.RelativeMax,older.RelativeMax);

fprintf('\nIndependent t-test\n');
fprintf('t(%d) = %.3f\n',stats.df,stats.tstat);
fprintf('p = %.5f\n',p);

%% ==========================================================
% ANOVA: Maximum N1-P2 amplitude across the four states
%% ==========================================================

fprintf('\n=================================================\n');
fprintf('ANOVA: MAXIMUM N1-P2 AMPLITUDE ACROSS STATES\n');
fprintf('=================================================\n');

[p,tbl,stats] = anova1(best.Amp, best.Condition, 'off');

% Display ANOVA table
disp(tbl)

% Extract statistics
F = tbl{2,5};
df1 = tbl{2,3};
df2 = tbl{3,3};
eta2 = tbl{2,2} / tbl{4,2};



fprintf('\nOne-way ANOVA\n');
fprintf('F(%d,%d) = %.3f\n',df1,df2,F);
fprintf('p = %.5f\n',p);
fprintf('Eta squared = %.3f\n',eta2);