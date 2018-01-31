import warnings
from data_set import produce_data_set

import pandas as pd
import glob
from sklearn.grid_search import GridSearchCV

from sklearn.pipeline import Pipeline
from sklearn.pipeline import make_pipeline
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_validate
from sklearn.metrics import accuracy_score

from sklearn.svm import SVC
from sklearn.dummy import DummyClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import GradientBoostingClassifier, RandomForestClassifier

warnings.filterwarnings("ignore")

class EstimatorSelectionHelper:
    def __init__(self, models, params):
        if not set(models.keys()).issubset(set(params.keys())):
            missing_params = list(set(models.keys()) - set(params.keys()))
            raise ValueError("Some estimators are missing parameters: %s" % missing_params)
        self.models = models
        self.params = params
        self.keys = models.keys()
        self.grid_searches = {}
    
    def fit(self, X, y, cv=3, n_jobs=1, verbose=1, scoring=None, refit=False):
        for key in self.keys:
            print("\nRunning GridSearchCV for %s." % key)
            model = self.models[key]
            params = self.params[key]
            gs = GridSearchCV(model, params, cv=cv, n_jobs=n_jobs, 
                              verbose=verbose, scoring=scoring, refit=refit)
            gs.fit(X,y)
            self.grid_searches[key] = gs    
    
    def score_summary(self, sort_by='mean_score'):
        def row(key, scores, params):
            d = {
                 'estimator': key,
                 'min_score': min(scores),
                 'max_score': max(scores),
                 'mean_score': np.mean(scores),
                 'std_score': np.std(scores),
            }
            return pd.Series({**params, **d})
                      
        rows = [row(k, gsc.cv_validation_scores, gsc.parameters) 
                     for k in self.keys
                     for gsc in self.grid_searches[k].grid_scores_]
        df = pd.concat(rows, axis=1).T
        
        columns = ['estimator', 'min_score', 'mean_score', 'max_score', 'std_score']
        columns = columns + [c for c in df.columns if c not in columns]
        
        return df[columns]


PATH = '../vince_with_dates_no_skt.csv'
OUTCOME_COLUMN = 'receptivity'
START_OF_INPUT = 3
END_OF_INPUT = -1

# Read dataset
df = pd.read_csv(PATH,sep=';')

# Split into train-/ and test-set
from sklearn.model_selection import train_test_split
df_train, df_test = train_test_split(df)

# Define the input features
X_train = df_train.iloc[:,START_OF_INPUT:END_OF_INPUT]
X_test = df_test.iloc[:,START_OF_INPUT:END_OF_INPUT]

# Define the outcome feature
import numpy as np
y_train = np.where(df_train[OUTCOME_COLUMN] == 1.0, 1, 0)
y_test = np.where(df_test[OUTCOME_COLUMN] == 1.0, 1, 0)


#X_train = np.array(dataset[0])
#X_test = np.array(dataset[1])
#y_train = np.array(dataset[2])
#y_test = np.array(dataset[3])
#day = np.array(dataset[4])

models = {
	'DecisionTreeClassifier':		DecisionTreeClassifier(),
	'RandomForestClassifier':		RandomForestClassifier(),
	'KNeighborsClassifier':			KNeighborsClassifier(),
	'LogisticRegression':			LogisticRegression(),
	'GradientBoostingClassifier':	GradientBoostingClassifier()
}

params = {
	'DecisionTreeClassifier': {},
	'RandomForestClassifier': { 'n_estimators': [16, 32] },
	'KNeighborsClassifier': {},
	'LogisticRegression': {},
	'GradientBoostingClassifier':{ 'n_estimators': [16, 32], 'learning_rate': [0.8, 1.0] }
}

dataset = produce_data_set(PATH)

for d in dataset:
	print(d[1])
	x_train = d[0]
	x_test = d[1]
	y_train = d[2]
	y_test = d[3]
	day = d[4]
	print(type(x_train))
	helper = EstimatorSelectionHelper(models, params)
	helper.fit(x_train, y_train)
	print(helper.score_summary(sort_by='min_score'))



