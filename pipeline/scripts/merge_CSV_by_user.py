import pandas as pd
import os

userIds = {
    "5a26ff32b07e944d86d30c6b": "vince",
    "5a2b02b7b07e944d86d41969": "vince",
    "5a2fa237421a763ff2b33932": "vince",
    "5a310db8a808c47336b38d88": "vince",
    "5a4f4c70ebd4d8179239db74": "vince",
    "5a4f50cbebd4d8179239db7c": "vince",
    "5a772fb497d5175235f12d2c": "vince",
    "5a4f50cbebd4d8179239db7c": "vince",
    "5a2bf8c8b07e944d86d47ce7": "max",
    "5a3a70e3e627fc62bd42f053": "max",
}

userCSV = {
	"vince": None,
	"max": None
}

dir = os.path.dirname(os.path.realpath(__file__))
csv_path = os.path.join(dir, '../', 'CSV/')

for i, file in enumerate(os.listdir(csv_path)):
    if file.endswith(".csv"):
        temp = pd.read_csv(csv_path + file, sep = ';')
        if 'phoneId' in temp:
            user = userIds[temp['phoneId'][temp['phoneId'].first_valid_index()]]
            if userCSV[user] is None:
                userCSV[user] = temp
            else:
                userCSV[user] = userCSV[user].append(temp)

userCSV["vince"].to_csv(csv_path + "vince.csv")
userCSV["max"].to_csv(csv_path + "max.csv")