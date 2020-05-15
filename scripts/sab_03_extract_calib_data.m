function [] = sab_03_extract_calib_data()
%
% sab_03_extract_calib_data.m--
%
% Experimental markers are stored in fEEGrid_studie/Documents/Code_table.docx: they all begin with
% an 'S' in the data files
% Experiment Artifacts	Has codes beginning with 1
% 11	Welcome Screen
% 12	Fixation Cross
% 13	Pause (ends automatically after time)
% 14	Pause (end with button)
% 15	Tone Trial (beep), they blink simultaneously
% 16	Alpha trial (eyes open 161, eyes closed 162)
% 17	Jaw trial
% 18	Calibration (one trigger every second)
% Experiment Vibro	Has codes beginning with 2
% 21	Frequent vibration
% 22	Rare vibration
% 23	Calibration
% Experiment P300	Has codes beginning with 2
% 31	Standard sound
% 32	Rare sound
% 33	Calibration (one trigger every second)
% Experiment N400	Has one-digit codes (original configuration)
% 4 	Sentence body
% 5     Sinnvolles Ende (meaningful ending)
% 6     Sinnloses Ende (meaningless ending)
% 7     Calibration
% Experiment attentive Listening	Has codes beginning with 4
% 41	Story started
% 42	Calibration
%
%
% Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
% at University of Oldenburg.
% Sarah Blum (sarah.blum@uol.de), 2019-05-09 09:06
%-------------------------------------------------------------------------
PATHIN = 'data/filtered/';
SESSIONS = {'Morning/', 'Evening/'};
PATHOUT = 'data/calibration_data/';

markers = {'S 18', 'S 23', 'S 33', 'S  7', 'S 42'};
% exp = {'artifacts', 'vibro', 'p300', 'n400', 'listening'};

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
for sess = 1 : length(SESSIONS)
    flist = dir([PATHIN, SESSIONS{sess},  '*.set']);
    
    for s = 1 : length(flist)
        EEG = pop_loadset('filename',flist(s).name,'filepath', [PATHIN, SESSIONS{sess}]);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = eeg_checkset( EEG );
        newname = [EEG.filename(1:end-4), '_all_calib'];
        
        % extract 60 seconds beginning with first respective trigger
        indices_art = find(~cellfun(@isempty,regexp({EEG.event.type},markers{1}))); % art
        indices_vibro = find(~cellfun(@isempty,regexp({EEG.event.type},markers{2}))); % vibro
        indices_p300 = find(~cellfun(@isempty,regexp({EEG.event.type},markers{3}))); % p300
        indices_n400 = find(~cellfun(@isempty,regexp({EEG.event.type},markers{4}))); % n400
        indices_list = find(~cellfun(@isempty,regexp({EEG.event.type},markers{5}))); % listening
        %disp([length(indices_art), length(indices_vibro), length(indices_p300), length(indices_n400), length(indices_list)]);
        
        % do we want to concatenate all calibration data epochs for the morning and evening session?
        indices = [indices_art(1), indices_vibro(1), indices_p300(1), indices_n400(1), indices_list(1)];
        EEG = pop_epoch(EEG, {}, [1,60] ,'eventindices', indices, 'epochinfo', 'yes'); 
        
        %EEG = pop_jointprob(EEG,1,[ ] ,2,2,1,0,0,[],0); % reject epoch if > 2 std
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
        EEG = eeg_checkset( EEG );
        % save calib data for every subject in new folder for later cleaning
        EEG = pop_saveset( EEG, 'filename',newname,'filepath', [PATHOUT,SESSIONS{sess}]);
    end
end

end
