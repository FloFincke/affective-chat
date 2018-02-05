# Remarks
#
# Download is don manually via a S3 client -> no more get requests
# Unzipping can be done without a script and should be done in the folders based on the id,
# so we dont build one big dataframe with allllll the dataaaa
#

import os
import warnings

import numpy as np  # Data processing
# IMPORTS #
import pandas as pd  # Data processing

from . import loc_clustering
from . import physi_calc  # Physiological calculaction

warnings.filterwarnings("ignore")

# GLOBAL VARIABLES #
current_dir = os.path.dirname(os.path.realpath(__file__))
dir_name_unzipped = os.path.join(current_dir, '../unzipped/')


def run_preprocessing(sliding_window_size):
    for folder in os.listdir(dir_name_unzipped):
        folder = '{0}/'.format(folder)
        measurements = {}
        for i, file in enumerate(os.listdir(dir_name_unzipped + folder)):
            if file.endswith(".json"):
                temp = pd.read_json(dir_name_unzipped + folder + file)
                measurements[i] = {
                    'phoneId': temp['phoneId'][temp['phoneId'].first_valid_index()],
                    'date': temp.index[0].date(),
                    'location': temp['location'][temp['location'].first_valid_index()],
                    'receptivity': temp['receptivity'][temp['receptivity'].first_valid_index()],
                    'data': temp.drop('receptivity', 1)
                }
                if measurements[i]['data']['gsr'].count() > 100:
                    temp_sec = measurements[i]['data'].resample('1S').mean()
                    temp_sec.sort_index(inplace=True)
                    measurements[i]['data'] = temp_sec

        calc_features(measurements, sliding_window_size)


def calc_features(measurements, sliding_window_size):
    results = pd.DataFrame(columns=[
        'phoneId',
        'date',
        'measurementId',
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
        'receptivity'
    ])

    for key in measurements:
        measurement = clean(measurements[key]['data'])

        for i in range(0, len(measurement.index)):
            if i + sliding_window_size <= len(measurement.index):
                window = measurement.iloc[i:i + 30]

                # normalized base values
                SCL = pd.DataFrame(physi_calc.scl(window.gsr.tolist()))
                SCR = pd.DataFrame(physi_calc.scr(window.gsr.tolist()))

                # Mean values
                mSCL = SCL[0].mean()
                mSCR = SCR[0].mean()
                mHR = window.heartRates.mean()
                mRR = window.rrInterval.mean()
                mSkin = window.skinTemperature.mean()

                # Standard deviation
                stdSCL = SCL[0].std()
                stdSCR = SCR[0].std()
                stdHR = window.heartRates.std()
                stdRR = window.rrInterval.std()
                stdSkin = window.skinTemperature.std()

                # Mean absolute deviation (mad)
                madSCL = SCL[0].mad()
                madSCR = SCR[0].mad()
                madHR = window.heartRates.mad()
                madRR = window.rrInterval.mad()
                madSkin = window.skinTemperature.mad()

                # RR calc
                rri = window.rrInterval.tolist()
                RMSSD = physi_calc.rmssd(rri)

                # Other params
                id = measurements[key]['phoneId']
                date = measurements[key]['date']

                location = measurements[key]['location']
                location = loc_clustering.where(id, (location['lat'], location['long']))

                motionType = measurement.motionType.median()  # is this enough?

                receptivity = measurements[key]['receptivity']
                if (receptivity == 0):
                    receptivity = -1

                results.loc[-1] = [id, date, key, location, motionType, mSCL, mSCR, mHR, mRR, mSkin, madSCL, madSCR,
                                   madHR, madRR, madSkin,
                                   stdSCL, stdSCR, stdHR, stdRR, stdSkin, RMSSD, receptivity]
                results.index = results.index + 1  # shifting index
                print('.', sep=' ', end='', flush=True)

    results = results.sort_index()  # sorting by index
    outputCSV(results)
    print(' saved ' + results['phoneId'][0] + '! ')


def outputCSV(results):
    for column in results:
        if column not in ['phoneId', 'date', 'measurementId', 'location', 'motionType', 'receptivity']:
            results[column] = pd.DataFrame(results[column].tolist())

    results.to_csv(results['phoneId'][0] + "_export.csv", sep=";", encoding="utf-8")


# Calculate the Tukey interquartile range for outlier detection
def get_iqr(dframe, columnName):
    q75, q25 = np.percentile(dframe[columnName].dropna(), [75, 25])
    iqr = q75 - q25
    min = q25 - (iqr * 1.5)
    max = q75 + (iqr * 1.5)
    return min, max


def clean(dframe):
    for column in dframe:
        dframe.fillna(method='ffill', inplace=True)  # fill NaN downwards
        #    dframe.fillna((dframe.mean()), inplace=True)  # fill remaining NaN upwards with mean
        dframe.fillna(method='bfill', inplace=True)  # fill remaining NaN upwards
        dframe.fillna(value=-1, inplace=True)  # fill columns with no numerical value at all in it with -1
        min, max = get_iqr(dframe, column)
        dframe['Outlier'] = 0
        dframe.loc[dframe[column] < min, 'Outlier'] = 1
        dframe.loc[dframe[column] > max, 'Outlier'] = 1

        for key in dframe['Outlier'].keys():
            if dframe['Outlier'][key] == 1:
                dframe.drop(key, inplace=True)

        del dframe['Outlier']  # Remove outlier column

    return dframe

####################################################################################################################
####################################################################################################################

# runPreprocessing()
