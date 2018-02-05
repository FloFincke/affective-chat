# Affective Chat

Unser Repo

## Folder

```
.
├── affective-chat --> iOS Application
├── classifiers
│   ├── baselines.py
│   ├── controller.py
│   ├── data_set.py
│   ├── testClassifiers.py
│   └── trained_rf_model
├── data --> Backup from S3
├── data-processing
│   ├── archive --> Old files and Notebooks
│   ├── hrv --> Library used for feature generation
│   ├── loc_clustering.py --> Location clustering
│   ├── physi_calc.py --> feature generation helper functions
│   └── preprocessing_v3.py --> Preprocessing script
├── pipeline --> Automation pipeline
│   ├── a.py
│   ├── b.py
│   ├── data_set.py
│   └── preprocessing.py
├── push-server
│   ├── app-start.js --> Starts app
│   ├── app.js --> Express server
│   ├── components --> Components of the server (e.g. push, database etc.)│   
│   ├── python-backend --> Python ML Backend
│   ├── routes --> Express routes
```

## Server HOWTO

Vorher Zugangsdaten etc. von Flo holen

1. MongoDB, node etc. installieren
2. im Terminal in `push-server` navigieren
3. `npm install` laufen lassen
4. in einem neuen Terminal Fenster die MongoDB starten (`mongod` ausführen)
5. im ersten Fenster `npm run start` ausführen

## Pipline

1. run sudo pip3 install -r requirements.txt