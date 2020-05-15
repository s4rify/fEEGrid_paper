function [] = sab_02_filter()
%
% sab_02_filter.m--
%
% Input arguments:
%
% Output arguments:
%
% Other m-files required:
%
% Example usage:
%
%
% Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
% at University of Oldenburg.
% Sarah Blum (sarah.blum@uol.de), 2019-05-07 16:39
%-------------------------------------------------------------------------
PATHIN = 'data/raw_with_channel_info/';
PATHOUT = 'data/filtered/';
SESSIONS = {'Morning/', 'Evening/'};

[ALLEEG, EEG ,CURRENTSET ,ALLCOM] = eeglab;

for sess = 1 : length(SESSIONS)
    flist = dir([PATHIN, SESSIONS{sess},  '*.set']);
    for s = 1 : length(flist)
        EEG = pop_loadset('filename',flist(s).name,'filepath', [PATHIN,SESSIONS{sess}]);
        % lp
        EEG = pop_eegfiltnew(EEG, [],40,166,0,[],0);
        % hp
        EEG = pop_eegfiltnew(EEG, [],0.25,6600,1,[],0);
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename', EEG.filename(1:end-4), 'filepath', [PATHOUT, SESSIONS{sess}]);
    end
end
end