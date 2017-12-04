# IMPORTS #
import pandas as pd #Data processing
import numpy as np #Data processing
import matplotlib.pyplot as plt #Visualization
import seaborn as sns #Visualization
import os, zipfile #Unzipping
import boto3 #AWS Download

# GLOBAL VARIABLES #
dir = os.path.dirname(os.path.realpath(__file__))
dir_name_zipped = os.path.join(dir, 'zipped/')
dir_name_unzipped = os.path.join(dir, 'unzipped/')

colNames = ['receptivity', 'location', 'gsr', 'rrInterval', 'motionType', 'skinTemperature', 'heartRates']
df = pd.DataFrame([])
df_equidistant = pd.DataFrame(columns=['phoneId', 'location', 'heartRate', 'gsr', 'rrInterval', 'motionType', 'skinTemp', 'mean(GSR)', 'mean(HR)', 'mean(RR)', 'mean(skinTemp)', 'std(GSR)', 'std(HR)', 'std(RR)', 'std(skinTemp)'])


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
            bucket.download_file(object.key, object.key)
            os.chdir(dir)


# Unzip files from folder 'zipped' to folder 'unzipped'. 'zipped' has to be in the same directory as this script
def unzip_files():
    extension = ".zip"
    #os.chdir(dir_name_zipped)  # Change directory to zipped-folder
    for folder in os.listdir(dir_name_zipped):
        folder = '{0}/'.format(folder)
        for counter, item in enumerate(os.listdir(dir_name_zipped + folder)):  # loop through items in dir
            if item.endswith(extension):  # check for ".zip" extension
                file_name = os.path.abspath(folder + item)
                zip_ref = zipfile.ZipFile(file_name)
                zip_ref.extractall(dir_name_unzipped)

                # rename file to prevent overwriting the previous json-file
                temp = os.listdir(dir_name_unzipped)[0]
                os.rename(dir_name_unzipped + str(temp), dir_name_unzipped + str(counter) + "_" + str(temp))

                zip_ref.close()  # close file
                # os.remove(file_name) # delete zipped file


def read_jsons(directory):
    global df
    for file in os.listdir(directory):
        if file.endswith(".json"):
            temp = pd.read_json(directory + file, convert_dates=False, convert_axes=False, date_unit='ms')
            df = df.append(temp)
    df.sort_index(inplace=True) # Sort by timestamps


def fill_na():
    global df
    df.fillna(method='ffill', inplace=True) # fill NaN downwards
    df.fillna((df.mean()), inplace=True)  # fill remaining NaN upwards with mean
    df.fillna(method='bfill', inplace=True) # fill remaining NaN upwards


def calc_new_columns():
    global df, df_equidistant
    timestep = 5000

    phoneIds = df.phoneId.unique() # Get all registered phoneIds

    for id in phoneIds: # Don't mix users just yet
        temp = df.loc[(df['phoneId'] == id)]
        start = temp.index.values[0]
        customIndex = 0
        temp_equidist = pd.DataFrame([])

        # Max values for user
        maxGSR = temp.gsr.max()
        maxHR = temp.heartRates.max()
        maxSkintemp = temp.skinTemperature.max()
        maxRRInterval = temp.rrInterval.max()

        for timestamp in temp.index.values:
            if int(timestamp) <= int(start) + timestep: # Combine measurements within a n-milliseconds (= timestep) timeframe
                temp_equidist = temp_equidist.append(temp.ix[timestamp])
            else:
                motionType = temp_equidist.motionType.mode()[0] # Most frequent value in time range

                # Percentage of max values
                GSR = temp_equidist.gsr.mean()/maxGSR
                HR = temp_equidist.heartRates.mean()/maxHR
                RR = temp_equidist.rrInterval.mean()/maxRRInterval
                Skin = temp_equidist.skinTemperature.mean()/maxSkintemp

                # Mean values
                mGSR = temp_equidist.gsr.mean()
                mHR = temp_equidist.heartRates.mean()
                mRR = temp_equidist.rrInterval.mean()
                mSkin = temp_equidist.skinTemperature.mean()

                # Standard deviation
                stdGSR = temp_equidist.gsr.std()
                stdHR = temp_equidist.heartRates.std()
                stdRR = temp_equidist.rrInterval.std()
                stdSkin = temp_equidist.skinTemperature.std()

                # Set values in dataframe
                df_equidistant.set_value(customIndex, 'phoneId', temp.ix[timestamp].phoneId)
                df_equidistant.set_value(customIndex, 'location', temp.ix[timestamp].location)
                df_equidistant.set_value(customIndex, 'heartRate', HR)
                df_equidistant.set_value(customIndex, 'gsr', GSR)
                df_equidistant.set_value(customIndex, 'rrInterval', RR)
                df_equidistant.set_value(customIndex, 'motionType', motionType)
                df_equidistant.set_value(customIndex, 'skinTemp', Skin)
                df_equidistant.set_value(customIndex, 'mean(GSR)', mGSR)
                df_equidistant.set_value(customIndex, 'mean(HR)', mHR)
                df_equidistant.set_value(customIndex, 'mean(RR)', mRR)
                df_equidistant.set_value(customIndex, 'mean(skinTemp)', mSkin)
                df_equidistant.set_value(customIndex, 'std(GSR)', stdGSR)
                df_equidistant.set_value(customIndex, 'std(HR)', stdHR)
                df_equidistant.set_value(customIndex, 'std(RR)', stdRR)
                df_equidistant.set_value(customIndex, 'std(skinTemp)', stdSkin)

                # Reset
                temp_equidist = temp_equidist.iloc[0:0]
                start = timestamp
                customIndex += timestep # Update index

    # Export omnidistant dataframe to json
    #out = df_omnidistant.to_json(orient='records')
    #with open('export.json', 'w') as f:
    #    f.write(out)
    print (df_equidistant[:10])


# Calculate the Tukey interquartile range for outlier detection
def get_iqr(columnName):
    q75, q25 = np.percentile(df[columnName].dropna(), [75, 25])
    iqr = q75 - q25
    min = q25 - (iqr * 1.5)
    max = q75 + (iqr * 1.5)
    return min, max


# Detect outliers in a specific column of the dataset and plot the results
def visualize(columnName):
    min, max = get_iqr(columnName)

    # Chart
    plt.figure(figsize=(10, 8))
    plt.subplot(211)
    plt.xlim(df[columnName].min(), df[columnName].max() * 1.1)
    plt.axvline(x=min)
    plt.axvline(x=max)
    ax = df[columnName].plot(kind='kde')

    # Boxplot
    plt.subplot(212)
    plt.xlim(df[columnName].min(), df[columnName].max() * 1.1)
    sns.boxplot(x=df[columnName])
    plt.axvline(x=min)
    plt.axvline(x=max)

    df['Outlier'] = 0
    df.loc[df[columnName] < min, 'Outlier'] = 1
    df.loc[df[columnName] > max, 'Outlier'] = 1

    # Print timestamps of outliers in this particular column
    for key in df['Outlier'].keys():
        if df['Outlier'][key] == 1:
            print(key)

    plt.show()


####################################################################################################################
####################################################################################################################


download_zips()

unzip_files()

read_jsons(dir_name_unzipped)

fill_na()

calc_new_columns()


#visualize(colNames[3]) # Visualize the value distribution and outliers of a given column. 1 = 'receptivity', 2 = 'location' ...

#df.fillna(0, inplace=True) # Replace all "NaN" with 0
