function [impedances] = sab_parse_impedances_from_header(pathin, num_channels)
    %
    % sab_parse_impedances_from_header.m--
    %
    % inputs
    %   pathin : path to the header files Brain Vision Data Exchange Header File Version 1.0
    %   num_channels: how many channels were in the recording
    %
    % output
    %   array of impedance values with dimension files_in_the_folder x num_channels
    %
    % dependencies:
    %   loadtxt() - load ascii text file into numeric or cell arrays from Arnaud Delorme
    %
    % Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2019-07-09 12:58
    %-------------------------------------------------------------------------
    
    
    % get a list of all the vhdr files in the specified folder
    flist = dir([pathin, '*.vhdr']);
    for s = 1: length(flist)
        header = loadtxt([flist(s).folder, filesep , flist(s).name]);
        
        % in the header file, at some point the impedance values are written below each other. They start
        % with a title which states that from now on, values will be impedances. This title can be found by
        % searching for 'Impedance' and use the first value as start index. This index marks the start of
        % the channel numbers
        start_idx_channel = find(strcmp(header, 'Impedance'));
        
        % in another row of the parsed data, we find the impedance values themselves, ordered by channel
        % number. Their first value can be found in the column with the title '[kOhm]', use the first
        % result as starting point for the impedance values
        start_idx_values =  find(strcmp(header, '[kOhm]'));
        
        % save impedance values for this header file
        % get the values
        vals = header(start_idx_values(1)+1: start_idx_values(1)+ num_channels);
        
        % this may contain strings, because BrainVisionRecorder indicates values out of range with a warning
        % in the form of a string (thank you)
        if isempty(find(strcmp(vals, 'Out'),1))
            % if the entries do not contain 'Out of Range', they can still be invalid entries which are
            % indicated by '???' and I assume this means that for some reason no impedance measurement was
            % recorded. In this case, replace the question marks by NaNs and inform the user
            if all(vals{1} == '???')
                impedances(s,:) = nan(1,num_channels);
                warning('Missing impedance values detected! Filled them with NaNs.')
            else
                impedances(s,:) = cell2mat(vals);
                disp('All good, have some impedance values.')
            end
        else
            % replace out of range number with very high value for us: 1000
            all_ind_of_strings = find(strcmp(vals, 'Out'));
            vals(all_ind_of_strings) = {nan()}; %{1000};
            impedances(s,:) = cell2mat(vals);
            disp('Values out of range were replaced by NaN.')
        end
    end
    
end


