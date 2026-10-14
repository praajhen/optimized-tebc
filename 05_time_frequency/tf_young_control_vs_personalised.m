%% ========================================================================
% NATURE-STYLE FIGURE (FULLY CORRECTED)
% Young Control vs Personalised
% ERP + Evoked + ITC + Induced
%
% Maps:     4–15 Hz
% Spectra:  5–10 Hz
% Stats:    ERP pointwise only
%% ========================================================================

clear; clc; close all;

%% ========================================================================
% PATHS
%% ========================================================================

erp_folder = ...
'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\ERP';

tf_folder = ...
'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\TF_results';

%% ========================================================================
% SUBJECTS
%% ========================================================================

young_personalised_ids = [01 02 03 06 09 11 13 15 17 20 ...
21 23 24 26 29 30 31 36 37 38 41];

young_control_ids = [04 05 07 08 10 12 14 16 18 19 ...
22 25 27 28 32 33 34 35 39 40];

roiNames = {'E6','E7','E106'};

%% ========================================================================
% LOAD GA
%% ========================================================================

cd(tf_folder)
load('GA.mat');
load('PL01_TEBC_TF.mat','ITC');

freq = ITC.freq;
time = ITC.time * 1000;

%% ========================================================================
% WINDOWS
%% ========================================================================

% Maps
f_tf = freq >= 4 & freq <= 15;
t_tf = time >= -100 & time <= 400;

% Spectra
f_sp = freq >= 5 & freq <= 10;
t_sp = time >= 80 & time <= 250;

ff_tf = freq(f_tf);
ff_sp = freq(f_sp);
tt    = time(t_tf);

%% ========================================================================
% LOAD ERP SUBJECTS
%% ========================================================================

cd(erp_folder)

ERP_ctrl = [];
ERP_pers = [];

for s = young_control_ids
    f = sprintf('PL%02d_TEBC.mat',s);
    if exist(f,'file')
        D = load(f);
        fn = fieldnames(D);
        X = D.(fn{1});
        ch = find(ismember(X.label,roiNames));
        ERP_ctrl(end+1,:) = mean(X.avg(ch,:),1);
    end
end

for s = young_personalised_ids
    f = sprintf('PL%02d_TEBC.mat',s);
    if exist(f,'file')
        D = load(f);
        fn = fieldnames(D);
        X = D.(fn{1});
        ch = find(ismember(X.label,roiNames));
        ERP_pers(end+1,:) = mean(X.avg(ch,:),1);
    end
end

time_ms = X.time * 1000;

m1 = mean(ERP_ctrl,1);
m2 = mean(ERP_pers,1);

sem1 = std(ERP_ctrl,0,1) ./ sqrt(size(ERP_ctrl,1));
sem2 = std(ERP_pers,0,1) ./ sqrt(size(ERP_pers,1));

%% ========================================================================
% ERP SIGNIFICANCE
%% ========================================================================

pERP = nan(1,length(time_ms));

for i = 1:length(time_ms)
    [~,pERP(i)] = ttest2(ERP_ctrl(:,i),ERP_pers(:,i));
end

sigERP = pERP < 0.05 & time_ms >= 0 & time_ms <= 400;

%% ========================================================================
% TF MAPS
%% ========================================================================

EV1 = GA.YC_EV(f_tf,t_tf);
EV2 = GA.YP_EV(f_tf,t_tf);

IT1 = GA.YC_ITC(f_tf,t_tf);
IT2 = GA.YP_ITC(f_tf,t_tf);

IN1 = GA.YC_IN(f_tf,t_tf);
IN2 = GA.YP_IN(f_tf,t_tf);

%% ========================================================================
% SPECTRA
%% ========================================================================

spEV1 = mean(GA.YC_EV(f_sp,t_sp),2,'omitnan');
spEV2 = mean(GA.YP_EV(f_sp,t_sp),2,'omitnan');

spIT1 = mean(GA.YC_ITC(f_sp,t_sp),2,'omitnan');
spIT2 = mean(GA.YP_ITC(f_sp,t_sp),2,'omitnan');

spIN1 = mean(GA.YC_IN(f_sp,t_sp),2,'omitnan');
spIN2 = mean(GA.YP_IN(f_sp,t_sp),2,'omitnan');

