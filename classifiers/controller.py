import numpy as np
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler

from classifiers.baselines import Classifier
from classifiers.data_set import produce_data_set

# from baselines import Classifier
# from data_set import produce_data_set

PATH = "../vince_with_dates_no_skt.csv"
# PATH = "../vince_with_dates.csv"

seed = 155
np.random.seed(seed)


def get_accuracies():
    x_train, x_test, y_train, y_test = produce_data_set(PATH)

    # print('X_train len: ' + str(len(x_train)))
    # print('Y_train len: ' + str(len(y_train)))
    # print('X_test len: ' + str(len(x_test)))
    # print('Y_test len: ' + str(len(y_test)))
    # print(x_train[0])
    # print(y_train[0])

    classifier = Classifier()

    y_train_dt = y_train.astype('int')
    y_test_dt = y_test.astype('int')

    decision_tree = classifier.decision_tree.fit(x_train, y_train_dt)
    random_forest = classifier.random_forest.fit(x_train, y_train_dt)

    predictions_tree = decision_tree.predict(x_test)
    dt_accuracy = accuracy_score(y_test_dt, predictions_tree)
    print('Accuracy Tree: ' + str(dt_accuracy))

    predictions_random = random_forest.predict(x_test)
    rf_accuracy = accuracy_score(y_test_dt, predictions_random)
    print('Accuracy Forest: ' + str(rf_accuracy))

    return dt_accuracy, rf_accuracy

whole_dt_acc = []
whole_rf_acc = []

for i in range(24):
    print(i)
    dt_acc, rf_acc = get_accuracies()
    whole_dt_acc.append(dt_acc)
    whole_rf_acc.append(rf_acc)

avg_dt = sum(whole_dt_acc) / 24
avg_rf = sum(whole_rf_acc) / 24

print('Average Decision Tree Accuracy: ' + str(avg_dt))
print('Average Random Forest Accuracy: ' + str(avg_rf))
