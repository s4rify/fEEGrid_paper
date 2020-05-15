function [] = sab_000_main()
%
% sab_000_main.m--
%
% Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
% at University of Oldenburg.
% Sarah Blum (sarah.blum@uol.de), 2019-05-23 16:20
%-------------------------------------------------------------------------

% parameterize if necessary
sab_01_import();
sab_02_filter();
sab_03_extract_calib_data();
% use Riemannian ASR
sab_04_asr('rASRToolbox/');

%% epoch and save data sets in data/epoched/output
% P300 oddball
marker1 = 'S 31';
marker2 = 'S 32';
PATHIN = 'data/asr_cleaned/';
PATHOUT = 'data/epoched/p300_auditory/';
sab_05_epoch(PATHIN, marker1, marker2, PATHOUT);

% vibro
marker1 = 'S 21';
marker2 = 'S 22';
PATHIN = 'data/asr_cleaned/';
% PATHIN = 'data/filtered/';
PATHOUT = 'data/epoched/p300_vibro/';
sab_05_epoch(PATHIN, marker1, marker2, PATHOUT);

% N400 sentences
marker1 = 'S  5';
marker2 = 'S  6';
PATHIN = 'data/asr_cleaned/';
PATHOUT = 'data/epoched/n400_auditory/';
sab_05_epoch(PATHIN, marker1, marker2, PATHOUT);

%% assemble info, combine data sets and plot them. Figures are stored in figures/name.jpg
% P300
path1 = 'data/epoched/p300_auditory/';
name = 'P300_cap_and_grid_audio';
condition = 'Auditory';
show_head_plots = true;
LIMITS = {[-2,2], [-5,5]};
sab_06_assemble_GA_plot(path1, name, condition, 'P300 audio', show_head_plots, LIMITS);

% Vibro
path1 = 'data/epoched/p300_vibro/';
name = 'P300_cap_and_grid_vibro';
condition = 'Vibro';
show_head_plots = true;
LIMITS = {[-2,2], [-5,5]};
sab_06_assemble_GA_plot(path1, name, condition, 'P300 vibro', show_head_plots, LIMITS);

% N400
path1 = 'data/epoched/n400_auditory/';
name = 'N400_cap_and_grid';
condition = 'N400 Sentences';
show_head_plots = true;
LIMITS = {[-2,2], [-6,6]};
sab_06_assemble_GA_plot(path1, name, condition, 'N400', show_head_plots, LIMITS);

%% shrinkage LDA classification
% Audio P300
marker_one =  'S 31' ;
marker_two =  'S 32' ;
[audio_models] = sab_07_crossvalidation(marker_one, marker_two);
[ACC_a, X_a, Y_a, T_a, AUC_a] = sab_08_cross_session_classification_evening(audio_models, marker_one, marker_two);
sab_10_LDA_plot(audio_models, 'audio', AUC_a)

% vibro P300
marker_one =  'S 21' ;
marker_two =  'S 22' ;
[vibro_models] = sab_07_crossvalidation(marker_one, marker_two);
[ACC_v, X_v, Y_v, T_v, AUC_v] = sab_08_cross_session_classification_evening(vibro_models, marker_one, marker_two);
sab_10_LDA_plot(vibro_models, 'vibro', AUC_v)

% N400
marker_one =  'S  5' ;
marker_two =  'S  6' ;
[n400_models] = sab_07_crossvalidation(marker_one, marker_two);
[ACC_n, X_n, Y_n, T_n, AUC_n] = sab_08_cross_session_classification_evening(n400_models, marker_one, marker_two);
sab_10_LDA_plot(n400_models, 'N400', AUC_n)

%% effect size plot
conditions = {'p300_auditory/', 'p300_vibro/', 'n400_auditory/'};
sab_09_hedges_g(conditions{1}, [0,2], [0,3]);
sab_09_hedges_g(conditions{2}, [0,2], [0,3]);
sab_09_hedges_g(conditions{3}, [0,1], [0,1]);

% save uncorrected and corrected data, epoched for the corrected vs uncorrected correlation plot
marker_one =  'S 31';
marker_two =  'S 32';
PATHOUT = 'data/epoched/p300_auditory/';
sab_11_save_sets(marker_one, marker_two, PATHOUT)

marker_one =  'S 21';
marker_two =  'S 22';
PATHOUT = 'data/epoched/p300_vibro/';
sab_11_save_sets(marker_one, marker_two, PATHOUT)

marker_one =  'S  5';
marker_two =  'S  6';
PATHOUT = 'data/epoched/n400_auditory/';
sab_11_save_sets(marker_one, marker_two, PATHOUT)

% plot
PATHIN = 'data/epoched/p300_auditory/';
sab_11_ERP_correlation(PATHIN, 'P300 Audio');

PATHIN = 'data/epoched/p300_vibro/';
sab_11_ERP_correlation(PATHIN, 'P300 Vibro');

PATHIN = 'data/epoched/n400_auditory/';
sab_11_ERP_correlation(PATHIN, 'N400');


% read out impedances from the header
% morning
pathin = [pwd, filesep, 'data/rawdata/Morning/'];
num_channels = 22;
[impedances_morning] = sab_parse_impedances_from_header(pathin, num_channels);
% evening
pathin = [pwd, filesep, 'data/rawdata/Evening/'];
num_channels = 22;
[impedances_evening] = sab_parse_impedances_from_header(pathin, num_channels);

% plot them 
sab_12_impedance_plot(impedances_morning, impedances_evening);

%%  stats
% impedances
mean_morning = mean(impedances_morning,2, 'omitnan');
mean_evening = mean(impedances_evening,2, 'omitnan');
[h,p,ci,stats] = ttest(mean_morning, mean_evening) ;

% effect size
% df should be 19, but: df = 18 because one subj has all nan values and they are ignored -> one entry missing
mean(mean_morning, 'omitnan'); % this is only to report the value in the paper
mean(mean_evening, 'omitnan');
computeCohen_d(mean_morning, mean_evening);
mes(mean_morning, mean_evening, 'hedgesg')

% p300 and n400 difference evaluation
conditions = {'p300_auditory/', 'p300_vibro/', 'n400_auditory/'};
oddball_difference_test(conditions{1})
oddball_difference_test(conditions{2})
oddball_difference_test(conditions{3})



