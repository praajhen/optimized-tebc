%% ============================================================
%  POST-HOC VALIDATION: ALL TEBC SUBJECTS
%
%  ECG + RESPIRATION + ACTUAL CS ONSETS
%
%  Based directly on the ORIGINAL WORKING PL01 CODE.
%
%  For every participant:
%       1. Find the paired CS-US trials
%       2. Read ECG + respiration from the SAME EDF
%       3. Extract +/-2 seconds around the actual CS onset
%       4. Plot trials 1-25
%       5. Plot trials 26-50
%       6. Save PNG images only
%

% ============================================================

clear;
clc;
close all;

%% ============================================================
% FIELDTRIP
% ============================================================

addpath('C:\toolboxes\fieldtrip-20230427');
ft_defaults;

%% ============================================================
% PATHS
% ============================================================

data_folder = ...
    'C:\TEBC_project\data\TEBC';

output_folder = ...
    'C:\TEBC_project\intermediate_files\ecg_resp_state_validation';

%% Create output folder

if ~exist(output_folder,'dir')
    mkdir(output_folder);
end

%% ============================================================
% SETTINGS
% ============================================================

fs = 1000;

window_before = 2;
window_after  = 2;

samples_before = round(window_before * fs);
samples_after  = round(window_after * fs);

t = (-samples_before:samples_after) / fs;

%% ============================================================
% FIND ALL TEBC EDF FILES
% ============================================================

files = dir(fullfile(data_folder,'*_TEBC*.edf'));

fprintf('\n');
fprintf('============================================\n');
fprintf('TEBC ECG + RESPIRATION VALIDATION\n');
fprintf('============================================\n');

fprintf('EDF files found: %d\n',length(files));

%% ============================================================
% GET UNIQUE PARTICIPANTS
%
% Example:
%
% PL01_TEBC.edf
% PL38_TEBC1.edf
% PL38_TEBC2.edf
%
% becomes:
%
% PL01
% PL38
% ============================================================

participant_names = cell(length(files),1);

for f = 1:length(files)

    participant_names{f} = ...
        regexprep(files(f).name,'_TEBC[0-9]*\.edf$','');

end

participant_names = unique(participant_names,'stable');

fprintf('Participants found: %d\n', ...
    length(participant_names));

%% ============================================================
% PROCESS ALL PARTICIPANTS
% ============================================================

