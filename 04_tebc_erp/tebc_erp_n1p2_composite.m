%% ============================================================
% Interactive composite N1–P2 extraction (TEBC)
%% ============================================================

clear; clc; close all

erp_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\ERP';
files = dir(fullfile(erp_folder,'PL*_TEBC.mat'));

channels = [6 7 106];

nSub = length(files);

results = table( ...
    strings(nSub,1), ...
    zeros(nSub,1), ...
    zeros(nSub,1), ...
    zeros(nSub,1), ...
    zeros(nSub,1), ...
    'VariableNames',{'Subject','a','b','c','Composite'});

figure('Position',[200 100 900 500])

for f = 42: 43 %1:length(files)

    clf

    fname = files(f).name;
    load(fullfile(erp_folder,fname))

    varname = erase(fname,'.mat');
    ERP = eval(varname);

    subj = erase(fname,'_TEBC.mat');

    time = ERP.time * 1000;
    signal = mean(ERP.avg(channels,:),1);

    plot(time,signal,'k','LineWidth',2)
    hold on

    xline(0,'--k')

    %% automatic windows
    winA = [50 120];
    winB = [80 160];
    winC = [150 250];

    idxA = time>=winA(1) & time<=winA(2);
    idxB = time>=winB(1) & time<=winB(2);
    idxC = time>=winC(1) & time<=winC(2);

    [~,ia] = max(signal(idxA));
    [~,ib] = min(signal(idxB));
    [~,ic] = max(signal(idxC));

    tA = time(idxA); tA = tA(ia);
    tB = time(idxB); tB = tB(ib);
    tC = time(idxC); tC = tC(ic);

    a = signal(time==tA);
    b = signal(time==tB);
    c = signal(time==tC);

    plot(tA,a,'ro','MarkerFaceColor','r')
    plot(tB,b,'ro','MarkerFaceColor','r')
    plot(tC,c,'ro','MarkerFaceColor','r')

    text(tA,a,'  a')
    text(tB,b,'  b')
    text(tC,c,'  c')

    amp = ((a-b)+(c-b))/2;

    title(sprintf('%s  |  Composite = %.2f µV',subj,amp))

    xlabel('Time (ms)')
    ylabel('Amplitude (µV)')

    xlim([-100 500])

    reply = input('Peaks OK? (y/n): ','s');

    if strcmpi(reply,'n')

        disp('Click: a (pos), b (neg), c (pos)')
        [x,y] = ginput(3);

        tA=x(1); a=y(1);
        tB=x(2); b=y(2);
        tC=x(3); c=y(3);

        amp = ((a-b)+(c-b))/2;

        clf
        plot(time,signal,'k','LineWidth',2); hold on
        xline(0,'--k')

        plot(tA,a,'go','MarkerFaceColor','g')
        plot(tB,b,'go','MarkerFaceColor','g')
        plot(tC,c,'go','MarkerFaceColor','g')

        text(tA,a,'  a')
        text(tB,b,'  b')
        text(tC,c,'  c')

        title(sprintf('%s  |  Composite = %.2f µV  (manual)',subj,amp))
    end

    results.Subject(f) = subj;
    results.a(f,1) = a;
    results.b(f,1) = b;
    results.c(f,1) = c;
    results.Composite(f,1) = amp;

end

save('TEBC_N1P2_composite.mat','results')
writetable(results,'TEBC_N1P2_composite.csv')