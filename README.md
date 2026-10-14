# Personalised cardiorespiratory timing in trace eyeblink conditioning

MATLAB analysis code for:

> Santhana Gopalan, P. R., & Nokia, M. S. (2026). Optimized Cardiorespiratory State at Tone Onset Enhances Sensory Responses but Not Associative Learning in Healthy Adults. *European Journal of Neuroscience*. https://doi.org/10.1111/ejn.70722

Forty-one young and 19 older adults completed a passive auditory task while EEG (128-channel HydroCel GSN), ECG and respiration were recorded. The cardiorespiratory state (INS–SYS, INS–DIA, EXP–SYS, EXP–DIA) giving the largest composite N1–P2 response was identified per participant. Participants then underwent trace eyeblink conditioning (TEBC) with the tone-CS timed either to their individually optimal state (Personalised) or to diastole during expiration (Control).

## Requirements

- MATLAB (R2023a or later recommended) with the Signal Processing and Statistics and Machine Learning toolboxes
- [FieldTrip](https://www.fieldtriptoolbox.org/) (versions 20230427 and 20251218 were used)
- [EEGLAB](https://sccn.ucsd.edu/eeglab/) with the ICLabel plugin (ICA cleaning, topographies)

Statistical tests reported in the paper were run in IBM SPSS 30 and JASP; the scripts here produce the values exported to those programs and some of the tests.

## Setup

The scripts were written for one workstation and use absolute Windows paths. Before running:

1. Replace the project root `C:\MyTemp\Personalised TEBC (2024-2025)` with your own folder (find and replace across the repository).
2. Replace the FieldTrip/EEGLAB paths (`C:\MyTemp\fieldtrip-...`, `C:\MyTemp\eeglab...`) with your installations.
3. Add the repository to the MATLAB path so helper functions are found: `addpath(genpath('path/to/this/repo'))`.

Expected project folder layout: `data/auditory`, `data/TEBC` (raw `.edf`), `intermediate_files/` (outputs of each step), `CR/`, `figures/`.

Most per-participant scripts process one file at a time (`file_idx`), as the analysis included manual inspection steps (bad channels, ICA components, peak verification).

## Pipeline

| Folder | Manuscript section | Content |
|---|---|---|
| `01_preprocessing` | 2.4.2 | Data browsing and channel interpolation (`s01`), bad-channel detection (`s01a`), ICA and component rejection (`s02`), joining a split recording (`edf_combiner`) |
| `02_passive_task_optimal_state` | 2.4, 3.2 | Passive-task epoching and amplitude-based trial rejection (`s03`, `tone_times`), respiration phase bins via Hilbert transform (`s04`), cardiac systole/diastole bins (`s05`, `s05a`), four cardiorespiratory bins and composite N1–P2 `[(a − b) + (c − b)] / 2` (`s06`, `s06b`, `plot_assigned_phase_N1P2`), trial counts, chi-square tests and ANOVA on optimal states (`optimal_state_stats`, `stats_passive_phase_distribution`) |
| `03_heart_resp_rate` | 2.6.1, 3.1 | Heart rate and respiration rate |
| `04_tebc_erp` | 2.6.2.1, 3.3 | CS-locked ERPs during TEBC (`s10`, trial function `tebcerp`), composite N1–P2 extraction, grand averages, N1/P2 extraction, post-hoc validation of the cardiorespiratory state at CS onset |
| `05_time_frequency` | 2.6.2.2, 3.3 | Wavelet decomposition (3 cycles, 4–15 Hz), ITC and induced power, 5–10 Hz / 80–300 ms metrics, statistics, regression and figures |
| `06_conditioning_emg` | 2.7, 3.4 | EMG envelope, CR detection (M + 2.5 × SD, 600–800 ms window), block-wise CR%, peak performance, learning rate, strict-exclusion sample, long-format export (trial functions `emgtrial`, `emgtrial1`) |
| `07_figures` | Figures 2–4 | Figure scripts and topographies |
| `resources` | | Electrode locations for the 128-channel HydroCel net |

Suggested order: `01` → `02` → `03` → `04` → `05` → `06` → `07`. Script numbers (`s01`, `s02`, ...) follow the original analysis order.

## Data

Participant data are not included. As stated in the article, data are available from the corresponding author upon reasonable request. Participant codes in the scripts (`PLxx` young, `PLexx` older) are pseudonymous.

## Original file names

Files were renamed to valid MATLAB script names. Mapping from the original names:

| New path | Original name |
|---|---|
| `01_preprocessing/s01_data_visualization_interpolation.m` | `1.data visualization and interpolation.m` |
| `01_preprocessing/s01a_bad_channel_detection.m` | `1a. noisy, bad channel detection.m` |
| `01_preprocessing/s02_ica.m` | `2.ICA.m` |
| `01_preprocessing/edf_combiner.m` | `edf combiner.m` |
| `02_passive_task_optimal_state/s03_erp_passive_task.m` | `3.ERP_N1.m` |
| `02_passive_task_optimal_state/s04_resp_phase_bins.m` | `4. resp_phase_bins vs. ERP.m` |
| `02_passive_task_optimal_state/s05_ecg_bins.m` | `5.ecg_bins vs. ERP.m` |
| `02_passive_task_optimal_state/s05a_cardiac_phase_window.m` | `9.systole_diastole window.m` |
| `02_passive_task_optimal_state/s06_cardioresp_bins_n1p2.m` | `6.resp+ecg vs. ERP.m` |
| `02_passive_task_optimal_state/s06b_cardioresp_bins_n1p2_figure.m` | `6.1.resp+ecg vs. ERP.m` |
| `02_passive_task_optimal_state/passive_trial_counts.m` | `trial counts.m` |
| `02_passive_task_optimal_state/optimal_state_stats.m` | `chi-test (n= 60).m` |
| `03_heart_resp_rate/s07_resp_rate_heart_rate.m` | `7. resp rate + heart rate.m` |
| `03_heart_resp_rate/s14_resp_rate_heart_rate_qc.m` | `14.RSAI.m` |
| `04_tebc_erp/s10_tebc_erp.m` | `10. TEBC erp.m` |
| `04_tebc_erp/tebc_erp_n1p2_composite.m` | `tebc_erp_N1-P2_composite.m` |
| `04_tebc_erp/s11_ga_erp_tebc_auditory.m` | `11.ga_erp_tebc audiotry.m` |
| `04_tebc_erp/s13_ga_erp_tebc_control_vs_personalised.m` | `13.ga_erp_TEBC_control vs personlaised.m` |
| `04_tebc_erp/n1_p2_extraction.m` | `n1 & p2 extraction.m` |
| `04_tebc_erp/tebc_posthoc_phase_validation.m` | `TEBC_posthoc_phase_validation.m` |
| `05_time_frequency/tf_analysis.m` | `TF analysis.m` |
| `05_time_frequency/tf_metric.m` | `TF metric.m` |
| `05_time_frequency/tf_stats.m` | `TF stats.m` |
| `05_time_frequency/tf_ga_young.m` | `TF GA.m` |
| `05_time_frequency/tf_ga_older.m` | `TF GA_older.m` |
| `05_time_frequency/tf_young_control_vs_personalised.m` | `TF young c vs. p.m` |
| `05_time_frequency/tf_older_control_vs_personalised.m` | `TF older c vs. p.m` |
| `05_time_frequency/tf_multiple_regression.m` | `TF multiple regression.m` |
| `05_time_frequency/tf_erp_mechanism.m` | `TF ERP_mechanism.m` |
| `05_time_frequency/tf_figure.m` | `TF figure.m` |
| `06_conditioning_emg/cr_estimation.m` | `CR_estimation.m` |
| `06_conditioning_emg/cr_estimation_part2.m` | `CR_estimation_PART2.m` |
| `06_conditioning_emg/cr_estimation_personalised_vs_control.m` | `CR_estimation_p_vs._c.m` |
| `06_conditioning_emg/s15_cr_longformat.m` | `15.CR_longformat.m` |
| `06_conditioning_emg/best_performance.m` | `best performance.m` |
| `06_conditioning_emg/learning_rate.m` | `learning rate.m` |
| `07_figures/condition_distribution_figure.m` | `condtion distribution.m` |
| `07_figures/n1p2_distribution_figure.m` | `n1p2 distribution figure.m` |
| `07_figures/erp_composite_figure.m` | `erp_compositve figure.m` |
| `07_figures/resp_ecg_sample_figure.m` | `resp,ecg sample figure.m` |
| `07_figures/topoplot_gif.m` | `topoplot gif.m` |
| `07_figures/tebc_figure.m` | `TEBC_figure.m` |
| `07_figures/tebc_figure_all.m` | `TEBC_figure_all.m` |
| `07_figures/tebc_figure_with_inset.m` | `TEBC_figure with inset.m` |
| `07_figures/tebc_figure_strict_exclusion.m` | `TEBC_figure_strict_exclusion.m` |
| `07_figures/learning_rate_figure.m` | `learning rate_figure.m` |

## Citation

If you use this code, please cite the article above and this software archive (see `CITATION.cff`; DOI on Zenodo).

## Licence

MIT, see `LICENSE`.

## Contact

Praghajieeth Raajhen Santhana Gopalan, University of Jyväskylä (praghajieeth.santhana@jyu.fi)
