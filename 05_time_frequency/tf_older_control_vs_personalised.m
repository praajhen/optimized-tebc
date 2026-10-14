%% ========================================================================
% FINAL CLEAN OLDER FIGURE (PUBLICATION CLEAN)
% Older Control vs Personalised
% ERP + Evoked + ITC + Induced
%
% Uses GA_older.mat
% Clean spectra using PCHIP interpolation (no spline artifacts)
%% ========================================================================

clear; clc; close all;

%% ========================================================================
% PATHS
%% ========================================================================

erp_folder = ...
'C:\TEBC_project\intermediate_files\ERP';

tf_folder = ...
'C:\TEBC_project\intermediate_files\TF_results';

%% ========================================================================
% SUBJECTS
%% ========================================================================

older_personalised_ids = [1 3 4 6 9 11 13 14 15 18];
older_control_ids      = [2 5 7 8 10 12 16 17 19];

roiNames = {'E6','E7','E106'};

%% ========================================================================
% LOAD GA
%% ========================================================================

cd(tf_folder)
load('GA_older.mat')

freq = GA.freq;
time = GA.time * 1000;

%% ========================================================================
% WINDOWS
%% ========================================================================

fmask  = freq >= 4  & freq <= 15;
tmask  = time >= -100 & time <= 400;
spmask = time >= 80 & time <= 250;

ff   = freq(fmask);
tt   = time(tmask);
fnew = 4:0.1:15;

%% ========================================================================
% TF MAPS
%% ========================================================================

EV1 = GA.OC_EV(fmask,tmask);
EV2 = GA.OP_EV(fmask,tmask);

IT1 = GA.OC_ITC(fmask,tmask);
IT2 = GA.OP_ITC(fmask,tmask);

IN1 = GA.OC_IN(fmask,tmask);
IN2 = GA.OP_IN(fmask,tmask);

%% ========================================================================
% RAW SPECTRA
%% ========================================================================

spEV1 = mean(GA.OC_EV(fmask,spmask),2,'omitnan');
spEV2 = mean(GA.OP_EV(fmask,spmask),2,'omitnan');

spIT1 = mean(GA.OC_ITC(fmask,spmask),2,'omitnan');
spIT2 = mean(GA.OP_ITC(fmask,spmask),2,'omitnan');

spIN1 = mean(GA.OC_IN(fmask,spmask),2,'omitnan');
spIN2 = mean(GA.OP_IN(fmask,spmask),2,'omitnan');

%% ========================================================================
% CLEAN SMOOTH SPECTRA (DISPLAY ONLY)
%% ========================================================================

spEV1s = interp1(ff,spEV1,fnew,'pchip');
spEV2s = interp1(ff,spEV2,fnew,'pchip');

spIT1s = interp1(ff,spIT1,fnew,'pchip');
spIT2s = interp1(ff,spIT2,fnew,'pchip');

spIN1s = interp1(ff,spIN1,fnew,'pchip');
spIN2s = interp1(ff,spIN2,fnew,'pchip');

spEV1s = smoothdata(spEV1s,'gaussian',7);
spEV2s = smoothdata(spEV2s,'gaussian',7);

spIT1s = smoothdata(spIT1s,'gaussian',7);
spIT2s = smoothdata(spIT2s,'gaussian',7);

spIN1s = smoothdata(spIN1s,'gaussian',7);
spIN2s = smoothdata(spIN2s,'gaussian',7);

%% ========================================================================
% LOAD ERP
%% ========================================================================

cd(erp_folder)

ERPc = [];
ERPp = [];
time_ms = [];

for s = older_control_ids

    f = sprintf('PLe%02d_TEBC.mat',s);

    if exist(f,'file')

        D = load(f);
        fn = fieldnames(D);
        X  = D.(fn{1});

        if isempty(time_ms)
            time_ms = X.time * 1000;
        end

        ch = find(ismember(X.label,roiNames));
        ERPc(end+1,:) = mean(X.avg(ch,:),1,'omitnan');
    end
end

for s = older_personalised_ids

    f = sprintf('PLe%02d_TEBC.mat',s);

    if exist(f,'file')

        D = load(f);
        fn = fieldnames(D);
        X  = D.(fn{1});

        ch = find(ismember(X.label,roiNames));
        ERPp(end+1,:) = mean(X.avg(ch,:),1,'omitnan');
    end
end

%% ========================================================================
% ERP STATS
%% ========================================================================

