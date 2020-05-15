function [] = sab_01_import()
%
% sab_01_import.m--
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
% Sarah Blum (sarah.blum@uol.de), 2019-05-07 16:36
%-------------------------------------------------------------------------

% paths
p_morning = 'data/rawdata/Morning/';
p_evening = 'data/rawdata/Evening/';
PATHS = {p_morning, p_evening};

% channels to import
morning_chans = [1:22];
evening_chans = [1:22, 33:56]; % 1:22 fEEGrid, 23:32 empty, 33:56 cap, 57:64 empty
CHANS = {morning_chans, evening_chans};

gridchannels = [1:22];
capchannels = [23:46];


% to assemble the output directory
PATHOUT = 'data/raw_with_channel_info/';
SESSIONS = {'Morning', 'Evening'};

% import everything, append channel info and cut out empty channels, then save
[ALLEEG, EEG ,CURRENTSET ,ALLCOM] = eeglab;
for paths = 1 : length(PATHS)
    % flist will now contain the files in the respective folder
    flist = dir([PATHS{paths}, '*.vhdr']);
    
    for s = 1 : length(flist)
        % import raw data
        EEG_full = pop_loadbv([pwd, filesep, PATHS{paths}], ...  path
            [flist(s).name], ...                         filename
            [ ],...                                         samples to import (all)
            CHANS{paths}); %                                channels to import
        
        % add channel information
        if EEG_full.nbchan > 22 % we have grid and cap data together
            % only load cap channels
            EEG_cap = pop_select(EEG_full, 'channel', capchannels);
            % add channel info 3d
            EEG_cap = pop_chanedit(EEG_cap, 'load',{'locations/brainstorm/24_cap.xyz' 'filetype' 'xyz'});
            rename_and_save(EEG_cap, flist, s, '_evening_cap');
            
            % afterwards only load grid channels
            EEG_grid = pop_select(EEG_full, 'channel', gridchannels);
            % add channel info 3d
            EEG_grid = pop_chanedit(EEG_grid, 'load',{'locations/brainstorm/grid.xyz' 'filetype' 'xyz'});
            rename_and_save(EEG_grid, flist, s, '_evening_grid');
            
        else % we only have grid

            EEG_grid = pop_select(EEG_full, 'channel', gridchannels);
            % add channel info 3d
            EEG_grid = pop_chanedit(EEG_grid, 'load',{'locations/brainstorm/grid.xyz' 'filetype' 'xyz'});
            rename_and_save(EEG_grid, flist, s, '_morning_grid');
        end

    end
end
    function rename_and_save(EEGin, flist, s, nam)
            EEGin = eeg_checkset(EEGin);
            EEGin = pop_resample(EEGin, 500); % just in case
            EEGin.setname = flist(s).name(1:end-5);
            % save data set with correct number of channels and channel location information
            EEGin = pop_saveset( EEGin, 'filename', [EEGin.setname,nam], 'filepath', [PATHOUT, SESSIONS{paths}, filesep]);
    end

end





