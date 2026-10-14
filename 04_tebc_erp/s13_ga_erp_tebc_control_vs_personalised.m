clear; clc;

%% ===================== SETUP FIELDTRIP =====================
addpath('C:\toolboxes\fieldtrip-20251218');
ft_defaults;

cd('C:\TEBC_project\intermediate_files\ERP');

%% ===================== ROI ======================
channels = [6 7 106];

%% ===================== SUBJECTS =================
young_personalised_ids = [01 02 03 06 09 11 13 15 17 20 ...
    21 23 24 26 29 30 31 36 37 38 41];

young_control_ids = [04 05 07 08 10 12 14 16 18 19 ...
    22 25 27 28 32 33 34 35 39 40];

older_personalised_ids = [01 03 04 06 09 11 13 14 15 18];
older_control_ids = [02 05 07 08 10 12 16 17 19];

%% ===================== LOAD =====================

load_group = @(ids, prefix) cellfun(@(p) ...
    load(sprintf('%s%02d_TEBC.mat',prefix,p)), ...
    num2cell(ids), 'UniformOutput', false);

yc = load_group(young_control_ids,'PL');
yp = load_group(young_personalised_ids,'PL');
oc = load_group(older_control_ids,'PLe');
op = load_group(older_personalised_ids,'PLe');

extract = @(data,prefix,ids) cellfun(@(d,i) ...
    d.(sprintf('%s%02d_TEBC',prefix,i)), ...
    data, num2cell(ids), 'UniformOutput', false);

TEBC_young_control = extract(yc,'PL',young_control_ids);
TEBC_young_pers    = extract(yp,'PL',young_personalised_ids);
TEBC_older_control = extract(oc,'PLe',older_control_ids);
TEBC_older_pers    = extract(op,'PLe',older_personalised_ids);

%% ===================== GRAND AVERAGE =====================
cfg = []; cfg.keepindividual = 'yes';

ga_yc = ft_timelockgrandaverage(cfg, TEBC_young_control{:});
ga_yp = ft_timelockgrandaverage(cfg, TEBC_young_pers{:});
ga_oc = ft_timelockgrandaverage(cfg, TEBC_older_control{:});
ga_op = ft_timelockgrandaverage(cfg, TEBC_older_pers{:});

%% ===================== ROI =====================
roi = @(ga) squeeze(mean(ga.individual(:,channels,:),2));

yc = roi(ga_yc); yp = roi(ga_yp);
oc = roi(ga_oc); op = roi(ga_op);

mean_yc = mean(yc,1); sem_yc = std(yc)/sqrt(size(yc,1));
mean_yp = mean(yp,1); sem_yp = std(yp)/sqrt(size(yp,1));

mean_oc = mean(oc,1); sem_oc = std(oc)/sqrt(size(oc,1));
mean_op = mean(op,1); sem_op = std(op)/sqrt(size(op,1));

time_ms = ga_yc.time * 1000;

%% ===================== WINDOWS =====================
P1_y = [60 100]; 
P1_o = [50 100]; 
% Young
N1_y = [110 120];
P2_y = [190 210];

% Older
N1_o = [100 110];
P2_o = [185 205];



%% ===================== FIND a, b, c =====================

sig_y = mean_yp;
sig_o = mean_op;

% -------- Young --------
idx = find(time_ms>=40 & time_ms<=110);
[ay, i] = max(sig_y(idx)); ay_t = time_ms(idx(i));

idx = find(time_ms>=105 & time_ms<=125);
[by, i] = min(sig_y(idx)); by_t = time_ms(idx(i));

idx = find(time_ms>=170 & time_ms<=250);
[cy, i] = max(sig_y(idx)); cy_t = time_ms(idx(i));

% -------- Older --------
idx = find(time_ms>=50 & time_ms<=100);
[ao, i] = max(sig_o(idx)); ao_t = time_ms(idx(i));

idx = find(time_ms>=80 & time_ms<=140);
[bo, i] = min(sig_o(idx)); bo_t = time_ms(idx(i));

idx = find(time_ms>=170 & time_ms<=260);
[co, i] = max(sig_o(idx)); co_t = time_ms(idx(i));
%% ===================== PLOT =====================
figure('Units','centimeters','Position',[1 1 29 12]);
tiledlayout(1,2);

%% ---------- YOUNG ----------
nexttile; hold on

fill([time_ms fliplr(time_ms)], [mean_yc+sem_yc fliplr(mean_yc-sem_yc)], ...
    'k','FaceAlpha',0.25,'EdgeColor','none')
