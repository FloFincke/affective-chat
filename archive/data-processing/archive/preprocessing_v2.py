# IMPORTS #
import pandas as pd #Data processing
import numpy as np #Data processing
import matplotlib.pyplot as plt #Visualization
import seaborn as sns #Visualization
import os, zipfile #Unzipping
import boto3 #AWS Download
import physi_calc #Physiological calculaction
import loc_clustering
# GLOBAL VARIABLES #
dir = os.path.dirname(os.path.realpath(__file__))
dir_name_zipped = os.path.join(dir, 'zipped/')
dir_name_unzipped = os.path.join(dir, 'unzipped/')

measurements = {}
results = []
normalizeColumns = ['mSCL', 'mSCR', 'mHR', 'mRR', 'mSkin', 'madSCL', 'madSCR', 'madHR', 'madRR', 'madSkin', 'stdSCL', 'stdSCR', 'stdHR', 'stdRR', 'stdSkin', 'RMSSD', 'LF', 'HF', 'LFHF']

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
            temp = pd.read_json(directory + file)
            measurements[file] = {
                'phoneId': temp['phoneId'][temp['phoneId'].first_valid_index()],
                'location': temp['location'][temp['location'].first_valid_index()],
                'receptivity': temp['receptivity'][temp['receptivity'].first_valid_index()],
                'data': temp.drop('receptivity', 1)
            }
            if measurements[file]['data']['gsr'].count() > 100:
                tempSec = measurements[file]['data'].resample('1S').mean()
                tempSec.sort_index(inplace=True)
                measurements[file]['data'] = tempSec

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
        'LF',
        'HF',
        'LF/HF',
        'receptivity'
    ])

    for key in measurements:
        measurement = clean(measurements[key]['data'])

        for i in range(0, len(measurement.index)):
            if i + 30 <= len(measurement.index):
                window = measurement.iloc[i:i+30]

                #normalized base values
                SCL = pd.DataFrame(physi_calc.scl(window.gsr.tolist()))
                SCR = pd.DataFrame(physi_calc.scr(window.gsr.tolist()))

                # Mean values
                mSCL = SCL[0].mean()
                mSCR = SCR[0].mean()
                mHR = window.heartRates.mean().item()
                mRR = window.rrInterval.mean().item()
                mSkin = window.skinTemperature.mean().item()

                # Standard deviation
                stdSCL = SCL[0].std()
                stdSCR = SCR[0].std()
                stdHR = window.heartRates.std().item()
                stdRR = window.rrInterval.std().item()
                stdSkin = window.skinTemperature.std().item()

                # Mean absolute deviation (mad)
                madSCL = SCL[0].mad()
                madSCR = SCR[0].mad()        
                madHR = window.heartRates.mad().item()
                madRR = window.rrInterval.mad().item()
                madSkin = window.skinTemperature.mad().item()

                #RR calc
                rri = window.rrInterval.tolist()
                RMSSD = physi_calc.rmssd(rri)
                freq = physi_calc.freq(rri)
                LF = freq['lf']
                HF = freq['hf']
                LFHF = freq['lf_hf']

                #Other params
                id = measurements[key]['phoneId']

                location = measurements[key]['location']
                location = loc_clustering.where(id, (location['lat'], location['long']))

                motionType = measurement.motionType.median() # is this enough?

                receptivity = measurements[key]['receptivity']
                if(receptivity == 0):
                    receptivity = -1

                results.loc[-1] = [id, location, motionType, mSCL, mSCR, mHR, mRR, mSkin, madSCL, madSCR, madHR, madRR, madSkin, 
                    stdSCL, stdSCR, stdHR, stdRR, stdSkin, RMSSD, LF, HF, LFHF, receptivity]
                results.index = results.index + 1  # shifting index
                print('.', sep=' ', end='', flush=True)

    results = results.sort_index()  # sorting by index
    outputCSV(results)

def outputCSV(results):
    ids = results.phoneId.unique()
    for id in ids:
        output = results.loc[results.phoneId == id]
        for column in normalizeColumns:
            output[column] = pd.DataFrame(normalizeList(output[column].tolist()))
        output.to_csv(str(id) + "_export.csv", sep=";", encoding="utf-8")

# Calculate the Tukey interquartile range for outlier detection
def get_iqr(dframe, columnName):
    q75, q25 = np.percentile(dframe[columnName].dropna(), [75, 25])
    iqr = q75 - q25
    min = q25 - (iqr * 1.5)
    max = q75 + (iqr * 1.5)
    return min, max

def clean(dframe):
    for column in dframe:        
        dframe.fillna(method='ffill', inplace=True) # fill NaN downwards
    #    dframe.fillna((dframe.mean()), inplace=True)  # fill remaining NaN upwards with mean
        dframe.fillna(method='bfill', inplace=True) # fill remaining NaN upwards
        dframe.fillna(value=-1, inplace=True)  # fill columns with no numerical value at all in it with -1
        min, max = get_iqr(dframe, column)
        dframe['Outlier'] = 0
        dframe.loc[dframe[column] < min, 'Outlier'] = 1
        dframe.loc[dframe[column] > max, 'Outlier'] = 1

        for key in dframe['Outlier'].keys():
            if dframe['Outlier'][key] == 1:
                dframe.drop(key, inplace=True)

        del dframe['Outlier'] # Remove outlier column

    return dframe

def normalizeList(inputList):
    nlist = []
    maxList = max(inputList)
    minList = min(inputList)
    meanList = np.mean([maxList,minList])

    for i in range(0, len(inputList)-1):
        nlist.append((inputList[i]-meanList)/meanList)

    return nlist

####################################################################################################################
####################################################################################################################


#download_zips()

#unzip_files()

read_jsons(dir_name_unzipped)
calc_features()
