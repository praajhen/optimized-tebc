clear; clc; close all

%% EEGLAB
addpath('C:\toolboxes\eeglab2025.1.0')
eeglab; close

%% LOAD LAYOUT
chanlocs = readlocs('GSN-HydroCel-128.sfp');
% chanlocs(1:3) = [];

%% ROI
occ = [52 65 70 72 75 83 90 92];   % Occipital (N1)
% par = [62 72 75];   % Centro-parietal (P3)
par = [6 7 106]

% Draw head
figure('Color','w','Position',[100 100 900 900])

topoplot([], chanlocs, ...
    'style','blank', ...
    'electrodes','on', ...
    'emarkersize',15);

hold on

%% GET TRUE TOPOPLOT COORDINATES
h = findobj(gca,'Type','line');

for i = 1:length(h)
    xd = get(h(i),'XData');
    if length(xd) == length(chanlocs)   % electrode line
        x = get(h(i),'XData');
        y = get(h(i),'YData');
        break
    end
end

% highlight
% plot(x(occ), y(occ), 'o', ...
%     'MarkerSize',20, ...
%     'MarkerFaceColor','b', ...
%     'MarkerEdgeColor','b')

plot(x(par), y(par), 'o', ...
    'MarkerSize',20, ...
    'MarkerFaceColor','b', ...
    'MarkerEdgeColor','b')

% title('Occipital (red) and Parietal (black)')

exportgraphics(gcf,'topo_layout.png','Resolution',600);