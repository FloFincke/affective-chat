import glob
import pandas as pd
from itertools import groupby
from operator import itemgetter
import numpy as np


def produce_data_set(path):
    data_sets_files = glob.glob(path)

    data_set = (pd.concat((pd.read_csv(f, sep=';', header=0) for f in data_sets_files))).values

    data_set = [list(g) for k, g in groupby(data_set, key=itemgetter(2))]

    np.random.shuffle(data_set)

    x_train, x_test, y_train, y_test = generate_train_test_data(data_set, size=0.1)

    return x_train, x_test, y_train, y_test


def generate_train_test_data(data_set, size=0.0):
    test_size = int(len(data_set) * size)
    big_test = data_set[-test_size:]
    big_training = data_set[:-test_size]

    test_set = np.array([item for sublist in big_test for item in sublist])
    training_set = np.array([item for sublist in big_training for item in sublist])

    np.random.shuffle(test_set)
    np.random.shuffle(training_set)

    x_train = training_set[:, 3:-1]
    y_train = training_set[:, -1]

    x_test = test_set[:, 3:-1]
    y_test = test_set[:, -1]

    return x_train, x_test, y_train, y_test
