% GIF filename
gif_filename = 'ERP_animation.gif';

% Channels of interest for ERP and highlight
erp_channels = [6, 7, 106];  
highlight_channels = {'E6','E7','E106'}; % Replace with actual electrode labels if you have them

% Colors for individual channels
line_colors = {'r', 'g', 'k'}; 

% Step size for animation
step_size = 20;  

% Time vector
ga_erp = ga_A_young;
time_vec = ga_erp.time;  

% Create figure
f = figure;
set(f, 'Color', [1 1 1], 'Position', [500, 200, 600, 600]);
%%
cfgtopo = [];
cfgtopo.layout = 'C:\MyTemp\fieldtrip-20230427\template\electrode\GSN-HydroCel-128.sfp';      % your 128-channel layout
cfgtopo.figure = 'gcf';
cfgtopo.zlim = [-5 5];           % adjust based on your ERP amplitude
cfgtopo.marker = 'off';
cfgtopo.highlight = 'on';
cfgtopo.highlightchannel = highlight_channels;
cfgtopo.highlightsymbol = '.';
cfgtopo.highlightsize = 10;
cfgtopo.comment = 'no';
cfgtopo.shading = 'interp';
cfgtopo.gridscale = 500;
%%
for i = 1:step_size:length(time_vec)
    clf(f);
    t = time_vec(i);
    
    % --- ERP subplot ---
    subplot(2,1,1);
    
    % Plot mean across ERP channels
    mean_erp = mean(ga_erp.avg(erp_channels,:), 1);
    plot(time_vec, mean_erp, 'b', 'LineWidth', 2); 
    hold on;
    
    % Plot individual channels
    for c = 1:length(erp_channels)
        plot(time_vec, ga_erp.avg(erp_channels(c),:), 'Color', line_colors{c}, 'LineWidth', 2);
    end
    
    % Vertical line at current time
    xline(t, '--r', 'LineWidth', 2);
    
    % Add label for time
    ylims = ylim;
    text(t+0.01, mean(ylims), sprintf('t = %.3f s', t), 'Color','r', 'FontSize',14, ...
        'HorizontalAlignment','left', 'VerticalAlignment','middle');
    
    xlabel('Time (s)');
    ylabel('Amplitude (\muV)');
    title('ERP over selected electrodes', 'FontWeight', 'normal');
    legend({'mean','ch6','ch7','ch106'}, 'Location','Best');
    grid on; box on;
    
    % --- Topography subplot ---
    subplot(2,1,2);
    cfgtopo.xlim = [t t];
    ft_topoplotER(cfgtopo, ga_erp);
    
    % Add horizontal colorbar
    axes('Position',[0.35,0.08,0.35,0.03],'Visible','off');
    c = colorbar('Location','north');
    caxis(cfgtopo.zlim);
    xlabel(c, '\muV', 'FontSize', 14);
    
    drawnow;
    
    % --- Capture and write GIF ---
    frame = getframe(f);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);
    
    if i == 1
        imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.05);
    else
        imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.05);
    end
end
