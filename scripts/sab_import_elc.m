function [EEG] = sab_import_elc(filename, EEG)
%
% sab_import_elc.m--
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
% Sarah Blum (sarah.blum@uol.de), 2019-05-24 15:09
%-------------------------------------------------------------------------

     if nargin < 1
        help readeetraklocs;
        return;
    end;
    
    % read location file
    % ------------------
    % tab, space and colon
    locs  = loadtxt(filename, 'delim', [':', 9, 32]);
        
    % get label names
    % ---------------
    % start with an offsetof three lines because they contain information we don't need. the next nbchan
    % lines will contain the channel labels
    % we cannot know when the labels stop, look for the word 'Nasion' and remember its index
    all_labels = locs([1:end],1);
    last_label_index = find(strcmp(all_labels, 'Nasion'));
    if isempty(last_label_index)
        last_label_index = EEG.nbchan + 4;
    end
    labels = locs([4:last_label_index-1],1);
    
    % get positions
    % -------------
    % this now contains the coordinates of the channels in the same order as the labels
    positions = locs(4:[last_label_index-1],3:5);
        
    % create structure
    % ----------------
    i = 1;
    for index = 1:length(labels)
        chanlocs(index).labels = labels{index};
        chanlocs(index).X      = positions{index,1};
        chanlocs(index).Y      = positions{index,2};
        chanlocs(index).Z      = positions{index,3};
        if strcmpi(chanlocs(index).labels,'ref') || strcmpi(chanlocs(index).labels, 'gnd')
            IN{i} = index;
            i = i + 1;
        end
    end;
    % we must delete ref and gnd if it's in there
    if i > 1
        chanlocs(IN{1}) = [];
        chanlocs(IN{2}) = [];
    end
    chanlocs = convertlocs(chanlocs, 'cart2all');
    EEG.chanlocs = chanlocs;
    