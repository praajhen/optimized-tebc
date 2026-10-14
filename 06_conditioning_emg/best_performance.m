%before this run CR_estimation.m code


%% ================= COMBINED BEST PERFORMANCE (SPACED YOUNG vs OLDER) =================

Best_Y_P = Best_Young(isY_P);
Best_Y_C = Best_Young(isY_C);

Best_O_P = Best_Older(isO_P);
Best_O_C = Best_Older(isO_C);

figure('Color','w','Position',[300 300 520 460]); hold on

jitter = 0.06;
delta  = 0.18;   % << spacing between Young and Older

xP = 1;   % Personalised center
xC = 2;   % Control center

% ---- X positions ----
xP_Y = xP - delta;   % Personalised – Young
xP_O = xP + delta;   % Personalised – Older

xC_Y = xC - delta;   % Control – Young
xC_O = xC + delta;   % Control – Older

% ---- Scatter: Young (red triangles) ----
plot(xP_Y + (rand(size(Best_Y_P))-0.5)*jitter, Best_Y_P, ...
     '^', 'Color','r', 'MarkerFaceColor','r', 'MarkerSize',7);

plot(xC_Y + (rand(size(Best_Y_C))-0.5)*jitter, Best_Y_C, ...
     '^', 'Color','r', 'MarkerFaceColor','r', 'MarkerSize',7);

% ---- Scatter: Older (black circles) ----
plot(xP_O + (rand(size(Best_O_P))-0.5)*jitter, Best_O_P, ...
     'o', 'Color','k', 'MarkerFaceColor','k', 'MarkerSize',7);

plot(xC_O + (rand(size(Best_O_C))-0.5)*jitter, Best_O_C, ...
     'o', 'Color','k', 'MarkerFaceColor','k', 'MarkerSize',7);

% ---- Means + SEMs ----
mean_Y_P = mean(Best_Y_P,'omitnan');
sem_Y_P  = std(Best_Y_P,'omitnan') / sqrt(sum(~isnan(Best_Y_P)));

mean_Y_C = mean(Best_Y_C,'omitnan');
sem_Y_C  = std(Best_Y_C,'omitnan') / sqrt(sum(~isnan(Best_Y_C)));

mean_O_P = mean(Best_O_P,'omitnan');
sem_O_P  = std(Best_O_P,'omitnan') / sqrt(sum(~isnan(Best_O_P)));

mean_O_C = mean(Best_O_C,'omitnan');
sem_O_C  = std(Best_O_C,'omitnan') / sqrt(sum(~isnan(Best_O_C)));

% ---- Errorbars (aligned with their group x positions) ----
errorbar(xP_Y, mean_Y_P, sem_Y_P, 'r', 'LineWidth',2, 'CapSize',12);
errorbar(xC_Y, mean_Y_C, sem_Y_C, 'r', 'LineWidth',2, 'CapSize',12);

errorbar(xP_O, mean_O_P, sem_O_P, 'k', 'LineWidth',2, 'CapSize',12);
errorbar(xC_O, mean_O_C, sem_O_C, 'k', 'LineWidth',2, 'CapSize',12);

%% ---- Axes & labels ----
xlim([0.5 2.5]);
ylim([0 100]);

xticks([1 2]);
xticklabels({'Personalised','Control'});

ylabel('Best Performance (CR %)');
title('Best Conditioned Responding (Blocks 3–5)');

box off;

%% ---- Legend (age only) ----
hY = plot(nan,nan,'^','Color','r','MarkerFaceColor','r','MarkerSize',8);
hO = plot(nan,nan,'o','Color','k','MarkerFaceColor','k','MarkerSize',8);

legend([hY hO], {'Young','Older'}, 'Location','northwest');



%% ================= 2×2 ANOVA: BEST PERFORMANCE (BLOCKS 3–5) =================

% ---- Combine data into long format ----
Yvals = [Best_Y_P(:); Best_Y_C(:); Best_O_P(:); Best_O_C(:)];

Age = [ ...
    repmat({'Young'}, numel(Best_Y_P), 1); ...
    repmat({'Young'}, numel(Best_Y_C), 1); ...
    repmat({'Older'}, numel(Best_O_P), 1); ...
    repmat({'Older'}, numel(Best_O_C), 1)];

Condition = [ ...
    repmat({'Personalised'}, numel(Best_Y_P), 1); ...
    repmat({'Control'},      numel(Best_Y_C), 1); ...
    repmat({'Personalised'}, numel(Best_O_P), 1); ...
    repmat({'Control'},      numel(Best_O_C), 1)];

T = table(Yvals, Age, Condition, ...
    'VariableNames', {'BestCR','Age','Condition'});

% ---- Remove rows with NaNs ----
T = T(~isnan(T.BestCR), :);

fprintf('\n===== 2×2 ANOVA: Best Performance (Blocks 3–5) =====\n');
disp(T(1:min(10,height(T)),:));   % preview first rows

%% ---- Run two-way ANOVA (Type II style via anovan) ----
[p, tbl, stats] = anovan(T.BestCR, {T.Age, T.Condition}, ...
    'model', 'interaction', ...
    'varnames', {'Age','Condition'}, ...
    'display', 'off');

% tbl format:
% Source | SS | df | MS | F | Prob>F

% ---- Extract values ----
SS_age  = tbl{2,2};   df_age  = tbl{2,3};   F_age  = tbl{2,5};   p_age  = tbl{2,6};
SS_cond = tbl{3,2};   df_cond = tbl{3,3};   F_cond = tbl{3,5};   p_cond = tbl{3,6};
SS_int  = tbl{4,2};   df_int  = tbl{4,3};   F_int  = tbl{4,5};   p_int  = tbl{4,6};
SS_err  = tbl{5,2};   df_err  = tbl{5,3};

% ---- Partial eta squared ----
eta2_age  = SS_age  / (SS_age  + SS_err);
eta2_cond = SS_cond / (SS_cond + SS_err);
eta2_int  = SS_int  / (SS_int  + SS_err);

%% ---- Print clean ANOVA report ----
fprintf('\n--- Two-way ANOVA on Best Performance (Blocks 3–5) ---\n');

fprintf('Main effect of Age:\n');
fprintf('  F(%d, %d) = %.2f, p = %.4f, partial eta^2 = %.3f\n', ...
    df_age, df_err, F_age, p_age, eta2_age);

fprintf('Main effect of Condition:\n');
fprintf('  F(%d, %d) = %.2f, p = %.4f, partial eta^2 = %.3f\n', ...
    df_cond, df_err, F_cond, p_cond, eta2_cond);

fprintf('Age × Condition interaction:\n');
fprintf('  F(%d, %d) = %.2f, p = %.4f, partial eta^2 = %.3f\n', ...
    df_int, df_err, F_int, p_int, eta2_int);
