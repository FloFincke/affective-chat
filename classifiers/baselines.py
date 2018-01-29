from sklearn import tree
from sklearn.ensemble import RandomForestClassifier
from sklearn.dummy import DummyClassifier


class Classifier:
    def __init__(self):
        self.decision_tree = self.create_decision_tree()
        self.random_forest = self.create_random_forest(n_jobs=-1, state=0, max_features=10)  # 'auto'
        self.dummy_stratified = self.create_dummy_classifier(strategy='stratified')
        self.dummy_most_frequent = self.create_dummy_classifier(strategy='most_frequent')
        self.dummy_prior = self.create_dummy_classifier(strategy='prior')
        self.dummy_uniform = self.create_dummy_classifier(strategy='uniform')
        self.dummy_constant = self.create_dummy_classifier(strategy='constant', constant=1.0)

    # Creates the Decision Tree from Sklearn
    @staticmethod
    def create_decision_tree():
        return tree.DecisionTreeClassifier()

    # Creates the Random Forest
    @staticmethod
    def create_random_forest(n_jobs, state, max_features):
        return RandomForestClassifier(n_jobs=n_jobs, random_state=state, max_features=max_features)

    # Creates the Dummy Classifier
    @staticmethod
    def create_dummy_classifier(strategy, constant=None):
        if strategy == 'constant':
            return DummyClassifier(strategy=strategy, constant=constant)
        return DummyClassifier(strategy=strategy)