fill([time_ms fliplr(time_ms)], [mean_yp+sem_yp fliplr(mean_yp-sem_yp)], ...
    'r','FaceAlpha',0.25,'EdgeColor','none')

plot(time_ms,mean_yc,'k')
plot(time_ms,mean_yp,'r')

xlim([-100 500]); ylim([-8 8])

% shaded windows
yL = ylim;
patch([N1_y(1) N1_y(2) N1_y(2) N1_y(1)],[yL(1) yL(1) yL(2) yL(2)],...
    [0.7 0.7 0.7],'FaceAlpha',0.2,'EdgeColor','none')
patch([P2_y(1) P2_y(2) P2_y(2) P2_y(1)],[yL(1) yL(1) yL(2) yL(2)],...
    [0.7 0.7 0.7],'FaceAlpha',0.2,'EdgeColor','none')

text(mean(N1_y), yL(2)-0.5, 'N1', 'HorizontalAlignment','center', 'FontSize',14)
text(mean(P2_y), yL(2)-0.5, 'P2', 'HorizontalAlignment','center', 'FontSize',14)

h1 = plot(time_ms, mean_yc, 'k');
h2 = plot(time_ms, mean_yp, 'r');
legend([h1 h2], {'Control (n=20)','Personalised (n=21)'},'Location','southeast','Box','off')

% a b c
plot(ay_t,ay,'o','MarkerFaceColor','r','MarkerSize',10, 'MarkerEdgeColor','none','HandleVisibility','off')
plot(by_t,by,'o','MarkerFaceColor','r','MarkerSize',10, 'MarkerEdgeColor','none','HandleVisibility','off')
plot(cy_t,cy,'o','MarkerFaceColor','r','MarkerSize',10, 'MarkerEdgeColor','none','HandleVisibility','off')

offset_y = 0.7 * sign([ay by cy]);   % automatic up/down

text(ay_t+10, ay + offset_y(1), 'a', 'FontSize',18,'FontWeight','bold')
text(by_t+10, by + offset_y(2), 'b', 'FontSize',18,'FontWeight','bold')
text(cy_t+10, cy + offset_y(3), 'c', 'FontSize',18,'FontWeight','bold')

xlabel('Time (ms)'); ylabel('Amplitude (\muV)')
box off

%% ---------- OLDER ----------
nexttile; hold on

fill([time_ms fliplr(time_ms)], [mean_oc+sem_oc fliplr(mean_oc-sem_oc)], ...
    'k','FaceAlpha',0.25,'EdgeColor','none')
fill([time_ms fliplr(time_ms)], [mean_op+sem_op fliplr(mean_op-sem_op)], ...
    'r','FaceAlpha',0.25,'EdgeColor','none')

plot(time_ms,mean_oc,'k')
plot(time_ms,mean_op,'r')

xlim([-100 500]); ylim([-8 8])

yL = ylim;
patch([N1_o(1) N1_o(2) N1_o(2) N1_o(1)],[yL(1) yL(1) yL(2) yL(2)],...
    [0.7 0.7 0.7],'FaceAlpha',0.2,'EdgeColor','none')
patch([P2_o(1) P2_o(2) P2_o(2) P2_o(1)],[yL(1) yL(1) yL(2) yL(2)],...
    [0.7 0.7 0.7],'FaceAlpha',0.2,'EdgeColor','none')
text(mean(N1_o), yL(2)-0.5, 'N1', 'HorizontalAlignment','center', 'FontSize',14)
text(mean(P2_o), yL(2)-0.5, 'P2', 'HorizontalAlignment','center', 'FontSize',14)

h3 = plot(time_ms, mean_oc, 'k');
h4 = plot(time_ms, mean_op, 'r');

legend([h3 h4], {'Control (n=9)','Personalised (n=10)'},'Location','southeast', 'Box','off')

plot(ao_t,ao,'o','MarkerFaceColor','r','MarkerSize',10, 'MarkerEdgeColor','none','HandleVisibility','off')
plot(bo_t,bo,'o','MarkerFaceColor','r','MarkerSize',10, 'MarkerEdgeColor','none','HandleVisibility','off')
plot(co_t,co,'o','MarkerFaceColor','r','MarkerSize',10, 'MarkerEdgeColor','none','HandleVisibility','off')

offset_o = 0.7 * sign([ao bo co]);

text(ao_t+10, ao + offset_o(1), 'a','FontSize',18,'FontWeight','bold')
text(bo_t+10, bo + offset_o(2), 'b','FontSize',18,'FontWeight','bold')
text(co_t+10, co + offset_o(3), 'c','FontSize',18,'FontWeight','bold')

