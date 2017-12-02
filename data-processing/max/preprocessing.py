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


def downloadZips():
    BUCKET_NAME = 'affective-chat'  # replace with your bucket name

    s3 = boto3.resource('s3')
    bucket = s3.Bucket(BUCKET_NAME)

    bucket_prefix = ""  # download everything
    objs = bucket.objects.filter(Prefix=bucket_prefix)

    for object in objs:
        print(object.key.split('/'))
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
def unzipFiles():
    extension = ".zip"
    #os.chdir(dir_name_zipped)  # Change directory to zipped-folder
    for folder in os.listdir(dir_name_zipped):
        folder = '{0}/'.format(folder)
        for counter, item in enumerate(os.listdir(dir_name_zipped + folder)):  # loop through items in dir
            print(item)
            if item.endswith(extension):  # check for ".zip" extension
                file_name = os.path.abspath(folder + item)
                zip_ref = zipfile.ZipFile(file_name)
                zip_ref.extractall(dir_name_unzipped)

                # rename file to prevent overwriting the previous json-file
                temp = os.listdir(dir_name_unzipped)[0]
                os.rename(dir_name_unzipped + str(temp), dir_name_unzipped + str(counter) + "_" + str(temp))

                zip_ref.close()  # close file
                # os.remove(file_name) # delete zipped file

def readJSONS(directory):
    global df
    for file in os.listdir(directory):
        if file.endswith(".json"):
            temp = pd.read_json(directory + file, convert_dates=False, convert_axes=False, date_unit='ms')
            df = df.append(temp)
    df.sort_index(inplace=True) # Sort by timestamps

def findMinMax():
    global df


# Calculate the Tukey interquartile range for outlier detection
def getIqrMinMax(columnName):
    q75, q25 = np.percentile(df[columnName].dropna(), [75, 25])
    iqr = q75 - q25
    min = q25 - (iqr * 1.5)
    max = q75 + (iqr * 1.5)
    return min, max

# Detect outliers in a specific column of the dataset and plot the results
def visualize(columnName):
    min, max = getIqrMinMax(columnName)

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


downloadZips()

unzipFiles()

readJSONS(dir_name_unzipped)

findMinMax()


#visualize(colNames[3]) # Visualize the value distribution and outliers of a given column. 1 = 'receptivity', 2 = 'location' ...

#df.fillna(0, inplace=True) # Replace all "NaN" with 0
