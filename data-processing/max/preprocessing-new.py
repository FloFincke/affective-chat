# IMPORTS #
import pandas as pd #Data processing
import numpy as np #Data processing
import matplotlib.pyplot as plt #Visualization
import seaborn as sns #Visualization
import os, zipfile #Unzipping
import boto3 #AWS Download
import physi_calc #Physiological calculaction

# GLOBAL VARIABLES #
dir = os.path.dirname(os.path.realpath(__file__))
dir_name_zipped = os.path.join(dir, 'zipped/')
dir_name_unzipped = os.path.join(dir, 'unzipped/')

measurements = {}
results = []
outlierColumns = ['heartRates', 'gsr', 'rrInterval', 'skinTemperature']

def download_zips():
    BUCKET_NAME = 'affective-chat'  # replace with your bucket name

    s3 = boto3.resource('s3')
    bucket = s3.Bucket(BUCKET_NAME)

    bucket_prefix = ""  # download everything
    objs = bucket.objects.filter(Prefix=bucket_prefix)

    for object in objs:
        if (object.key.endswith('.zip')):  # download tracking data only

            path, filename = os.path.split(object.key)
            path = '{0}{1}'.format(dir_name_zipped, path)
            try:
                os.makedirs(path)
            except:
                pass
            os.chdir(path)
            bucket.download_file(object.key, str(object.key.split('/')[1]))
            os.chdir(dir)


# Unzip files from folder 'zipped' to folder 'unzipped'. 'zipped' has to be in the same directory as this script
def unzip_files():
    extension = ".zip"
    #os.chdir(dir_name_zipped)  # Change directory to zipped-folder
    for folder in os.listdir(dir_name_zipped):
        folder = '{0}/'.format(folder)
        for counter, item in enumerate(os.listdir(dir_name_zipped + folder)):  # loop through items in dir
            if item.endswith(extension):  # check for ".zip" extension
                file_name = os.path.abspath(dir_name_zipped + folder + item)
                zip_ref = zipfile.ZipFile(file_name)
                zip_ref.extractall(dir_name_unzipped)

                # rename file to prevent overwriting the previous json-file
                temp = os.listdir(dir_name_unzipped)[0]
                os.rename(dir_name_unzipped + str(temp), dir_name_unzipped + str(counter) + "_" + str(temp))

                zip_ref.close()  # close file
                os.remove(file_name) # delete zipped file


# TODO
# x 1. read jsons one by one and add to list
# x 2. fill_na for every measurement
# x 3. remove outliers
# x 4. calculate features
# 5. append to one big dataset
# 5.1 normalize
# 6. write to csv

def read_jsons(directory):
    global measurements
    for i, file in enumerate(os.listdir(directory)):
        if file.endswith(".json"):
            temp = pd.read_json(directory + file, convert_dates=False, convert_axes=False, date_unit='ms')
            temp.sort_index(inplace=True)
            measurements[file] = temp

def fill_na_and_remove_outliers():
    global measurements
    for key in measurements: # TODO: doesn't need to happen for all columns
        measurements[key].fillna(method='ffill', inplace=True) # fill NaN downwards
        measurements[key].fillna((measurements[key].mean()), inplace=True)  # fill remaining NaN upwards with mean
        measurements[key].fillna(method='bfill', inplace=True) # fill remaining NaN upwards
        measurements[key].fillna(value=-1, inplace=True)  # fill columns with no numerical value at all in it with -1
        measurements[key] = remove_outliers(measurements[key])


def calc_features():
    global measurements, results

    results = pd.DataFrame(columns=[
        'phoneId',
        'location',
        'motionType',
        'mean(SCL)',
        'mean(SCR)',
        'mean(HR)',
        'mean(RR)',
        'mean(skinTemp)',
        'mad(SCL)',
        'mad(SCR)',
        'mad(HR)',
        'mad(RR)',
        'mad(skinTemp)',
        'std(SCL)',
        'std(SCR)',
        'std(HR)',
        'std(RR)',
        'std(skinTemp)',
        'RMSSD',
        'SDNN',
        'NN50',
        'PNN50',
        'receptivity'
    ])

    for key in measurements:
        measurement = clean(measurements[key])
        print(measurement.location)

        SCL = pd.DataFrame(physi_calc.scl(measurement.gsr.tolist()))
        SCR = pd.DataFrame(physi_calc.scr(measurement.gsr.tolist()))

        # Mean values
        mSCL = SCL[0].mean()
        mSCR = SCR[0].mean()
        mHR = measurement.heartRates.mean()
        mRR = measurement.rrInterval.mean()
        mSkin = measurement.skinTemperature.mean()

        # Standard deviation
        stdSCL = SCL[0].std()
        stdSCR = SCR[0].std()
        stdHR = measurement.heartRates.std()
        stdRR = measurement.rrInterval.std()
        stdSkin = measurement.skinTemperature.std()

        # Mean absolute deviation (mad)
        madSCL = SCL[0].mad()
        madSCR = SCR[0].mad()        
        madHR = measurement.heartRates.mad()
        madRR = measurement.rrInterval.mad()
        madSkin = measurement.skinTemperature.mad()

        #RR calc
        rr_values = physi_calc.rr_calc(measurement.rrInterval.tolist())
        RMSSD = rr_values['rmssd']
        SDNN = rr_values['sdnn']
        NN50 = rr_values['nn50']
        PNN50 = rr_values['pnn50']

        #Other params
        location = measurement['location'][0] #TODO: Should be cloustered and therefore just have an ENUM or so
        motionType = measurement['motionType'][0] #TODO: Should be also just one value for the whole session. Maybe we can guess this somehow?
        receptivity = measurement['receptivity'][0]
        id = measurement['phoneId'][0]

        results.loc[-1] = [id, location, motionType, mSCL, mSCR, mHR, mRR, mSkin, madSCL, madSCR, madHR, madRR, madSkin, stdSCL, stdSCR, stdHR, stdRR, stdSkin, RMSSD, SDNN, NN50, PNN50, receptivity]
        results.index = results.index + 1  # shifting index
        results = results.sort_index()  # sorting by index

    ids = results.phoneId.unique()
    for id in ids:
        results.loc[results.phoneId == id].to_csv(str(id) + "_export.csv", sep=";", encoding="utf-8")


# Calculate the Tukey interquartile range for outlier detection
def get_iqr(dframe, columnName):
    q75, q25 = np.percentile(dframe[columnName].dropna(), [75, 25])
    iqr = q75 - q25
    min = q25 - (iqr * 1.5)
    max = q75 + (iqr * 1.5)
    return min, max

def clean(dframe):
    dframe.fillna(method='ffill', inplace=True) # fill NaN downwards
#    dframe.fillna((dframe.mean()), inplace=True)  # fill remaining NaN upwards with mean
    dframe.fillna(method='bfill', inplace=True) # fill remaining NaN upwards
    dframe.fillna(value=-1, inplace=True)  # fill columns with no numerical value at all in it with -1
    for column in dframe:        
        if (column in outlierColumns):    
            min, max = get_iqr(dframe, column)
            dframe['Outlier'] = 0
            dframe.loc[dframe[column] < min, 'Outlier'] = 1
            dframe.loc[dframe[column] > max, 'Outlier'] = 1

            for key in dframe['Outlier'].keys():
                if dframe['Outlier'][key] == 1:
                    dframe.drop(key, inplace=True)

            del dframe['Outlier'] # Remove outlier column

    return dframe

####################################################################################################################
####################################################################################################################


#download_zips()

#unzip_files()

read_jsons(dir_name_unzipped)
calc_features()
