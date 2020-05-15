function sab_05_epoch(PATHIN, marker1, marker2, PATHOUT)
%
% sab_061_vibro_epoch.m--
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
% Sarah Blum (sarah.blum@uol.de), 2019-05-23 16:06
%-------------------------------------------------------------------------
    
    % path info
    %SESSIONS = {'Morning/', 'Evening/'};
    SESSIONS = {'Evening/'};
    % boot eeglab
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    
    % epoch parameters
    epoch.locthresh = 3;
    epoch.globthresh = 3;
    epoch.superpose = 0;
    epoch.reject = 1;
    epoch.vistype = 0;
    

    
    % index to store grid data, this must go until 40, every subject has two datasets with grid data,
    % but only one dataset with cap data
    ss = 1;
    
    for sess = 1 : length(SESSIONS)
        flist = dir([PATHIN, SESSIONS{sess},  '*.set']);
        
        for s = 1 : length(flist)
            EEG = pop_loadset('filename',flist(s).name,'filepath', [PATHIN, SESSIONS{sess}]);
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
            EEG = eeg_checkset( EEG );
            
            % epoch, baseline removal, bad epoch rejection, store in new EEG set
            timerange = [-0.2, 0.8];
            baseline = [-200, 0];
            [EEG_freq, n_epochs_f, nrej_f] = sab_epoch(EEG, {marker1}, timerange, epoch, baseline, true);
            [EEG_rare, n_epochs_r, nrej_r] = sab_epoch(EEG, {marker2}, timerange, epoch, baseline, true);
            
            ALLEEG_freq(ss) = EEG_freq;
            ALLEEG_rare(ss) = EEG_rare;
            ALL_f(ss) = n_epochs_f; 
            NREJ_F(ss) = nrej_f;
            ALL_r(ss) = n_epochs_r; 
            NREJ_R(ss) = nrej_r;
            ss = ss + 1;
            
            % save single subject data as well for later analyses
            if EEG_freq.nbchan > 22
                electrode_info = 'cap';
            else 
                electrode_info = 'grid';
            end
                
            pop_saveset(EEG_freq, 'filename', [EEG.setname, '_', electrode_info, '_freq'], 'filepath', [PATHOUT]);
            pop_saveset(EEG_rare, 'filename', [EEG.setname, '_', electrode_info, '_rare'], 'filepath', [PATHOUT]);
            
        end % flist
    end % morning and evening session
   % save to folder
   disp('saving variables....');
   save([PATHOUT, 'ALLEEG_freq.mat'], 'ALLEEG_freq');
   save([PATHOUT, 'ALLEEG_rare.mat'], 'ALLEEG_rare');
   
   % to add in the results section of paper
   disp(['mean epochs frequent:   ', num2str(mean(ALL_f))]);
   disp(['mean epochs rare:       ', num2str(mean(ALL_r))]);
   disp(['mean rejected frequent: ', num2str(mean(NREJ_F))]);
   disp(['mean rejected rare:     ', num2str(mean(NREJ_R))]);
   disp(['rejected percentage:    ', num2str((mean(NREJ_F)/mean(ALL_f)) * 100)]);
   disp(['rejected percentage:    ', num2str((mean(NREJ_R)/mean(ALL_r)) * 100)]);
   
   % audio
%     mean epochs frequent:   212.6
%     mean epochs rare:       54
%     mean rejected frequent: 30.775
%     mean rejected rare:     8.2
%     rejected percentage:    14.4755
%     rejected percentage:    15.1852
   
%     vibrotactile
%         mean epochs frequent:   303.4
%         mean epochs rare:       76.85
%         mean rejected frequent: 45.175
%         mean rejected rare:     11.175
%         rejected percentage:    14.8896
%         rejected percentage:    14.5413

   % N400
%    mean epochs frequent:   50
%    mean epochs rare:       50
%    mean rejected frequent: 6.75
%    mean rejected rare:     7.3
%   rejected percentage:    13.5
%   rejected percentage:    14.6
   
end

