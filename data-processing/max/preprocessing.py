# IMPORTS #
import pandas as pd #Data processing
import numpy as np #Data processing
import matplotlib.pyplot as plt #Visualization
import seaborn as sns #Visualization
import os, zipfile #Unzipping


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
    plt.xlim(df[columnName].min(), df[columnName].max()*1.1)
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


# Unzip files from folder 'zipped' to folder 'unzipped'. 'zipped' has to be in the same directory as this script
dir = os.path.dirname(os.path.realpath(__file__))
dir_name = os.path.join(dir, 'zipped/')
dir_name_unzipped = os.path.join(dir, 'unzipped/')
extension = ".zip"
os.chdir(dir_name)

for counter, item in enumerate(os.listdir(dir_name)): # loop through items in dir
    if item.endswith(extension): # check for ".zip" extension
        file_name = os.path.abspath(item)
        zip_ref = zipfile.ZipFile(file_name)
        zip_ref.extractall(dir_name_unzipped)

        #rename file to prevent overwriting the previous json-file
        temp = os.listdir(dir_name_unzipped)[0]
        os.rename(dir_name_unzipped + str(temp), dir_name_unzipped + str(counter) + "_" + str(temp))

        zip_ref.close() # close file
        #os.remove(file_name) # delete zipped file


# Read data
colNames = ['receptivity', 'location', 'gsr', 'rrInterval', 'motionType', 'skinTemperature', 'heartRates']
df = pd.DataFrame([])

for file in os.listdir(dir_name_unzipped):
    if file.endswith(".json"):
        temp = pd.read_json(dir_name_unzipped + file, convert_dates=False, convert_axes=False, date_unit='ms')
        df = df.append(temp)

visualize(colNames[3]) # Visualize the value distribution and outliers of a given column. 1 = 'receptivity', 2 = 'location' ...

#df.fillna(0, inplace=True) # Replace all "NaN" with 0
