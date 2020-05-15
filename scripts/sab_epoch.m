function [EEGout, n_epoch, nrej] = sab_epoch(EEGin, marker, timerange, epoch, baseline, bs);
%
% sab_epoch.m--
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
% Sarah Blum (sarah.blum@uol.de), 2019-05-16 14:30
%-------------------------------------------------------------------------

    EEGout = pop_epoch(EEGin, marker, timerange);
    n_epoch = size(EEGout.data,3);
    [EEGout, locthresh, globthresh, nrej] = ...
        pop_jointprob(EEGout,1,[1:EEGout.nbchan] ,epoch.locthresh,epoch.globthresh,epoch.superpose,epoch.reject,epoch.vistype);
    if bs
        EEGout = pop_rmbase(EEGout, baseline);
    end
    EEGout = eeg_checkset(EEGout);