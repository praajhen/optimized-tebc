clear; clc;
addpath('C:\MyTemp\fieldtrip-20251218');
ft_defaults;

data_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\data\auditory\';
dataset_files = dir(fullfile(data_folder, '*.edf'));

N = length(dataset_files);

% Preallocate
respiration_rate_bpm = nan(N,1);
respiration_frequency = nan(N,1);
heart_rate_bpm = nan(N,1);

RR_intervals = cell(N,1);
Resp_intervals = cell(N,1);
bad_subjects = false(N,1);

for file_idx = 1:N

    fprintf('\nProcessing %s\n', dataset_files(file_idx).name);
    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    try

        %% ===================== RESPIRATION =====================
        cfg = [];
        cfg.dataset = dataset_filename;
        cfg.channel = 'Resp';
        cfg.bpfilter = 'yes';
        cfg.bpfreq = [0.08 0.7];      % 5–42 breaths/min
        cfg.bpfilttype = 'but';
        cfg.bpfiltord = 2;
        Resp = ft_preprocessing(cfg);

        resp = Resp.trial{1};
        fs_resp = Resp.fsample;

        % Sanity: check signal quality
        if any(isnan(resp)) || std(resp) < 1e-6
            warning('Bad Resp signal in %s', dataset_files(file_idx).name);
            bad_subjects(file_idx) = true;
            continue;
        end

        % Detect respiration peaks
        [resp_peaks, resp_locs] = findpeaks(resp, ...
            'MinPeakDistance', round(1.2*fs_resp), ...
            'MinPeakProminence', std(resp));

        if length(resp_locs) < 5
            warning('Too few Resp peaks in %s', dataset_files(file_idx).name);
            bad_subjects(file_idx) = true;
            continue;
        end

        resp_intervals = diff(resp_locs) / fs_resp;

        % Remove implausible breathing intervals (6–50 bpm)
        resp_intervals = resp_intervals(resp_intervals > 1.2 & resp_intervals < 10);

        if length(resp_intervals) < 5
            warning('Too few valid Resp intervals in %s', dataset_files(file_idx).name);
            bad_subjects(file_idx) = true;
            continue;
        end

        Resp_intervals{file_idx} = resp_intervals;
        respiration_rate_bpm(file_idx) = 60 / median(resp_intervals);
        respiration_frequency(file_idx) = 1 / median(resp_intervals);

        % Sanity: Resp range
        if respiration_rate_bpm(file_idx) < 6 || respiration_rate_bpm(file_idx) > 40
            warning('Implausible Resp rate %.1f bpm in %s', respiration_rate_bpm(file_idx), dataset_files(file_idx).name);
        end


        %% ===================== ECG =====================
        cfg = [];
        cfg.dataset = dataset_filename;
        cfg.channel = 'ecg';
        cfg.bpfilter = 'yes';
        cfg.bpfreq = [5 35];
        cfg.bpfilttype = 'but';
        cfg.bpfiltord = 4;
        ecg = ft_preprocessing(cfg);

        ecg_sig = ecg.trial{1};
        fs_ecg = ecg.fsample;

        % Sanity: check ECG quality
        if any(isnan(ecg_sig)) || std(ecg_sig) < 1e-6
            warning('Bad ECG signal in %s', dataset_files(file_idx).name);
            bad_subjects(file_idx) = true;
            continue;
        end

        % Detect R-peaks
        [rpeaks, rlocs] = findpeaks(ecg_sig, ...
            'MinPeakDistance', round(0.3*fs_ecg), ...
            'MinPeakProminence', 3*std(ecg_sig));

        if length(rlocs) < 10
            warning('Too few ECG peaks in %s', dataset_files(file_idx).name);
            bad_subjects(file_idx) = true;
            continue;
        end

        RR = diff(rlocs) / fs_ecg;

        % Remove implausible RR intervals (24–200 bpm)
        RR = RR(RR > 0.3 & RR < 2.5);

        if length(RR) < 10
            warning('Too few valid RR intervals in %s', dataset_files(file_idx).name);
            bad_subjects(file_idx) = true;
            continue;
        end

        RR_intervals{file_idx} = RR;
        heart_rate_bpm(file_idx) = 60 / median(RR);

        % Sanity: HR range
        if heart_rate_bpm(file_idx) < 40 || heart_rate_bpm(file_idx) > 150
            warning('Implausible HR %.1f bpm in %s', heart_rate_bpm(file_idx), dataset_files(file_idx).name);
        end

        % Variability sanity
        cv_RR = std(RR)/mean(RR);
        if cv_RR < 0.01
            warning('Suspiciously low HR variability in %s', dataset_files(file_idx).name);
        end

        %% ===================== OPTIONAL VISUAL QC =====================
        if file_idx <= 3   % Only inspect first few automatically
            figure('Name', dataset_files(file_idx).name);
            subplot(2,1,1)
            plot(resp); hold on;
            plot(resp_locs, resp(resp_locs), 'r*');
            title('Respiration')

            subplot(2,1,2)
            plot(ecg_sig); hold on;
            plot(rlocs, ecg_sig(rlocs), 'r*');
            title('ECG')
        end

    catch ME
        warning('Error processing %s: %s', dataset_files(file_idx).name, ME.message);
        bad_subjects(file_idx) = true;
    end

end

%% ===================== SUMMARY =====================
fprintf('\nFinished processing.\n');
fprintf('Valid subjects: %d / %d\n', sum(~bad_subjects), N);

% Remove bad subjects for later analyses
valid_idx = ~bad_subjects;
heart_rate_bpm_clean = heart_rate_bpm(valid_idx);
respiration_rate_bpm_clean = respiration_rate_bpm(valid_idx);