for p = 3:length(participant_names)

    participant = participant_names{p};

    fprintf('\n');
    fprintf('============================================\n');
    fprintf('Participant %d / %d: %s\n', ...
        p,length(participant_names),participant);
    fprintf('============================================\n');

    %% ========================================================
    % FIND EDF FILE(S) FOR THIS PARTICIPANT
    % ========================================================

    participant_files = [];

    for f = 1:length(files)

        this_participant = ...
            regexprep(files(f).name,'_TEBC[0-9]*\.edf$','');

        if strcmp(this_participant,participant)

            participant_files = ...
                [participant_files; files(f)];

        end

    end

    %% Sort EDF files

    [~,order] = sort({participant_files.name});

    participant_files = participant_files(order);

    fprintf('EDF file(s): ');

    for f = 1:length(participant_files)

        fprintf('%s ',participant_files(f).name);

    end

    fprintf('\n');

    %% ========================================================
    % CREATE THE TWO FIGURES
    %
    % These remain open while we process the EDF file(s).
    % This allows us to put trials from split recordings
    % into the correct trial numbers.
    % ========================================================

    fig1 = figure( ...
        'Color','w', ...
        'Position',[50 50 1600 1000], ...
        'Visible','on');

    fig2 = figure( ...
        'Color','w', ...
        'Position',[50 50 1600 1000], ...
        'Visible','on');

    %% ========================================================
    % GLOBAL TRIAL COUNTER
    % ========================================================

    global_trial = 0;

    %% ========================================================
    % PROCESS EACH EDF FILE
    % ========================================================

    for f = 1:length(participant_files)

        edf_file = fullfile( ...
            data_folder, ...
            participant_files(f).name);

        fprintf('\nReading: %s\n', ...
            participant_files(f).name);

        %% ====================================================
        % READ EVENTS
        % ====================================================

        event = ft_read_event(edf_file);

        %% Remove empty events

        empty_idx = ...
            find(arrayfun(@(x) isempty(x.value),event));

        event(empty_idx) = [];

        %% Event labels and samples

        event_values = {event.value}';
        event_samples = [event.sample]';

        %% ====================================================
        % FIND STIMULUS A AND STIMULUS B
        % ====================================================

        A_idx = strcmp(event_values,'Stimulus A');
        B_idx = strcmp(event_values,'Stimulus B');

        A_samples = event_samples(A_idx);
        B_samples = event_samples(B_idx);

        fprintf('Stimulus A events: %d\n', ...
            length(A_samples));

        fprintf('Stimulus B events: %d\n', ...
            length(B_samples));

        %% ====================================================
        % FIND PAIRED CS-US TRIALS
        %
        % Stimulus A = CS
        % Stimulus B = US
        %
        % Paired trial:
        % A followed by B 700-900 ms later
        % ====================================================

        CS_samples = [];
        US_samples = [];

        for i = 1:length(A_samples)

            %% Find first B after this A

            next_B = ...
                B_samples(B_samples > A_samples(i));

            if isempty(next_B)

                continue

            end

            %% Delay between A and B

            delay_samples = ...
                next_B(1) - A_samples(i);

            delay_ms = ...
                delay_samples / fs * 1000;

            %% Paired trial

            if delay_ms >= 700 && delay_ms <= 900

                CS_samples(end+1,1) = ...
                    A_samples(i);

                US_samples(end+1,1) = ...
                    next_B(1);

            end

        end

        fprintf('Paired trials in this EDF: %d\n', ...
            length(CS_samples));

        %% ====================================================
        % IF NO PAIRED TRIALS, MOVE TO NEXT EDF
        % ====================================================

        if isempty(CS_samples)

            continue

        end

        %% ====================================================
        % READ PHYSIOLOGICAL DATA
        %
        % EXACT SAME APPROACH AS WORKING PL01 CODE
        % ====================================================

        hdr = ft_read_header(edf_file);

        data = ft_read_data(edf_file);

        fprintf('Data size: %d channels x %d samples\n', ...
            size(data,1),size(data,2));

        %% ====================================================
        % FIND ECG CHANNEL
        % ====================================================

        ecg_idx = ...
            find(strcmpi(hdr.label,'ECG'));

        if isempty(ecg_idx)

            ecg_idx = ...
                find(contains(lower(hdr.label),'ecg'));

        end

        if isempty(ecg_idx)

            ecg_idx = ...
                find(contains(lower(hdr.label),'ekg'));

        end

        %% ====================================================
        % FIND RESPIRATION CHANNEL
        % ====================================================

        resp_idx = ...
            find(strcmpi(hdr.label,'Resp'));

        if isempty(resp_idx)

            resp_idx = ...
                find(contains(lower(hdr.label),'resp'));

        end

        %% ====================================================
        % CHECK CHANNELS
        % ====================================================

        if isempty(ecg_idx)

            close(fig1);
            close(fig2);

            error('%s: ECG channel not found.', ...
                participant);

        end

        if isempty(resp_idx)

            close(fig1);
            close(fig2);

            error('%s: Respiration channel not found.', ...
                participant);

        end

        fprintf('ECG = %s\n', ...
            hdr.label{ecg_idx(1)});

        fprintf('Resp = %s\n', ...
            hdr.label{resp_idx(1)});

        %% ====================================================
        % EXTRACT ECG + RESP
        % ====================================================

        ecg = double(data(ecg_idx(1),:));

        resp = double(data(resp_idx(1),:));

        %% Diagnostic information

        fprintf('ECG NaN: %.2f %%\n', ...
            100*sum(isnan(ecg))/length(ecg));

        fprintf('Resp NaN: %.2f %%\n', ...
            100*sum(isnan(resp))/length(resp));

        fprintf('ECG range: %.2f to %.2f\n', ...
            min(ecg,[],'omitnan'), ...
            max(ecg,[],'omitnan'));

        fprintf('Resp range: %.2f to %.2f\n', ...
            min(resp,[],'omitnan'), ...
            max(resp,[],'omitnan'));

        %% ====================================================
        % PLOT EACH TRIAL
        %
        % IMPORTANT:
        % This is now essentially the SAME method as your
        % original working PL01 code.
        % ====================================================

        for tr = 1:length(CS_samples)

            %% Increase global trial number

            global_trial = global_trial + 1;

            %% Actual CS sample

            cs = CS_samples(tr);

            %% Calculate +/-2 s window

            idx1 = cs - samples_before;

            idx2 = cs + samples_after;

            %% =================================================
            % CHECK RECORDING BOUNDARIES
            % =================================================

            if idx1 < 1 || idx2 > length(ecg)

                fprintf(['WARNING: %s Trial %d cannot be ' ...
                    'plotted. CS=%d, recording=%d samples.\n'], ...
                    participant, ...
                    global_trial, ...
                    cs, ...
                    length(ecg));

                continue

            end

            %% =================================================
            % INDEX SIGNAL DIRECTLY
            % =================================================

            idx = idx1:idx2;

            this_ecg = ecg(idx);

            this_resp = resp(idx);

            %% =================================================
            % CHECK FOR ACTUAL SIGNAL
            % =================================================

            if all(isnan(this_ecg)) || ...
               all(isnan(this_resp))

                fprintf(['WARNING: %s Trial %d contains ' ...
                    'only NaN values.\n'], ...
                    participant,global_trial);

                continue

            end

            %% =================================================
            % FIGURE 1 — TRIALS 1-25
            % =================================================

            if global_trial <= 25

                figure(fig1);

                subplot(5,5,global_trial);

                %% ECG

                yyaxis left

                plot(t,this_ecg,'k');

                ylabel('ECG');

                %% Respiration

                yyaxis right

                plot(t,this_resp,'b');

                ylabel('Resp');

                hold on;

                %% Actual CS onset

                xline(0,'r','LineWidth',1.5);

                xlim([-2 2]);

                title(sprintf('Trial %d', ...
                    global_trial));

                grid on;

            %% =================================================
            % FIGURE 2 — TRIALS 26-50
            % =================================================

            else

                figure(fig2);

                subplot(5,5,global_trial-25);

                %% ECG

                yyaxis left

                plot(t,this_ecg,'k');

                ylabel('ECG');

                %% Respiration

                yyaxis right

                plot(t,this_resp,'b');

                ylabel('Resp');

                hold on;

                %% Actual CS onset

                xline(0,'r','LineWidth',1.5);

                xlim([-2 2]);

                title(sprintf('Trial %d', ...
                    global_trial));

                grid on;

            end

        end

        %% ====================================================
        % CLEAR LARGE DATA BEFORE NEXT EDF
        % ====================================================

        clear data ecg resp hdr event;

    end

    %% ========================================================
    % CHECK TOTAL TRIALS
    % ========================================================

    fprintf('\n');
    fprintf('--------------------------------------------\n');
    fprintf('%s TOTAL PAIRED TRIALS = %d\n', ...
        participant,global_trial);
    fprintf('--------------------------------------------\n');

    %% ========================================================
    % PARTICIPANT MUST HAVE 50 TRIALS
    % ========================================================

    if global_trial ~= 50

        fprintf(['WARNING: %s has %d paired trials ' ...
            'instead of 50.\n'], ...
            participant,global_trial);

        fprintf('Figures will NOT be saved.\n');

        close(fig1);
        close(fig2);

        continue

    end

    %% ========================================================
    % ADD TITLES
    % ========================================================

    figure(fig1);

    sgtitle(sprintf( ...
        '%s: Trials 1-25 | ±2 s around CS onset', ...
        participant));

    figure(fig2);

    sgtitle(sprintf( ...
        '%s: Trials 26-50 | ±2 s around CS onset', ...
        participant));

    %% ========================================================
    % SAVE ONLY PNG FILES
    % ========================================================

    png_file_1 = fullfile( ...
        output_folder, ...
        sprintf('%s_1.png',participant));

    png_file_2 = fullfile( ...
        output_folder, ...
        sprintf('%s_2.png',participant));

%% Save

drawnow;

exportgraphics( ...
    fig1, ...
    png_file_1, ...
    'Resolution',200);

drawnow;

exportgraphics( ...
    fig2, ...
    png_file_2, ...
    'Resolution',200);

%% Close figures

close(fig1);
close(fig2);

    %% ========================================================
    % PARTICIPANT COMPLETE
    % ========================================================

    fprintf('\n');
    fprintf('SAVED:\n');

    fprintf('  %s_1.png\n',participant);
    fprintf('  %s_2.png\n',participant);

end

%% ============================================================
% FINISHED
% ============================================================

fprintf('\n\n');
fprintf('============================================\n');
fprintf('VALIDATION FIGURES COMPLETE\n');
fprintf('============================================\n');

fprintf('Output folder:\n');
fprintf('%s\n',output_folder);

fprintf('============================================\n');