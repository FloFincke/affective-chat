PATH = '../vince_with_dates_no_skt.csv'
OUTCOME_COLUMN = 'receptivity'
START_OF_INPUT = 3
END_OF_INPUT = -1

import pandas as pd
import glob
#data_sets_files = glob.glob(PATH)
#df = (pd.concat((pd.read_csv(f, sep=';', header=0) for f in data_sets_files))).values
df = pd.read_csv(PATH,sep=';')

# Split into train-/ and test-set
from sklearn.model_selection import train_test_split
df_train, df_test = train_test_split(df)

# Define the outcome feature
import numpy as np
y_train = np.where(df_train[OUTCOME_COLUMN] == 1.0, 1, 0)
y_test = np.where(df_test[OUTCOME_COLUMN] == 1.0, 1, 0)

# Define the input features
X_train = df_train.iloc[:,START_OF_INPUT:END_OF_INPUT]
X_test = df_test.iloc[:,START_OF_INPUT:END_OF_INPUT]

# Create model object
from sklearn.ensemble import RandomForestClassifier
model = RandomForestClassifier()

# Fit model and predict on training data
model.fit(X_train, y_train)
y_pred_train = model.predict(X_train)
p_pred_train = model.predict_proba(X_train)[:, 1]

# Predict on test data
p_baseline = [y_train.mean()]*len(y_test)
p_pred_test = model.predict_proba(X_test)[:, 1]

# Measure performance on test data
from sklearn.metrics import roc_auc_score
auc_base = roc_auc_score(y_test, p_baseline)
auc_test = roc_auc_score(y_test, p_pred_test)
print(auc_base, auc_test)