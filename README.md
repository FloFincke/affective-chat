```
WWWWWWWW                           WWWWWWWW iiii          tttt         hhhhhhh                  LLLLLLLLLLL                                                                       !!!
W::::::W                           W::::::Wi::::i      ttt:::t         h:::::h                  L:::::::::L                                                                      !!:!!
W::::::W                           W::::::W iiii       t:::::t         h:::::h                  L:::::::::L                                                                      !:::!
W::::::W                           W::::::W            t:::::t         h:::::h                  LL:::::::LL                                                                      !:::!
 W:::::W           WWWWW           W:::::Wiiiiiiittttttt:::::ttttttt    h::::h hhhhh              L:::::L                  ooooooooooo vvvvvvv           vvvvvvv eeeeeeeeeeee    !:::!
  W:::::W         W:::::W         W:::::W i:::::it:::::::::::::::::t    h::::hh:::::hhh           L:::::L                oo:::::::::::oov:::::v         v:::::vee::::::::::::ee  !:::!
   W:::::W       W:::::::W       W:::::W   i::::it:::::::::::::::::t    h::::::::::::::hh         L:::::L               o:::::::::::::::ov:::::v       v:::::ve::::::eeeee:::::ee!:::!
    W:::::W     W:::::::::W     W:::::W    i::::itttttt:::::::tttttt    h:::::::hhh::::::h        L:::::L               o:::::ooooo:::::o v:::::v     v:::::ve::::::e     e:::::e!:::!
     W:::::W   W:::::W:::::W   W:::::W     i::::i      t:::::t          h::::::h   h::::::h       L:::::L               o::::o     o::::o  v:::::v   v:::::v e:::::::eeeee::::::e!:::!
      W:::::W W:::::W W:::::W W:::::W      i::::i      t:::::t          h:::::h     h:::::h       L:::::L               o::::o     o::::o   v:::::v v:::::v  e:::::::::::::::::e !:::!
       W:::::W:::::W   W:::::W:::::W       i::::i      t:::::t          h:::::h     h:::::h       L:::::L               o::::o     o::::o    v:::::v:::::v   e::::::eeeeeeeeeee  !!:!!
        W:::::::::W     W:::::::::W        i::::i      t:::::t    tttttth:::::h     h:::::h       L:::::L         LLLLLLo::::o     o::::o     v:::::::::v    e:::::::e            !!!
         W:::::::W       W:::::::W        i::::::i     t::::::tttt:::::th:::::h     h:::::h     LL:::::::LLLLLLLLL:::::Lo:::::ooooo:::::o      v:::::::v     e::::::::e
          W:::::W         W:::::W         i::::::i     tt::::::::::::::th:::::h     h:::::h     L::::::::::::::::::::::Lo:::::::::::::::o       v:::::v       e::::::::eeeeeeee   !!!
           W:::W           W:::W          i::::::i       tt:::::::::::tth:::::h     h:::::h     L::::::::::::::::::::::L oo:::::::::::oo         v:::v         ee:::::::::::::e  !!:!!
            WWW             WWW           iiiiiiii         ttttttttttt  hhhhhhh     hhhhhhh     LLLLLLLLLLLLLLLLLLLLLLLL   ooooooooooo            vvv            eeeeeeeeeeeeee   !!!

```   

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
│   ├── data --> CSV files with raw data
│   ├── scripts
│   │   ├── custom-transformers.py --> Transformers for pipeline
│   │   ├── loc_clustering.py --> cluster users most important locations
│   │   ├── physi_calc.py --> feature generation helper functions
│   │   ├── prepare_data.py --> Create a dataframe from input csv-file
│   │   └── preprocessing.py --> Create csv-file from raw data (1 per user)
│   ├── unzipped
│   └── main.py --> Script that starts pipeline and creates trained model 
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
2. python3 pipeline/main.py
