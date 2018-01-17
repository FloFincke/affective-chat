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

#X = data_set[:, 3:-1]
#Y = data_set[:,-1]

#X_train, X_test, y_train, y_test = train_test_split( X, Y, test_size = 0.275, random_state = 42)

#print(type(X_train))

#scaler = StandardScaler()

#X_train_fitted	= scaler.fit_transform(X_train)
#X_test_fitted	= scaler.fit_transform(X_test)
#y_train_dt		= y_train.astype('int')
#y_test_dt		= y_test.astype('int')

# DECISION TREE
#decisionTree = tree.DecisionTreeClassifier()
#decisionTree.fit(X_train, y_train_dt)
#predictions_tree = decisionTree.predict(X_test)
#print('Accuracy DecisionTree: ' + str(accuracy_score(y_test_dt, predictions_tree)))


# RANDOM FOREST
#clf = RandomForestClassifier(n_jobs=2, random_state=0)
#clf.fit(X_train, y_train_dt)
#predictions = clf.predict(X_test)
#print('Accuracy RandomForest: ' + str(accuracy_score(y_test_dt, predictions)))



df = pd.DataFrame(data_set)
unique_dates = df[2].unique()

#for i in range(len(unique_dates)):
train, test = np.split(data_set, np.where(data_set[:, 2] != unique_dates[3])[0][1:]), np.split(data_set, np.where(data_set[:, 2] == unique_dates[3])[0][1:])
train, test = np.vstack(train), np.vstack(test)

X_train, Y_train = train[:, 3:-2], train[:,-1]
X_test, Y_test = test[:, 3:-2], test[:,-1]
Y_train_dt, Y_test_dt = Y_train.astype('int'), Y_test.astype('int')



t = tree.DecisionTreeClassifier()
t.fit(X_train, Y_train_dt)
pt = t.predict(X_test)
print('Accuracy DecisionTree ' + str(3) + ":\t" + str(accuracy_score(Y_test_dt, pt)))

clf = RandomForestClassifier(n_jobs=2, random_state=0)
clf.fit(X_train, Y_train_dt)
predictions = clf.predict(X_test)
print('Accuracy RandomForest: ' + str(accuracy_score(Y_test_dt, predictions)))





