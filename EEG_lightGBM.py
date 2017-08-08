import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
from glob import glob
import lightgbm as lgb
import os
import xgboost as xgb
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA, FastICA



def prepare_data_train(fname):
    """ read and prepare training data """
    # Read data
    data = pd.read_csv(fname)
    # events file
    events_fname = fname.replace('_data', '_events')
    # read event file
    labels = pd.read_csv(events_fname)
    clean = data.drop(['id'], axis=1)  # remove id
    labels = labels.drop(['id'], axis=1)  # remove id
    return clean, labels


def prepare_data_test(fname):
    """ read and prepare test data """
    # Read data
    data = pd.read_csv(fname)
    return data


scaler = StandardScaler()


def data_preprocess_train(X):
    X_prep = scaler.fit_transform(X)
    # do here your preprocessing
    return X_prep


def data_preprocess_test(X):
    X_prep = scaler.transform(X)
    # do here your preprocessing
    return X_prep


#######columns name for labels#############
cols = ['HandStart', 'FirstDigitTouch',
        'BothStartLoadPhase', 'LiftOff',
        'Replace', 'BothReleased']

#######number of subjects###############
subjects = range(1, 13)
ids_tot = []
pred_tot = []

###loop on subjects and 8 series for train data + 2 series for test data
for subject in subjects:
    y_raw = []
    raw = []
    ################ READ DATA ################################################
    fnames = glob('train/subj%d_series*_data.csv' % (subject))
    for fname in fnames:
        data, labels = prepare_data_train(fname)
        raw.append(data)
        y_raw.append(labels)

    X = pd.concat(raw)
    y = pd.concat(y_raw)

    # transform in numpy array
    # transform train data in numpy array
    X_train = np.asarray(X.astype(float))
    y = np.asarray(y.astype(float))

    ################ Read test data #####################################
    fnames = glob('test/subj%d_series*_data.csv' % (subject))
    test = []
    idx = []
    for fname in fnames:
        data = prepare_data_test(fname)
        test.append(data)
        idx.append(np.array(data['id']))
    X_test = pd.concat(test)
    ids = np.concatenate(idx)
    ids_tot.append(ids)
    X_test = X_test.drop(['id'], axis=1)  # remove id
    # transform test data in numpy array
    X_test = np.asarray(X_test.astype(float))

    print(X_train.shape)
    ################ Train classifiers ########################################

    X_train = data_preprocess_train(X_train)
    X_test = data_preprocess_test(X_test)
    print(X_train.shape)
    # X_train = pd.DataFrame(X_train)
    # X_test = pd.DataFrame(X_test)
    print(X_train.shape)

    # prepare dict of params for lighgbm to run with
    param = {'num_leaves': 150, 'objective': 'multiclass', 'max_depth': 7, 'learning_rate': .05, 'max_bin': 200, 'num_class': 6}
    param['metric'] = ['auc', 'multi_logloss']

    # form DMatrices for lightgbm training
    # xgboost, cross-validation
    X_train = np.asarray(X_train)
    X_test = np.asarray(X_test)
    print(X_train.shape)
    pred = np.empty((X_test.shape[0], 6))
    for i in range(6):
        y_train = y[:, i]
        dtrain = lgb.Dataset(X_train[::subsample, :], label =  y_train[::subsample])
        # train model
        num_round = 50
        lgbm = lgb.train(param, dtrain, num_round)
        print('Train subject %d, class %s' % (subject, cols[i]))
        pred[:, i] = lgbm.predict(X_test)[:, 1]
    pred_tot.append(pred)

# submission file
submission_file = 'grasp-sub-simple_lgb.csv'
# create pandas object for sbmission
submission = pd.DataFrame(index=np.concatenate(ids_tot),
                          columns=cols,
                          data=np.concatenate(pred_tot))

# write file
submission.to_csv(submission_file, index_label='id', float_format='%.3f')