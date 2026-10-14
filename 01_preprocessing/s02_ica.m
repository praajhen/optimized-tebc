clear; clc;

addpath('C:\MyTemp\fieldtrip-20230427');
ft_defaults;

data_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\clean_channels\';  % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, '*.mat'));  % List all .edf files in the folder

%--------------------------------------------------------------------------------------------------
file_idx =  2 %enter the file number
%--------------------------------------------------------------------------------------------------

dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

%load cleaned channel EEG data
load(dataset_filename);

cfg = [];
cfg.dftfreq       = [50 100 150]; %line noise frequencies
data = ft_preprocessing(cfg, data_fixed);

% Perform ICA anlaysis
cfg        = [];
cfg.dataset    = dataset_filename;
cfg.continuous = 'yes';
cfg.channel = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60','61', '62', '63', '64', '65', '66', '67', '68', '69', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '100','101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', '121', '122', '123', '124', '125', '126', '127', '128'};
cfg.method = 'fastica'; % this is the default and uses the implementation from EEGLAB
cfg.numcomponent = 30;
cfg.blc = 'no';
ica = ft_componentanalysis(cfg,data_fixed);

% Save ICA results
ica_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\ICA';  % Folder to save ICA results
[~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
ica_filename = fullfile(ica_folder, [base_filename '.mat']);
save(ica_filename, 'ica');


% Plot ICA topoplots
cfg          = [];
cfg.component  = [1:30]; % components to be plotted
cfg.layout    = 'C:\MyTemp\Personalised TEBC (2024-2025)\matlab_code\GSN-HydroCel-128.sfp';
cfg.comment   = 'no';
cfg.marker  ='no';
% cfg.colormap  ='jet';
ft_topoplotIC(cfg, ica);

% Plot ICA time course and topoplots
cfg          = [];
%--------------------------------------------------------------------------------------------------
cfg.channel  = [1 2 3 ]; % components to be plotted
%--------------------------------------------------------------------------------------------------
cfg.viewmode = 'component';
cfg.layout    = 'C:\MyTemp\Personalised TEBC (2024-2025)\matlab_code\GSN-HydroCel-128.sfp';
ft_databrowser(cfg, ica)


% Read the whole EEG data
cfg            = [];
cfg.dataset    = dataset_filename;
cfg.channel = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60','61', '62', '63', '64', '65', '66', '67', '68', '69', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '100','101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', '121', '122', '123', '124', '125', '126', '127', '128'};
data           = ft_preprocessing(cfg);

% Rejecting the artifact ICA componetns
cfg           = [];
%--------------------------------------------------------------------------------------------------
cfg.component = [1 2 3 4 7 8 9 12 13 10 16 22]; %components to be rejected
%--------------------------------------------------------------------------------------------------
data_clean    = ft_rejectcomponent(cfg, ica, data);


% Save ICA cleaned data
ica_cleaned_folder = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\ICA_cleaned\';  % Folder to save ICA results
[~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
ica_cleaned_data_filename = fullfile(ica_cleaned_folder, [base_filename '.mat']);
save(ica_cleaned_data_filename, 'data_clean','-v7.3');



