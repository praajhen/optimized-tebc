%% ================= Figure: Representative subject (PL14_A) =================
clear; clc; close all;

addpath('C:\MyTemp\Personalised TEBC (2024-2025)\matlab_code');
addpath('C:\MyTemp\fieldtrip-20251218');
ft_defaults;

fontName = 'Arial';
fontSize = 14;
lineW = 1.8;

%% ---------------------- Load subject ----------------------
subj = 'PL14_A';

resp_file = fullfile('C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\trials\resp',[subj '.mat']);
ecg_file  = fullfile('C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\trials\ecg',[subj '.mat']);

load(resp_file); resp_bins = binMatrices;
load(ecg_file);  ecg_bins  = binMatrices;

%% ---------------------- Match trials ----------------------
ins_sys={}; ins_dia={}; exp_sys={}; exp_dia={};

for i=1:length(ecg_bins{1,1})
for j=1:length(resp_bins{1,1})
if isequal(ecg_bins{1,1}{i},resp_bins{1,1}{j})
ins_sys{end+1,1}=ecg_bins{1,1}{i};
end
end
end

for i=1:length(ecg_bins{1,2})
for j=1:length(resp_bins{1,1})
if isequal(ecg_bins{1,2}{i},resp_bins{1,1}{j})
ins_dia{end+1,1}=ecg_bins{1,2}{i};
end
end
end

for i=1:length(ecg_bins{1,1})
for j=1:length(resp_bins{1,2})
if isequal(ecg_bins{1,1}{i},resp_bins{1,2}{j})
exp_sys{end+1,1}=ecg_bins{1,1}{i};
end
end
end

for i=1:length(ecg_bins{1,2})
for j=1:length(resp_bins{1,2})
if isequal(ecg_bins{1,2}{i},resp_bins{1,2}{j})
exp_dia{end+1,1}=ecg_bins{1,2}{i};
end
end
end

%% ---------------------- ERP ----------------------
load('C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\label.mat');

fs=1000;
time = linspace(-200,1000,1200);

make_ft = @(x) struct( ...
'trial',{x},...
'fsample',fs,...
'label',{label},...
'time',{repmat({time/1000},1,length(x))});

cfg=[];
erp = @(x) ft_timelockanalysis(cfg,make_ft(x));

ga1=erp(ins_sys);
ga2=erp(ins_dia);
ga3=erp(exp_sys);
ga4=erp(exp_dia);

%% ---------------------- ROI ----------------------
channels=[6 7 106];

signals{1}=mean(ga1.avg(channels,:),1);
signals{2}=mean(ga2.avg(channels,:),1);
signals{3}=mean(ga3.avg(channels,:),1);
signals{4}=mean(ga4.avg(channels,:),1);

trials_all = {ins_sys, ins_dia, exp_sys, exp_dia};

names={'INS–SYS','INS–DIA','EXP–SYS','EXP–DIA'};
ntr=[length(ins_sys) length(ins_dia) length(exp_sys) length(exp_dia)];

%% ================= Figure =================
figure('Position',[100 50 1000 700])
t = tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

panel={'A','B','C','D'};

for k=1:4

nexttile; hold on

trials = trials_all{k};

%% ---------- MEAN + SEM ----------
nTrials = length(trials);
Y = zeros(nTrials, length(time));

for t = 1:nTrials
    tmp = mean(trials{t}(channels,:),1);
    Y(t,:) = tmp(:)';
end

meanERP = mean(Y,1);
semERP  = std(Y,[],1) ./ sqrt(nTrials);

timeVec = time(:)';

upper = meanERP + semERP;
lower = meanERP - semERP;

fill([timeVec fliplr(timeVec)], ...
     [upper fliplr(lower)], ...
     [0.9 0.9 0.9], ...
     'EdgeColor','none');

plot(timeVec,meanERP,'k','LineWidth',lineW)
xline(0,'--','Color',[.6 .6 .6])

%% ---------- INTERACTIVE PEAK SELECTION ----------
zoom on
disp('Zoom then press any key')
pause
zoom off

disp(['Panel ' panel{k} ' : click a (P1)'])
[ta,a] = ginput(1);

disp('click b (N1)')
[tb,b] = ginput(1);

disp('click c (P2)')
[tc,c] = ginput(1);

amp=((a-b)+(c-b))/2;

%% ---------- plot peaks ----------
plot(ta,a,'ro','MarkerFaceColor','r','MarkerSize',6)
plot(tb,b,'ro','MarkerFaceColor','r','MarkerSize',6)
plot(tc,c,'ro','MarkerFaceColor','r','MarkerSize',6)

text(ta,a,'  a','FontName',fontName,'FontSize',fontSize)
text(tb,b,'  b','FontName',fontName,'FontSize',fontSize)
text(tc,c,'  c','FontName',fontName,'FontSize',fontSize)

%% panel label
text(-350,2,panel{k}, ...
'FontWeight','bold', ...
'FontSize',fontSize+3, ...
'FontName',fontName)

title(sprintf('%s (n=%d)',names{k},ntr(k)), ...
'FontName',fontName,'FontSize',fontSize)

text(550,1.5,sprintf('Amp = %.2f µV',amp), ...
'Color','b','FontName',fontName,'FontSize',fontSize)

xlabel('Time (ms)','FontName',fontName,'FontSize',fontSize)
ylabel('Amplitude (\muV)','FontName',fontName,'FontSize',fontSize)

xlim([-200 1000])
ylim([-3 2])

set(gca,...
'FontName',fontName,...
'FontSize',fontSize,...
'LineWidth',1.2,...
'Box','off')

end

exportgraphics(gcf,'ERP_composite_value.png','Resolution',600)