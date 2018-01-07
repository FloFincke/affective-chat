import glob
import pandas as pd
from sklearn.model_selection import train_test_split


def produce_data_set(path):
    data_sets_files = glob.glob(path)

    data_set = (pd.concat((pd.read_csv(f, sep=';', header=0) for f in data_sets_files))).values

    x_train, x_test, y_train, y_test = train_test_split(
        data_set[:, 2:-1],
        data_set[:, -1],
        test_size=0.2, random_state=87)

    return x_train, x_test, y_train, y_test
