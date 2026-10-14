# Optimized cardiorespiratory state and trace eyeblink conditioning (TEBC): analysis code

MATLAB/FieldTrip code for:

> Santhana Gopalan, P. R., & Nokia, M. S. (2026). Optimized Cardiorespiratory State at Tone Onset Enhances Sensory Responses but Not Associative Learning in Healthy Adults. *European Journal of Neuroscience*. https://doi.org/10.1111/ejn.70722

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23363484.svg)](https://doi.org/10.5281/zenodo.23363484)

## Overview

Young (n = 41) and older (n = 19) adults completed a passive auditory task while 128-channel EEG, ECG and respiration were recorded (NeurOne, 1 kHz). The cardiorespiratory state giving the largest composite N1-P2 response was identified for each participant. Participants then underwent trace eyeblink conditioning (TEBC) with the tone-CS timed either to their individually optimal state (Personalised) or to diastole during expiration (Control). The code:

1. preprocesses the EEG (channel interpolation, ICA, 1-30 Hz filter),
2. sorts passive-task trials by respiration phase (2 bins) and cardiac phase (2 bins) at tone onset and finds each participant's optimal state from the composite N1-P2,
3. computes heart and respiration rate,
4. extracts CS-locked ERPs during TEBC and validates the cardiorespiratory state at CS onset,
5. computes theta-band inter-trial coherence and induced power,
6. scores conditioned responses from the EMG and derives learning measures,
7. produces the figures.

Statistics were run in IBM SPSS Statistics 30 (ANOVAs, t-tests, Mann-Whitney U-tests) and JASP (Bayesian ANOVAs). Those steps are not part of this repository. Chi-square tests, split-half reliability and some correlations are computed in the MATLAB scripts.

## Requirements

- MATLAB with the Signal Processing and Statistics and Machine Learning toolboxes
- FieldTrip 20230427 and 20251218
- EEGLAB 2025.1.0 with ICLabel (ICA cleaning, topographies)
- EGI HydroCel GSN 128 layout (`GSN-HydroCel-128.sfp`, included in `resources/`)

## Data

Participant data are not included. They are available from the corresponding author on reasonable request. This also applies to the per-participant cardiac bin edges (see below). Participant codes in the scripts (`PLxx` young, `PLexx` older) are pseudonymous.

## Usage

1. Replace the project root `C:\TEBC_project` and the toolbox paths (`C:\toolboxes\...`) with your own folders, and add the repository to the MATLAB path (`addpath(genpath(...))`).
2. Run the scripts in order. Most per-participant scripts are interactive and run one participant at a time (`file_idx`).

| Script | Step | Paper |
|---|---|---|
| `01_preprocessing/s01_data_visualization_interpolation.m` | Visual inspection, bad channel interpolation | Methods 2.4.2 |
| `01_preprocessing/s01a_bad_channel_detection.m` | Flat and noisy channel detection | Methods 2.4.2 |
| `01_preprocessing/s02_ica.m` | ICA (FastICA, 30 components), removal of artifact components | Methods 2.4.2 |
| `01_preprocessing/edf_combiner.m` | Joins one recording saved in two parts | |
| `02_passive_task_optimal_state/s03_erp_passive_task.m` | 1-30 Hz band-pass, epochs (-200 to 1000 ms), artifact rejection, average reference, ERPs | Methods 2.4.2 |
| `02_passive_task_optimal_state/s04_resp_phase_bins.m` | Respiration phase at tone onset, 2 bins | Methods 2.4.1 |
| `02_passive_task_optimal_state/s05a_cardiac_phase_window.m` | Proposed cardiac bin edges from the mean ECG waveform | Methods 2.4.1 |
| `02_passive_task_optimal_state/s05_ecg_bins.m` | Cardiac phase at tone onset, 2 bins | Methods 2.4.1 |
| `02_passive_task_optimal_state/s06_cardioresp_bins_n1p2.m` | ERPs per cardiorespiratory state and composite N1-P2 | Methods 2.4.2, Fig. 2A |
| `02_passive_task_optimal_state/s06b_cardioresp_bins_n1p2_figure.m` | Same, all four states in one figure | Fig. 2A |
| `02_passive_task_optimal_state/plot_assigned_phase_N1P2.m` | ERPs and peaks per state for one participant | Fig. 2A |
| `02_passive_task_optimal_state/passive_trial_counts.m` | Trials retained after artifact rejection | Methods 2.4.2 |
| `02_passive_task_optimal_state/resp_ecg_trial_counts.m` | Trials per respiration and cardiac bin | Methods 2.4.1 |
| `02_passive_task_optimal_state/optimal_state_stats.m` | Distribution of optimal states, chi-square tests, relative maximum, ANOVA | Results 3.2 |
| `02_passive_task_optimal_state/stats_passive_phase_distribution.m` | Optimal-state distribution by age group | Results 3.2 |
| `02_passive_task_optimal_state/split_half_reliability.m` | Optimal state from two random halves of the trials | Results 3.2 |
| `02_passive_task_optimal_state/split_half_reliability_stats.m` | Split-half agreement, Cohen's kappa, correlations | Results 3.2 |
| `03_heart_resp_rate/s07_resp_rate_heart_rate.m` | Heart and respiration rate | Results 3.1 |
| `03_heart_resp_rate/s14_resp_rate_heart_rate_qc.m` | Same, with signal quality checks | Results 3.1 |
| `04_tebc_erp/s10_tebc_erp.m` | CS-locked epochs (-100 to 500 ms), artifact rejection, average reference, ERPs | Methods 2.6.2.1 |
| `04_tebc_erp/tebc_erp_n1p2_composite.m` | Composite N1-P2 during TEBC, with manual peak check | Results 3.3 |
| `04_tebc_erp/s11_ga_erp_tebc_auditory.m` | Grand-averaged passive-task and TEBC ERPs | |
| `04_tebc_erp/s13_ga_erp_tebc_control_vs_personalised.m` | Grand-averaged TEBC ERPs, Control vs. Personalised | Fig. 3A-B |
| `04_tebc_erp/n1_p2_extraction.m` | Mean N1 and P2 amplitudes in fixed windows | |
| `04_tebc_erp/tebc_posthoc_phase_validation.m` | ECG and respiration around each CS onset | Results 3.3 |
| `05_time_frequency/tf_analysis.m` | Wavelet decomposition, ITC, evoked and induced power | Methods 2.6.2.2 |
| `05_time_frequency/tf_metric.m` | Subject-level 5-10 Hz, 80-300 ms values | Methods 2.6.2.2 |
| `05_time_frequency/tf_stats.m` | Group comparisons and correlations | Results 3.3 |
| `05_time_frequency/tf_multiple_regression.m` | ITC and induced power as predictors of N1-P2 | Results 3.3 |
| `05_time_frequency/tf_erp_mechanism.m` | Correlations between TF measures and N1-P2 | Results 3.3 |
| `05_time_frequency/tf_ga_young.m`, `tf_ga_older.m` | Grand averages per age group | |
| `05_time_frequency/tf_young_control_vs_personalised.m`, `tf_older_control_vs_personalised.m`, `tf_figure.m` | Time-frequency figures | |
| `06_conditioning_emg/cr_estimation.m` | EMG envelope and CR detection per trial | Methods 2.7 |
| `06_conditioning_emg/cr_estimation_part2.m` | Bad-trial screen, learner criterion, block-wise CR%, peak performance, strict-exclusion sample | Methods 2.7, Results 3.4 |
| `06_conditioning_emg/cr_estimation_personalised_vs_control.m` | Learning curves and peak performance by group | Results 3.4 |
| `06_conditioning_emg/best_performance.m` | Peak performance figure and 2 x 2 ANOVA | Results 3.4 |
| `06_conditioning_emg/learning_rate.m` | Trial of the fifth CR | Results 3.4 |
| `06_conditioning_emg/s15_cr_longformat.m` | Trial-level CR table in long format | |
| `06_conditioning_emg/emg_preprocessing.m` | Early EMG check (polarity, threshold) | |
| `07_figures/condition_distribution_figure.m`, `n1p2_distribution_figure.m`, `n1p2_by_state_and_group_figure.m`, `erp_composite_figure.m` | Passive-task N1-P2 figures | Fig. 2 |
| `07_figures/erp_topoplot.m`, `topoplot_maker.m` | N1 and P2 topographies, ROI layout | Fig. 3C-D |
| `07_figures/tebc_figure.m`, `tebc_figure_all.m`, `tebc_figure_with_inset.m`, `tebc_figure_strict_exclusion.m` | TEBC learning curves | Fig. 4A-D |
| `07_figures/learning_rate_figure.m` | Age vs. peak performance and learning rate | Fig. 4E-F |
| `07_figures/resp_ecg_sample_figure.m`, `eyeblink_checking_in_topoplot.m`, `topoplot_gif.m` | Example signals and checks | |

Trial functions (`tone_times.m`, `tebcerp.m`, `emgtrial.m`, `emgtrial1.m`) sit next to the scripts that use them.

## Key parameters

- **ROI:** electrodes 6, 7 and 106 (fronto-central).
- **Passive-task epochs:** -200 to 1000 ms relative to tone onset, baseline -200 to 0 ms, 1-30 Hz band-pass.
- **TEBC epochs:** -100 to 500 ms relative to CS onset, baseline -100 to 0 ms, CS-US paired trials only.
- **Artifact rejection:** epoch rejected if peak-to-peak exceeds 175 µV in more than 25 channels, or 300 µV in any channel (computed from sample 150 onward).
- **Composite N1-P2:** first positive peak (a), following trough (b) and next positive peak (c) after onset, at least 75 ms apart, visually verified; amplitude = [(a - b) + (c - b)] / 2.
- **Respiration phase:** `angle(hilbert(resp))` of the raw respiration signal at tone onset, rounded to two decimals, split at 0 rad.
- **Cardiac phase:** time from the preceding R-peak to tone onset, sorted into systole and diastole with per-participant edges.
- **Time-frequency:** -1 to 1 s epochs, 1-30 Hz band-pass, 50 Hz notch, baseline -300 to -50 ms, 3-cycle wavelets 4-15 Hz; ITC and induced power averaged over 5-10 Hz and 80-300 ms.
- **CR detection:** EMG high-pass 60 Hz and low-pass 20 Hz (8th-order Butterworth, two-pass), rectified; threshold baseline mean + 2.5 SD (-500 to 0 ms); bad trial if exceeded -200 to 0 ms; CR if exceeded 600-800 ms after CS onset.
- **Learning measures:** CR% in five blocks of 10 paired trials; peak performance = highest CR% in blocks 3-5; learning rate = trial of the fifth CR.

## Notes on implementation details

- **Event codes.** Passive task: trigger value 1 = tone. TEBC EEG: annotation `A - Stimulation` = CS. TEBC EMG: `Stimulus A` = tone CS, `Stimulus B` = airpuff US.
- **Trial order.** CR tables have 60 rows: CS-alone trials 1-5, CS-US paired trials 6-55, CS-alone (extinction) trials 56-60. The five initial US-alone trials are dropped.
- **Split recording.** One TEBC recording was saved in two parts and joined with `edf_combiner.m`.
- **Random halves.** `split_half_reliability.m` uses `rng('shuffle')`, so each run draws different halves.

## Citation

If you use this code, please cite the article above and this repository (see `CITATION.cff`).

## License

MIT, see `LICENSE`.

## Contact

Praghajieeth Raajhen Santhana Gopalan, University of Jyväskylä (ORCID [0000-0003-4244-485X](https://orcid.org/0000-0003-4244-485X))
