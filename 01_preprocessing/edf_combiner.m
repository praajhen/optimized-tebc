addpath('C:\MyTemp\fieldtrip-20251218');
ft_defaults;

file1 = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\ICA_cleaned\TEBC\PL38_TEBC1.set';
file2 = 'C:\MyTemp\Personalised TEBC (2024-2025)\intermediate_files\ICA_cleaned\TEBC\PL38_TEBC2.set';

hdr1 = ft_read_header(file1);
dat1 = ft_read_data(file1);
evt1 = ft_read_event(file1);

hdr2 = ft_read_header(file2);
dat2 = ft_read_data(file2);
evt2 = ft_read_event(file2);

hdr = hdr1; % assume same sampling rate and channel layout
dat = cat(2, dat1, dat2); % concatenate data along time dimension

% number of samples in the first file
nsamples1 = size(dat1, 2);

% shift event sample numbers for the second file
for i = 1:length(evt2)
    if isfield(evt2(i), 'sample') && ~isempty(evt2(i).sample)
        evt2(i).sample = evt2(i).sample + nsamples1;
    end
end

% harmonize event structures
f1 = fieldnames(evt1);
f2 = fieldnames(evt2);
allfields = unique([f1; f2]);
for k = 1:numel(allfields)
    fld = allfields{k};
    if ~isfield(evt1, fld)
        [evt1.(fld)] = deal([]);
    end
    if ~isfield(evt2, fld)
        [evt2.(fld)] = deal([]);
    end
end

% concatenate events
% manually combine evt1 and evt 2 to evt1


ft_write_data('PL38_TEBC.vhdr', dat, 'header', hdr, 'event', evt1);

