from sklearn import tree
from sklearn.ensemble import RandomForestClassifier


class Classifier:
    def __init__(self):
        self.decision_tree = self.create_decision_tree()
        self.random_forest = self.create_random_forest(n_jobs=2, state=0)

    # Creates the Decision Tree from Sklearn
    @staticmethod
    def create_decision_tree():
        return tree.DecisionTreeClassifier()

    # Creates the Random Forest
    @staticmethod
    def create_random_forest(n_jobs, state):
        return RandomForestClassifier(n_jobs=n_jobs, random_state=state)
