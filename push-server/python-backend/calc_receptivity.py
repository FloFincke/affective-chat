# Imports
import pandas as pd  # Data processing
import numpy as np  # Data processing
import os
import warnings
import physi_calc  # Physiological calculaction
import loc_clustering
from datetime import datetime
import sys
import json
import _pickle as cPickle

RANDOM_FOREST_MODEL = None

def receptivity(json):
    temp = pd.read_json(json)  # should be a dataframe with the rows: phoneId, gsr, heartRates, rrInterval, skinTemperature, location, motionType
    measurements = {
        'phoneId': temp['phoneId'][temp['phoneId'].first_valid_index()],
        'date': temp.index[0].date(),
        'location': temp['location'][temp['location'].first_valid_index()],
        'data': temp
    }
    tempSec = measurements['data'].resample('1S').mean()
    tempSec.sort_index(inplace=True)
    measurements['data'] = tempSec

    features = clac_features(measurements)

    #result = True if RANDOM_FOREST_MODEL.predict(features) == 1.0 else False
    result = True
    return result


def clac_features(measurements):
    raw_data = measurements['data']
    results = pd.DataFrame(columns=[
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
        'RMSSD'
    ])

    # normalized base values
    SCL = pd.DataFrame(physi_calc.scl(raw_data.gsr.tolist()))
    SCR = pd.DataFrame(physi_calc.scr(raw_data.gsr.tolist()))

    # Mean values
    mSCL = SCL[0].mean()
    mSCR = SCR[0].mean()
    mHR = raw_data.heartRates.mean()
    mRR = raw_data.rrInterval.mean()
    mSkin = raw_data.skinTemperature.mean()

    # Standard deviation
    stdSCL = SCL[0].std()
    stdSCR = SCR[0].std()
    stdHR = raw_data.heartRates.std()
    stdRR = raw_data.rrInterval.std()
    stdSkin = raw_data.skinTemperature.std()

    # Mean absolute deviation (mad)
    madSCL = SCL[0].mad()
    madSCR = SCR[0].mad()
    madHR = raw_data.heartRates.mad()
    madRR = raw_data.rrInterval.mad()
    madSkin = raw_data.skinTemperature.mad()

    # RR calc
    rri = raw_data.rrInterval.tolist()
    RMSSD = physi_calc.rmssd(rri)

    # Other params
    location = measurements['location']
    location = loc_clustering.where(measurements['phoneId'], (location['lat'], location['long']))

    motionType = raw_data.motionType.median()  # is this enough?

    return [location, motionType, mSCL, mSCR, mHR, mRR, mSkin, madSCL, madSCR, madHR, madRR, madSkin, stdSCL, stdSCR,
            stdHR, stdRR, stdSkin, RMSSD]


def read_in():
    lines = sys.stdin.readlines()
    # Since our input would only be having one line, parse our JSON data from that
    return lines[0]


def main():
    global RANDOM_FOREST_MODEL

    #with open(os.path.dirname(os.path.realpath(__file__)) + '/trained_rf_model', 'rb') as f:
    #    RANDOM_FOREST_MODEL = cPickle.load(f)

    # get our data as an array from read_in()
    lines = read_in()

    result = receptivity(lines)
    print(result)


# Start process
if __name__ == '__main__':
    main()