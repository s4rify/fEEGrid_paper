function [TABLE, n_one, n_two] = sab_create_table(fname, pathin, marker_one, marker_two)
    %
    % Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2019-05-23 16:06
    %-------------------------------------------------------------------------
    
    win_len = 25; %50 samples = 100ms
    
    % epoch parameters
    epoch_len = [-0.2, 0.8];
    baseline = [-200, 0];
    epoch.locthresh = 3;
    epoch.globthresh = 3;
    epoch.superpose = 0;
    epoch.reject = 0; % do not reject epochs for the classification --> same n for all subjects
    epoch.vistype = 0;
    bs_corr = true;
    
    EEG = pop_loadset('filename',fname, 'filepath',[pwd, filesep, pathin]);
    EEG = eeg_checkset(EEG);
    % 10 hz lowpass
    EEG = pop_eegfiltnew(EEG, [],10,660,0,[],0);
    % class one   
    [EEG_one, ~, ~] = sab_epoch(EEG, {marker_one}, epoch_len, epoch, baseline, bs_corr);
    EEG_one = eeg_checkset(EEG_one);
    % class two
    [EEG_two, ~, ~] = sab_epoch(EEG, {marker_two}, epoch_len, epoch, baseline, bs_corr);
    EEG_two = eeg_checkset(EEG_two);
        
    % store size of data sets for this subj
    n_one = size(EEG_one.data,3);
    n_two = size(EEG_two.data,3);
    
    table_one = sab_feature_extraction(EEG_one.data, marker_one, win_len);
    table_two = sab_feature_extraction(EEG_two.data, marker_two, win_len);
    TABLE = [table_one; table_two];    
end


% helper function which extracts the features: atm this is mean of successive time windows in the epoched
% data for every channel which are stored in a table. the table will have every channel and every
% time window as separate features
% the dimension will be
%
%   -----> n_channels * n_windows
%  |
%  |
%  v
%   n_epoch
%
% Consequently, the label vector will have length n_channels * n_windows and will contain every
% combination of channel and window number
function [tt] = sab_feature_extraction(data, label, win_len)
    winsize  = win_len; %25; % 25 samples = 50ms , 12.5 samples = 25 ms
    len_epoch = size(data,2);
    start_lat = 1;
    windows = [start_lat : winsize : len_epoch];
    n_win = length(windows) -1;
    
    % compute the successive window means
    for i = 1 : n_win
        current_window = windows(i) : windows(i+1);
        % successive mean will contain channel x #epoch entries, each of which contains
        % the averaged data points of the current time window
        % the result has dimensions n_channels x n_windows x n_epochs
        successive_window_mean(:,i,:) = squeeze(mean(data(:,current_window, :),2));
        
        % each channel is supposed to be one feature in our classification
        % channel 1, all windows, all epochs: successive_win_mean(1,:,:)
        F = successive_window_mean;
    end
    
    % create table
    %   -----> n_channels * n_windows
    %  |
    %  |
    %  v
    %   n_epoch
    n_chan = size(data,1);
    n_epoch = size(data,3);
    n = 1;
    for ch = 1: n_chan
        for w = 1 : n_win
            % whithout loop: reshape(F, [n_win, n_epoch*chans]), but then
            % we loose the information for the VariableName (column name in table),
            % TODO can this be done more elegantly?
            current_col(:,w) = squeeze(reshape(F(ch,w,:), [1, (n_epoch * 1)]))';
            col_name{n} = ['ch', num2str(ch), 'w', num2str(w)];
            % never reset n, because we need to store all combinations of channels and windows here
            n = n + 1;
        end
        % save the current column which contains n_channel x n_windows columns and n_epochs rows
        COLS{ch} = current_col;
    end
    
    % construct the table
    tt = array2table(cell2mat(COLS));
    tt.Properties.VariableNames = col_name;
    labels = repmat(label, n_epoch,1);
    tt.Label = labels;
    
end

