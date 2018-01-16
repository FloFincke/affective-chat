import glob
import warnings
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score
from sklearn import tree

warnings.filterwarnings("ignore")

PATH = "../vince.csv"

data_sets_files = glob.glob(PATH)
data_set = (pd.concat((pd.read_csv(f, sep=';', header=0) for f in data_sets_files))).values

X = data_set[:, 2:-1]
Y = data_set[:,-1]

X_train, X_test, y_train, y_test = train_test_split( X, Y, test_size = 0.275, random_state = 42)

scaler = StandardScaler()

X_train_fitted	= scaler.fit_transform(X_train)
X_test_fitted	= scaler.fit_transform(X_test)
y_train_dt		= y_train.astype('int')
y_test_dt		= y_test.astype('int')

# DECISION TREE
decisionTree = tree.DecisionTreeClassifier()
decisionTree.fit(X_train, y_train_dt)
predictions_tree = decisionTree.predict(X_test)
print('Accuracy DecsionTree: ' + str(accuracy_score(y_test_dt, predictions_tree)))


# RANDOM FOREST
clf = RandomForestClassifier(n_jobs=2, random_state=0)
clf.fit(X_train, y_train_dt)
predictions = clf.predict(X_test)
print('Accuracy RandomForest: ' + str(accuracy_score(y_test_dt, predictions)))