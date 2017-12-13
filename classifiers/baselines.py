from sklearn import tree
from keras.models import Sequential
from keras.layers import Dense


class Classifier:
    def __init__(self, hidden_size_little_nn, input_dim_little_nn, hidden_size_large_nn, input_dim_large_nn):
        self.decision_tree = self.create_decision_tree()
        self.little_nn = self.create_little_nn(hidden_size_little_nn, input_dim_little_nn)
        self.large_nn = self.create_large_nn(hidden_size_large_nn, input_dim_large_nn)

    # Creates the Decision Tree from Sklearn
    @staticmethod
    def create_decision_tree():
        return tree.DecisionTreeClassifier()

    # Creates the little NN
    @staticmethod
    def create_little_nn(hidden_size, input_size):
        # create model
        model = Sequential()
        model.add(Dense(hidden_size, input_dim=input_size, kernel_initializer='normal', activation='relu'))
        model.add(Dense(1, kernel_initializer='normal', activation='sigmoid'))  # Just one output (-1 or 1)
        # Compile model
        model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
        return model

    # Creates the large model
    @staticmethod
    def create_large_nn(hidden_size, input_size):
        # create model
        model = Sequential()
        model.add(Dense(hidden_size, input_dim=input_size, kernel_initializer='normal', activation='relu'))
        model.add(Dense(int(hidden_size/2), kernel_initializer='normal', activation='relu'))
        model.add(Dense(1, kernel_initializer='normal', activation='sigmoid'))
        # Compile model
        model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
        return model