xlabel('Time (ms)')
box off

exportgraphics(gcf,'Figure_ERP.png','Resolution',600);


%% graphical abstract figure

figure('Units','centimeters','Position',[1 1 29 14]);

tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

% ====================== YOUNG ======================
nexttile;
hold on

% ----- SEM shading -----
fill([time_ms fliplr(time_ms)], ...
    [mean_yc+sem_yc fliplr(mean_yc-sem_yc)], ...
    'k', ...
    'FaceAlpha',0.25, ...
    'EdgeColor','none');

fill([time_ms fliplr(time_ms)], ...
    [mean_yp+sem_yp fliplr(mean_yp-sem_yp)], ...
    'r', ...
    'FaceAlpha',0.25, ...
    'EdgeColor','none');

% ----- ERP lines -----
plot(time_ms, mean_yc, ...
    'k', ...
    'LineWidth',2.5);

plot(time_ms, mean_yp, ...
    'r', ...
    'LineWidth',2.5);

xlim([-100 500]);
ylim([-8 8]);

% ----- Significant windows -----
yL = ylim;

patch([N1_y(1) N1_y(2) N1_y(2) N1_y(1)], ...
      [yL(1) yL(1) yL(2) yL(2)], ...
      [0.7 0.7 0.7], ...
      'FaceAlpha',0.2, ...
      'EdgeColor','none');

patch([P2_y(1) P2_y(2) P2_y(2) P2_y(1)], ...
      [yL(1) yL(1) yL(2) yL(2)], ...
      [0.7 0.7 0.7], ...
      'FaceAlpha',0.2, ...
      'EdgeColor','none');
% 
% % ----- Labels -----
% text(mean(N1_y), yL(2)-0.5, 'N1', ...
%     'HorizontalAlignment','center', ...
%     'FontSize',16);
% 
% text(mean(P2_y), yL(2)-0.5, 'P2', ...
%     'HorizontalAlignment','center', ...
%     'FontSize',16);

% ----- Axes labels -----
xlabel('Time (ms)','FontSize',22);
ylabel('Amplitude (\muV)','FontSize',22);

% ----- Title -----
t = title('Young','FontSize',20,'FontWeight','bold');
t.Units = 'normalized';
t.Position(2) = 1.05;

% ----- Axes style -----
set(gca, ...
    'FontSize',20, ...
    'LineWidth',1.5);

box off


% ====================== OLDER ======================
nexttile;
hold on

% ----- SEM shading -----
fill([time_ms fliplr(time_ms)], ...
    [mean_oc+sem_oc fliplr(mean_oc-sem_oc)], ...
    'k', ...
    'FaceAlpha',0.25, ...
    'EdgeColor','none');

fill([time_ms fliplr(time_ms)], ...
    [mean_op+sem_op fliplr(mean_op-sem_op)], ...
    'r', ...
    'FaceAlpha',0.25, ...
    'EdgeColor','none');

% ----- ERP lines -----
plot(time_ms, mean_oc, ...
    'k', ...
    'LineWidth',2.5);

plot(time_ms, mean_op, ...
    'r', ...
    'LineWidth',2.5);

xlim([-100 500]);
ylim([-8 8]);

% ----- Significant windows -----
yL = ylim;

patch([N1_o(1) N1_o(2) N1_o(2) N1_o(1)], ...
      [yL(1) yL(1) yL(2) yL(2)], ...
      [0.7 0.7 0.7], ...
      'FaceAlpha',0.2, ...
      'EdgeColor','none');

patch([P2_o(1) P2_o(2) P2_o(2) P2_o(1)], ...
      [yL(1) yL(1) yL(2) yL(2)], ...
      [0.7 0.7 0.7], ...
      'FaceAlpha',0.2, ...
      'EdgeColor','none');

% ----- Labels -----
% text(mean(N1_o), yL(2)-0.5, 'N1', ...
%     'HorizontalAlignment','center', ...
%     'FontSize',16);
% 
% text(mean(P2_o), yL(2)-0.5, 'P2', ...
%     'HorizontalAlignment','center', ...
%     'FontSize',16);

% ----- Axes labels -----
xlabel('Time (ms)','FontSize',22);

% ----- Title -----
t = title('Older','FontSize',20,'FontWeight','bold');
t.Units = 'normalized';
t.Position(2) = 1.05;

% ----- Axes style -----
set(gca, ...
    'FontSize',18, ...
    'LineWidth',1.5);

box off

% exportgraphics(gcf,'2.png','Resolution',600);