%% ========================================================================
% LIMITS
%% ========================================================================

ev_clim = [0 max([EV1(:); EV2(:)])];
it_clim = [0 max([IT1(:); IT2(:)])];
in_clim = [min([IN1(:); IN2(:)]) max([IN1(:); IN2(:)])];

erp_ylim = [min([m1-sem1 m2-sem2])-1 max([m1+sem1 m2+sem2])+1];

%% ========================================================================
% FIGURE
%% ========================================================================

figure('Color','w','Position',[20 20 1125 3000]);
tiledlayout(7,2,'TileSpacing','compact','Padding','compact');

set(groot,'defaultAxesFontName','Arial')
set(groot,'defaultAxesFontSize',10)

%% ========================================================================
% ERP
%% ========================================================================

for c = 1:2

nexttile; hold on

if c==1
    m = m1; s = sem1; col='k'; ttl='Control ERP';
else
    m = m2; s = sem2; col='r'; ttl='Personalised ERP';
end

fill([time_ms fliplr(time_ms)],...
     [m+s fliplr(m-s)],...
     col,'FaceAlpha',0.18,'EdgeColor','none');

plot(time_ms,m,col,'LineWidth',2)

xline(0,'--','Color',[.4 .4 .4]);
yline(0,':','Color',[.5 .5 .5]);

if c==1
    yy = erp_ylim(2)-0.4;
    plot(time_ms(sigERP),yy*ones(1,sum(sigERP)),'k.','MarkerSize',8)
end

xlim([-100 500])
ylim(erp_ylim)

ylabel('\muV')
title(ttl)
box off

end

%% ========================================================================
% EVOKED MAPS
%% ========================================================================

for c=1:2

nexttile

if c==1
    imagesc(tt,ff_tf,EV1)
else
    imagesc(tt,ff_tf,EV2)
end

axis xy
caxis(ev_clim)
xlim([-100 400])

ylabel('Hz')
title('Evoked Power')
colorbar
box off

end

%% ========================================================================
% EVOKED SPECTRUM
%% ========================================================================

for c=1:2

nexttile; hold on

if c==1
    plot(ff_sp,spEV1,'k','LineWidth',2)
else
    plot(ff_sp,spEV2,'r','LineWidth',2)
end

set(gca,'XScale','log')
xticks([5 6 8 10])
xlim([5 10])

ylabel('Mean')
title('Evoked Spectrum')
box off

end

%% ========================================================================
% ITC MAPS
%% ========================================================================

for c=1:2

nexttile

if c==1
    imagesc(tt,ff_tf,IT1)
else
    imagesc(tt,ff_tf,IT2)
end

axis xy
caxis(it_clim)
xlim([-100 400])

ylabel('Hz')
title('ITC')
colorbar
box off

end

%% ========================================================================
% ITC SPECTRUM
%% ========================================================================

for c=1:2

nexttile; hold on

if c==1
    plot(ff_sp,spIT1,'k','LineWidth',2)
else
    plot(ff_sp,spIT2,'r','LineWidth',2)
end

set(gca,'XScale','log')
xticks([5 6 8 10])
xlim([5 10])

ylabel('Mean')
title('ITC Spectrum')
box off

end

%% ========================================================================
% INDUCED MAPS
%% ========================================================================

for c=1:2

nexttile

if c==1
    imagesc(tt,ff_tf,IN1)
else
    imagesc(tt,ff_tf,IN2)
end

axis xy
caxis(in_clim)
xlim([-100 400])

ylabel('Hz')
title('Induced Power')
colorbar
box off

end

%% ========================================================================
% INDUCED SPECTRUM
%% ========================================================================

for c=1:2

nexttile; hold on

if c==1
    plot(ff_sp,spIN1,'k','LineWidth',2)
else
    plot(ff_sp,spIN2,'r','LineWidth',2)
end

set(gca,'XScale','log')
xticks([5 6 8 10])
xlim([5 10])

xlabel('Frequency (Hz)')
ylabel('Mean')
title('Induced Spectrum')
box off

end

sgtitle('Young Control vs Personalised', ...
'FontSize',22,'FontWeight','bold')

exportgraphics(gcf,'TF_young c vs. p.png','Resolution',600);