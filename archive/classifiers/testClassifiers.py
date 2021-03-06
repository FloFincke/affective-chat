import glob
import warnings
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score
from sklearn import tree

warnings.filterwarnings("ignore")

PATH = "../vince_with_dates.csv"

data_sets_files = glob.glob(PATH)
data_set = (pd.concat((pd.read_csv(f, sep=';', header=0) for f in data_sets_files))).values

df = pd.DataFrame(data_set)
unique_dates = df[2].unique()
print(unique_dates)

for i in range(len(unique_dates)):
    train, test = np.split(data_set, np.where(data_set[:, 2] != unique_dates[i])[0][1:]), np.split(data_set, np.where(
        data_set[:, 2] == unique_dates[i])[0][1:])
    train, test = np.vstack(train), np.vstack(test)

    X_train, Y_train = train[:, 3:-2], train[:, -1]
    X_test, Y_test = test[:, 3:-2], test[:, -1]
    Y_train_dt, Y_test_dt = Y_train.astype('int'), Y_test.astype('int')

    t = tree.DecisionTreeClassifier()
    t.fit(X_train, Y_train_dt)
    pt = t.predict(X_test)
    print('Accuracy DecisionTree ' + str(i) + ":\t" + str(accuracy_score(Y_test_dt, pt)))

    clf = RandomForestClassifier(n_jobs=2, random_state=0)
    clf.fit(X_train, Y_train_dt)
    predictions = clf.predict(X_test)
    print('Accuracy RandomForest ' + str(i) + ':\t' + str(accuracy_score(Y_test_dt, predictions)))
