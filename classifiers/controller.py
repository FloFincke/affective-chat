import numpy as np
from sklearn.metrics import accuracy_score

from classifiers.baselines import Classifier
from classifiers.data_set import produce_data_set

#from baselines import Classifier
#from data_set import produce_data_set

PATH = "../vince_with_dates_no_skt.csv"
# PATH = "../vince_with_dates.csv"

seed = 155
np.random.seed(seed)


def get_accuracies(current_x_train, current_x_test, current_y_train, current_y_test):
    # print('X_train len: ' + str(len(x_train)))
    # print('Y_train len: ' + str(len(y_train)))
    # print('X_test len: ' + str(len(x_test)))
    # print('Y_test len: ' + str(len(y_test)))
    # print(x_train[0])
    # print(y_train[0])

    classifier = Classifier()

    y_train_dt = current_y_train.astype('int')
    y_test_dt = current_y_test.astype('int')

    # Decision Tree
    decision_tree = classifier.decision_tree.fit(current_x_train, y_train_dt)
    # Random Forest
    random_forest = classifier.random_forest.fit(current_x_train, y_train_dt)
    # Dummy Strategies
    dummy_stratified = classifier.dummy_stratified.fit(current_x_train, y_train_dt)
    dummy_most_frequent = classifier.dummy_most_frequent.fit(current_x_train, y_train_dt)
    dummy_prior = classifier.dummy_prior.fit(current_x_train, y_train_dt)
    dummy_uniform = classifier.dummy_uniform.fit(current_x_train, y_train_dt)
    dummy_constant = classifier.dummy_constant.fit(current_x_train, y_train_dt)

    # Decision Tree
    predictions_tree = decision_tree.predict(current_x_test)
    dt_accuracy = accuracy_score(y_test_dt, predictions_tree)

    # Random Forest
    predictions_random = random_forest.predict(current_x_test)
    rf_accuracy = accuracy_score(y_test_dt, predictions_random)

    # Dummy Strategies
    predictions_dummy_stratified = dummy_stratified.predict(current_x_test)
    predictions_dummy_most_frequent = dummy_most_frequent.predict(current_x_test)
    predictions_dummy_prior = dummy_prior.predict(current_x_test)
    predictions_dummy_uniform = dummy_uniform.predict(current_x_test)
    predictions_dummy_constant = dummy_constant.predict(current_x_test)

    ds_accuracy = accuracy_score(y_test_dt, predictions_dummy_stratified)
    dms_accuracy = accuracy_score(y_test_dt, predictions_dummy_most_frequent)
    dp_accuracy = accuracy_score(y_test_dt, predictions_dummy_prior)
    du_accuracy = accuracy_score(y_test_dt, predictions_dummy_uniform)
    dc_accuracy = accuracy_score(y_test_dt, predictions_dummy_constant)

    return dt_accuracy, rf_accuracy, ds_accuracy, dms_accuracy, dp_accuracy, du_accuracy, dc_accuracy

accuracy_per_day = produce_data_set(PATH)

days = []
whole_dt_acc = []
whole_rf_acc = []
whole_ds_acc = []
whole_dms_acc = []
whole_dp_acc = []
whole_du_acc = []
whole_dc_acc = []

for option in accuracy_per_day:
    x_train = option[0]
    x_test = option[1]
    y_train = option[2]
    y_test = option[3]
    day = option[4]
    dt_acc, rf_acc, ds_acc, dms_acc, dp_acc, du_acc, dc_acc = get_accuracies(x_train, x_test, y_train, y_test)
    days.append(day)
    whole_dt_acc.append(dt_acc)
    whole_rf_acc.append(rf_acc)
    whole_ds_acc.append(ds_acc)
    whole_dms_acc.append(dms_acc)
    whole_dp_acc.append(dp_acc)
    whole_du_acc.append(du_acc)
    whole_dc_acc.append(dc_acc)

    print('Test Day: ' + str(day))
    print('Decision Tree Acc: ' + str(dt_acc))
    print('Random Forest Acc: ' + str(rf_acc))
    print('Dummy Stratified: ' + str(ds_acc))
    print('Dummy Most Frequent: ' + str(dms_acc))
    print('Dummy Prior: ' + str(dp_acc))
    print('Dummy Uniform: ' + str(du_acc))
    print('Dummy Constant: ' + str(dc_acc))
    print('\n')

avg_dt = sum(whole_dt_acc) / len(whole_dt_acc)
avg_rf = sum(whole_rf_acc) / len(whole_rf_acc)
avg_ds = sum(whole_ds_acc) / len(whole_ds_acc)
avg_dms = sum(whole_dms_acc) / len(whole_dms_acc)
avg_dp = sum(whole_dp_acc) / len(whole_dp_acc)
avg_du = sum(whole_du_acc) / len(whole_du_acc)
avg_dc = sum(whole_dc_acc) / len(whole_dc_acc)

print('\n')
print('\n')

print('Average Decision Tree Accuracy: ' + str(avg_dt))
print('Average Random Forest Accuracy: ' + str(avg_rf))
print('Average Dummy Stratified: ' + str(avg_ds))
print('Average Dummy Most Frequent: ' + str(avg_dms))
print('Average Dummy Prior: ' + str(avg_dp))
print('Average Dummy Uniform: ' + str(avg_du))
print('Average Dummy Constant: ' + str(avg_dc))
