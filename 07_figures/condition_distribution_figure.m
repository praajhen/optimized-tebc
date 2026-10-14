clear; clc; close all;

load('C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\CardioResp_N1P2_allSubjects.mat')

figure('Color','w','Position',[100 100 1080 520]);

set(groot,'defaultAxesFontName','Arial')
set(groot,'defaultTextFontName','Arial')
set(groot,'defaultAxesFontSize',14)
set(groot,'defaultTextFontSize',14)

rng(1)

phaseNames = {'EXP-DIA','EXP-SYS','INS-DIA','INS-SYS'};

phaseColors = [
    0.20 0.60 1.00
    0.85 0.20 0.45
    0.20 0.75 0.75
    0.45 0.20 0.75
];

jitterAmount = 0.32;

nYoung = sum(best.AgeGroup == 1);
nOlder = sum(best.AgeGroup == 2);

for age = 1:2
    
    ax(age) = subplot(1,2,age);
    hold on
    
    if age == 1
        set(gca,'Position',[0.08 0.14 0.39 0.76])
        title(sprintf('Young adults (n = %d)', nYoung), 'FontWeight','bold')
        text(-0.18,1.02,'A','Units','normalized','FontWeight','bold','FontSize',18)
    else
        set(gca,'Position',[0.55 0.14 0.39 0.76])
        title(sprintf('Older adults (n = %d)', nOlder), 'FontWeight','bold')
        text(-0.18,1.02,'B','Units','normalized','FontWeight','bold','FontSize',18)
    end
    
    ageIdx = best.AgeGroup == age;
    
    %% Control
    idxC = ageIdx & best.ConditionGroup == 1;
    yC = best.Amp(idxC);
    condC = best.Condition(idxC);
    
    for i = 1:length(yC)
        
        label = upper(condC{i});
        label = strrep(label,'_','-');
        label = strrep(label,'–','-');
        label = strrep(label,' ','');
        
        p = find(strcmp(label, phaseNames));
        if isempty(p)
            p = 1;
        end
        
        x = 1 + (rand - 0.5) * jitterAmount;
        
        scatter(x, yC(i), 72, ...
            'MarkerFaceColor', phaseColors(p,:), ...
            'MarkerEdgeColor', 'k', ...
            'LineWidth',0.7);
    end
    
    %% Personalised
    idxP = ageIdx & best.ConditionGroup == 2;
    yP = best.Amp(idxP);
    condP = best.Condition(idxP);
    
    for i = 1:length(yP)
        
        label = upper(condP{i});
        label = strrep(label,'_','-');
        label = strrep(label,'–','-');
        label = strrep(label,' ','');
        
        p = find(strcmp(label, phaseNames));
        if isempty(p)
            p = 1;
        end
        
        x = 2 + (rand - 0.5) * jitterAmount;
        
        scatter(x, yP(i), 72, ...
            'MarkerFaceColor', phaseColors(p,:), ...
            'MarkerEdgeColor', 'k', ...
            'LineWidth',0.7);
    end
    
    %% Means
    meanC = mean(yC);
    semC  = std(yC) / sqrt(length(yC));
    
    meanP = mean(yP);
    semP  = std(yP) / sqrt(length(yP));
    
    errorbar(1, meanC, semC, 'k', 'LineWidth',2, 'CapSize',10)
    plot(1, meanC, 'kd', 'MarkerFaceColor','k', 'MarkerSize',8)
    
    errorbar(2, meanP, semP, 'k', 'LineWidth',2, 'CapSize',10)
    plot(2, meanP, 'kd', 'MarkerFaceColor','k', 'MarkerSize',8)
    
    nC = sum(idxC);
    nP = sum(idxP);
    
    set(gca,...
        'XTick',[1 2],...
        'XTickLabel',{ ...
        sprintf('Control (n = %d)',nC), ...
        sprintf('Personalised (n = %d)',nP)},...
        'LineWidth',1.2,...
        'TickDir','out')
    
    xlim([0.5 2.5])
    ylim([0 10])
    
    if age == 1
        ylabel('Composite N1-P2 amplitude (\muV)')
    end
    
    box off
    
end

for i = 1:4
    h(i) = scatter(ax(2),nan,nan,70,...
        'MarkerFaceColor',phaseColors(i,:),...
        'MarkerEdgeColor','k');
end

legend(ax(2),h,phaseNames,...
    'Location','northeast',...
    'Box','off',...
    'FontSize',11);

exportgraphics(gcf,'N1-P2_composite.png','Resolution',600);