m1 = mean(ERPc,1,'omitnan');
m2 = mean(ERPp,1,'omitnan');

s1 = std(ERPc,0,1,'omitnan') ./ sqrt(size(ERPc,1));
s2 = std(ERPp,0,1,'omitnan') ./ sqrt(size(ERPp,1));

pERP = nan(1,length(time_ms));

for i = 1:length(time_ms)
    [~,pERP(i)] = ttest2(ERPc(:,i),ERPp(:,i));
end

sigERP = pERP < 0.05 & time_ms >= 0 & time_ms <= 400;

%% ========================================================================
% LIMITS
%% ========================================================================

erp_ylim = [min([m1-s1 m2-s2])-1 max([m1+s1 m2+s2])+1];

ev_clim = [0 max([EV1(:);EV2(:)])];
it_clim = [0 max([IT1(:);IT2(:)])];
in_clim = [min([IN1(:);IN2(:)]) max([IN1(:);IN2(:)])];

ylEV = [0 max([spEV1s spEV2s])];
ylIT = [0 max([spIT1s spIT2s])];
ylIN = [0 max([spIN1s spIN2s])];

%% ========================================================================
% FIGURE
%% ========================================================================

figure('Color','w','Position',[20 20 1125 3000]);
tiledlayout(7,2,'TileSpacing','compact','Padding','compact');

set(groot,'defaultAxesFontName','Arial')
set(groot,'defaultAxesFontSize',10)

%% ERP
for c = 1:2

nexttile; hold on

if c==1
    m=m1; s=s1; col='k'; ttl='Older Control ERP';
else
    m=m2; s=s2; col='r'; ttl='Older Personalised ERP';
end

fill([time_ms fliplr(time_ms)],...
     [m+s fliplr(m-s)],...
     col,'FaceAlpha',0.18,'EdgeColor','none');

plot(time_ms,m,col,'LineWidth',2)

xline(0,'--','Color',[.4 .4 .4]);
yline(0,':','Color',[.5 .5 .5]);

if c==1
    yy = erp_ylim(2)-0.35;
    plot(time_ms(sigERP),yy*ones(1,sum(sigERP)),'k.','MarkerSize',8)
end

xlim([-100 500])
ylim(erp_ylim)

ylabel('\muV')
title(ttl)
box off
end

%% EVOKED MAPS
for c=1:2
nexttile
if c==1, imagesc(tt,ff,EV1); else, imagesc(tt,ff,EV2); end
axis xy; caxis(ev_clim); xline(0,'--k'); xlim([-100 400])
ylabel('Hz'); title('Evoked Power'); colorbar; box off
end

%% EVOKED SPECTRA
for c=1:2
nexttile; hold on
if c==1, plot(fnew,spEV1s,'k','LineWidth',2);
else,    plot(fnew,spEV2s,'r','LineWidth',2); end
xlim([4 15]); ylim(ylEV)
ylabel('Power'); title('Evoked Spectrum'); box off
end

%% ITC MAPS
for c=1:2
nexttile
if c==1, imagesc(tt,ff,IT1); else, imagesc(tt,ff,IT2); end
axis xy; caxis(it_clim); xline(0,'--k'); xlim([-100 400])
ylabel('Hz'); title('ITC'); colorbar; box off
end

%% ITC SPECTRA
for c=1:2
nexttile; hold on
if c==1, plot(fnew,spIT1s,'k','LineWidth',2);
else,    plot(fnew,spIT2s,'r','LineWidth',2); end
xlim([4 15]); ylim(ylIT)
ylabel('ITC'); title('ITC Spectrum'); box off
end

%% INDUCED MAPS
for c=1:2
nexttile
if c==1, imagesc(tt,ff,IN1); else, imagesc(tt,ff,IN2); end
axis xy; caxis(in_clim); xline(0,'--k'); xlim([-100 400])
ylabel('Hz'); title('Induced Power'); colorbar; box off
end

%% INDUCED SPECTRA
for c=1:2
nexttile; hold on
if c==1, plot(fnew,spIN1s,'k','LineWidth',2);
else,    plot(fnew,spIN2s,'r','LineWidth',2); end
xlim([4 15]); ylim(ylIN)
xlabel('Frequency (Hz)')
ylabel('Power'); title('Induced Spectrum'); box off
end

%% SAVE

sgtitle('Older Control vs Personalised', ...
'FontSize',22,'FontWeight','bold')

% exportgraphics(gcf,'TF_older c vs. p.png','Resolution',600);