 clear;  clc;

addpath('C:\toolboxes\fieldtrip-20251218');
ft_defaults;

data_folder = 'C:\TEBC_project\data\auditory\';  % Folder containing your datasets
% data_folder = 'C:\TEBC_project\data\TEBC\';
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder

%--------------------------------------------------------------------------------------------------
file_idx = 31 %enter the file number
%--------------------------------------------------------------------------------------------------

dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

% Read the whole EEG data
cfg            = [];
cfg.dataset    = dataset_filename;
% cfg.channel = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60','61', '62', '63', '64', '65', '66', '67', '68', '69', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '100','101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', '121', '122', '123', '124', '125', '126', '127', '128'};
data           = ft_preprocessing(cfg);

% EEG data browser
cfg = [];
cfg.ylim = [-82 82];
cfg.channel = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60','61', '62', '63', '64', '65', '66', '67', '68', '69', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '100','101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', '121', '122', '123', '124', '125', '126', '127', '128'};
cfg.layout        = 'C:\TEBC_project\matlab_code\GSN-HydroCel-128.sfp';
cfg.viewmode      = 'vertical';
cfg.blocksize     = 5; % time window to browse
cfg.artifactalpha = 0.8;  % this make the colors less transparent and thus more vibrant
artifInfo = ft_databrowser(cfg, data);

%EEG locations
elec =ft_read_sens('C:\TEBC_project\matlab_code\GSN-HydroCel-128.sfp','senstype','eeg');

load ('C:\TEBC_project\matlab_code\neighbours.mat'); %neighbours (see below for code)
load ('C:\TEBC_project\matlab_code\layout.mat'); % EEG layoug (see below for code)

