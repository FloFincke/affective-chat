import glob
import pandas as pd
from itertools import groupby
from operator import itemgetter
import numpy as np
import random


def produce_data_set(path):
    data_sets_files = glob.glob(path)

    data_set = (pd.concat((pd.read_csv(f, sep=';', header=0) for f in data_sets_files))).values

    data_set = sorted(data_set, key=itemgetter(2))

    data_set = np.array([list(g) for k, g in groupby(data_set, key=itemgetter(2))])

    return generate_train_test_data_per_day(data_set, size=1)


def generate_train_test_data_per_day(data_set, size=1):
    """Works just for size = 1"""
    final_list = []
    if size == 1:
        for i in range(len(data_set)):
            train_set = data_set[np.arange(len(data_set)) != i]
            test_set = np.array(data_set[i])
            day = test_set[0][2]

            train_set = np.array([item for sublist in train_set for item in sublist])

            np.random.shuffle(test_set)
            np.random.shuffle(train_set)
            x_train = train_set[:, 3:-1]
            y_train = train_set[:, -1]

            x_test = test_set[:, 3:-1]
            y_test = test_set[:, -1]

            final_list.append([x_train, x_test, y_train, y_test, day])

    return final_list


def generate_train_test_data(data_set, size=0.0):
    test_size = int(len(data_set) * size)
    big_test = data_set[-test_size:]
    big_training = data_set[:-test_size]

    test_set = np.array([item for sublist in big_test for item in sublist])
    training_set = np.array([item for sublist in big_training for item in sublist])

    # print('here: ' + str(training_set[0][7]))
    np.random.shuffle(test_set)
    np.random.shuffle(training_set)
    # print('here1: ' + str(training_set[0][7]))

    x_train = training_set[:, 3:-1]
    y_train = training_set[:, -1]

    x_test = test_set[:, 3:-1]
    y_test = test_set[:, -1]

    return x_train, x_test, y_train, y_test
