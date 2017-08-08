"# EEG_preprocessing" 
This repository contains Maltab and Python file for preprocessing EEG data. 
The Matlab file is the preprocessing step for futher analysis. The preprocessing was performed as follows:
  1. Filtering (0.5 – 30 Hz)
	2. re-Reference (Common Average Reference)
	3. Calculating ICA weights using EEGLAB ICA plugin.
	4. Finding and Selecting only actual trials (against whole dataset) for clean data
	5. Epoching from -1 to 2 seconds  was used.
	6. To reject artifactual components, SASICA was used.
	7. Detrending the data and removing line noise.
	8. Removing abnormal epochs
The above steps are the result of researching existing papers on the topic and experimental approach. 

The python file is an analysis code for classifying EEG data for grasp-lift data taken from Kaggle database. The description of the dataset is given here: https://www.kaggle.com/c/grasp-and-lift-eeg-detection.
In the analysis I performed the simple transformation of the data and applying LightGbM algorithm from Microsoft. The code can be used as a template for future use on other EEG datasets. The lightGBM parameters were selected using GrigSearch and Cross-Validation. Along with lightGBM other algorithms such as logistic regression, XGboost, SVM were used, however, lightGBM has the best balance between speed (Top1) and accuracy (Top 2). 
