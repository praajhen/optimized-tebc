function [trl, event] = emgtrial1(cfg)

% =========================================================
% Trial definition for EMG eyeblink conditioning
% Design:
%   5  x US-only  (B)   -> ignored
%   5  x CS-only  (A)
%   50 x CS + US  (A -> B)
%   5  x CS-only  (A)
%
% CS = 'Stimulus A' (tone)
% US = 'Stimulus B' (airpuff)
%
% Trial types:
%   1 = CS-only
%   2 = CS+US
% =========================================================

cfg.trialdef.eventtype = 'annotation';
cfg.trialdef.prestim  = 0.500;   % 500 ms before CS
cfg.trialdef.poststim = 1.000;   % 1000 ms after CS

% ---------------------------------------------------------
% Read header and events
% ---------------------------------------------------------
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% ---------------------------------------------------------
% Remove empty values
% ---------------------------------------------------------
emptyValueIndices = find(arrayfun(@(x) isempty(x.value), event));
event(emptyValueIndices) = [];

% ---------------------------------------------------------
% Remove duplicate events 
% ---------------------------------------------------------
evenIndices = 2:2:length(event);
event(evenIndices) = [];

% ---------------------------------------------------------
% Extract values and samples
% ---------------------------------------------------------
value  = {event(:).value}';
sample = [event(:).sample]';

% ---------------------------------------------------------
% Identify CS and US events
% ---------------------------------------------------------
isCS = strcmp(value, 'Stimulus A');   % tone
isUS = strcmp(value, 'Stimulus B');   % airpuff

cs_samples = sample(isCS);
us_samples = sample(isUS);

nTrials = numel(cs_samples);

% ---------------------------------------------------------
% Trial window in samples
% ---------------------------------------------------------
pretrig  = -round(cfg.trialdef.prestim  * hdr.Fs);
posttrig =  round(cfg.trialdef.poststim * hdr.Fs);

trl = zeros(nTrials, 4);   % [beg end offset trialtype]

for j = 1:nTrials
    
    trlbegin = cs_samples(j) + pretrig;
    trlend   = cs_samples(j) + posttrig;
    offset   = pretrig;
    
    % -----------------------------------------------------
    % Determine if this CS is followed by a US
    % -----------------------------------------------------
    % Find first US after this CS
    nextUS = us_samples(us_samples > cs_samples(j));
    
    if isempty(nextUS)
        trialtype = 1;   % CS-only
    else
        % Check if US falls within this CS epoch
        if nextUS(1) <= trlend
            trialtype = 2;   % CS + US
        else
            trialtype = 1;   % CS-only
        end
    end
    
    trl(j,:) = [trlbegin trlend offset trialtype];
end
