% EEGLAB history file generated on the 08-Aug-2017
% ------------------------------------------------
%This script provedes the Matlab code for preprocessing the EEG data for a random participant. You need customize it specifically for you puproses.


EEG.etc.eeglabvers = '14.1.0'; % this tracks which version of EEGLAB is being used, you may ignore it

%importing the data
EEG = pop_loadeep('C:\Users\Olzhas\Data\Experiment_data\P09\EEG\P09-EEG-1.cnt');

% Setting the name
EEG.setname='P09';

% This funciton checks the consistency of the fields of an EEG dataset. It is done automatically by the EEGLAB
EEG = eeg_checkset( EEG );

% Importing channel location using 10-20 system from EEGLAB GUI
EEG=pop_chanedit(EEG, 'lookup','C:\\Users\\Olzhas\\Progs\\eeglab14_1_0b\\eeglab14_1_0b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp');
EEG = eeg_checkset( EEG );

% Importing the trigger information from AntNeuro files. Specify latency, duration, type as the file columns.
EEG = pop_importevent( EEG, 'event','C:\\Users\\Olzhas\\Data\\Experiment_data\\P09\\EEG\\P09-EEG-1.trg','fields',{'latency' 'duration' 'type'},'skipline',1,'timeunit',1);
EEG = eeg_checkset( EEG );

% For the preprocessing and normal artifact rejection we select only actual trials and the BCI system electrodes. At this point of analysis we dismiss other electrodes except BCI.
EEG = pop_select( EEG,'time',[445.8 2208] ,'channel',{'Fp1' 'Fpz' 'Fp2' 'F7' 'F3' 'Fz' 'F4' 'F8' 'FC5' 'FC1' 'FC2' 'FC6' 'M1' 'T7' 'C3' 'Cz' 'C4' 'T8' 'M2' 'CP5' 'CP1' 'CP2' 'CP6' 'P7' 'P3' 'Pz' 'P4' 'P8' 'POz' 'O1' 'Oz' 'O2'});

% Updating the name
EEG.setname='P09_acttrl';
EEG = eeg_checkset( EEG );

% Filtering the lower edge of the data at 0.5 Hz using lowpass filter
EEG = pop_eegfiltnew(EEG, [],0.5,16500,1,[],1);

% Updating the name
EEG.setname='P09_acttrl_filt';
EEG = eeg_checkset( EEG );

% Filtering the upper edge of the data at 30 Hz using highpass filter
EEG = pop_eegfiltnew(EEG, [],30,1100,0,[],1);
EEG = eeg_checkset( EEG );

% Rerefrencing the data using common average reference
EEG = pop_reref( EEG, []);

% Updating the name
EEG.setname='P09_acttrl_filt_reref';
EEG = eeg_checkset( EEG );
EEG = eeg_checkset( EEG );

% Calculating the ICA weights using "Extended" mode and 31 components
EEG = pop_runica(EEG, 'extended',1,'interupt','on','pca',31);
EEG = eeg_checkset( EEG );

%Epoching the data set around trigger 4 in the interval [-1 2] seconds so the analysis will be consetrated on stimulus.
EEG = pop_epoch( EEG, {  '4'  }, [-1  2], 'newname', 'P09_acttrl_filt_reref_epoched', 'epochinfo', 'yes');

% Updating the name
EEG.setname='P09_acttrl_filt_reref_epoched_1_2';
EEG = eeg_checkset( EEG );

% Removing the baseling in the interval  [-100    0] sec.
EEG = pop_rmbase( EEG, [-100    0]);

% Updating the name
EEG.setname='P09_acttrl_filt_reref_epoched_1_2_bsline';
EEG = eeg_checkset( EEG );

% !!!!!!!!At this point You need to run SASICA from the GUI. It will propose artifactual components which need to be rejected.!!!!!!
% After running the SASICA, reject the artifact components.
EEG = pop_subcomp( EEG, [3   5   7  12  27  29  30], 0);

% Updating the name
EEG.setname='P09_acttrl_filt_reref_epoched_1_2_bsline_comp_rej';
EEG = eeg_checkset( EEG );

% Running the PREP pipeline toolbox to perform detrending. The parameters are default
EEG = pop_prepPipeline(struct('detrendChannels', [1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32], 'detrendCutoff', 1, 'detrendStepSize', 0.02, 'detrendType', 'High Pass'), 

% Updating the name
EEG.setname='P09_acttrl_filt_reref_epoched_1_2_bsline_comp_rej_detrend';
EEG = eeg_checkset( EEG );

%Running the PREP pipeline toolbox to remove line noise. We use 50 Hz as the main parameter.
EEG = pop_prepPipeline(struct('lineNoiseChannels', [1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32], 'lineFrequencies', [60   120   180   240   300   360   420   480   540   600   660   720   780   840   900   960  1020  1080  1140  1200], 'Fs', 50, 'p', 0.01, 'fScanBandWidth', 2, 'taperBandWidth', 2, 'taperWindowSize', 4, 'pad', 0, 'taperWindowStep', 1, 'fPassBand', [0  1250], 'tau', 100, 'maximumIterations', 10), 

% Updating the name
EEG.setname='P09_acttrl_filt_reref_epoched_1_2_bsline_comp_rej_detrend_linens';
EEG = eeg_checkset( EEG );

% Detrecting epochs which exceed 75 microVolts threshold.
EEG = pop_autorej(EEG, 'nogui','on','threshold',75,'eegplot','on');

% Updating the name
EEG.setname='P09_acttrl_filt_reref_epoched_1_2_bsline_comp_rej_detrend_linens_epoch_rej';
EEG = eeg_checkset( EEG );

% Rejecting the detected epochs.
EEG = pop_rejepoch( EEG, [63 76 82 91 98 116 122 124 125 126 132 137 143 158 160 186 202 204 220 243 251 257] ,0);
