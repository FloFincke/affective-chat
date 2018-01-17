import numpy as np
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler

from classifiers.baselines import Classifier
from classifiers.data_set import produce_data_set

PATH = "../vince_with_dates.csv"

seed = 155
np.random.seed(seed)

X_train, X_test, Y_train, Y_test = produce_data_set(PATH)

print('X_train len: ' + str(len(X_train)))
print('Y_train len: ' + str(len(Y_train)))
print('X_test len: ' + str(len(X_test)))
print('Y_test len: ' + str(len(Y_test)))
print(X_train[0])
print(Y_train[0])

scaler = StandardScaler()

X_train_fitted = scaler.fit_transform(X_train)
X_test_fitted = scaler.fit_transform(X_test)

classifier = Classifier()

Y_train_dt = Y_train.astype('int')
Y_test_dt = Y_test.astype('int')

decision_tree = classifier.decision_tree.fit(X_train, Y_train_dt)
random_forest = classifier.random_forest.fit(X_train, Y_train_dt)

predictions_tree = decision_tree.predict(X_test)
print('Accuracy Tree: ' + str(accuracy_score(Y_test_dt, predictions_tree)))

predictions_random = random_forest.predict(X_test)
print('Accuracy Forest: ' + str(accuracy_score(Y_test_dt, predictions_random)))
