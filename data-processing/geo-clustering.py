from geopy.distance import vincenty
from enum import Enum

class Locations(Enum):
	HOME = 1
	WORK = 2
	UNI = 3
	UNI2 = 4
	GIRLFRIEND = 5
	OUTSIDE = 6

locationsOrder = [Locations.HOME, Locations.WORK, Locations.UNI, Locations.UNI2, Locations.GIRLFRIEND]

homes = {
	# Vince
	"5a26ff32b07e944d86d30c6b": [(48.149348, 11.575510), (48.145757, 11.579653), (48.150150, 11.594123), (0,0), (48.149268, 11.561927)],
	"5a2b02b7b07e944d86d41969": [(48.149348, 11.575510), (48.145757, 11.579653), (48.150150, 11.594123), (0,0), (48.149268, 11.561927)],
	"5a2fa237421a763ff2b33932": [(48.149348, 11.575510), (48.145757, 11.579653), (48.150150, 11.594123), (0,0), (48.149268, 11.561927)],
	"5a310db8a808c47336b38d88": [(48.149348, 11.575510), (48.145757, 11.579653), (48.150150, 11.594123), (0,0), (48.149268, 11.561927)],

	# Max
	"5a2bf8c8b07e944d86d47ce7": [(48.108183, 11.601069), (48.090051, 11.649915), (48.149501, 11.594165), (48.147224, 11.576588), (0,0)],
	"5a3a70e3e627fc62bd42f053": [(48.108183, 11.601069), (48.090051, 11.649915), (48.149501, 11.594165), (48.147224, 11.576588), (0,0)],
}


def where(id, location):
	for i, loc in enumerate(homes[id]):
		if(vincenty(location, loc).km < 1.0):
			return locationsOrder[i]

	return Locations.OUTSIDE




print(where("5a26ff32b07e944d86d30c6b", (48.149347, 11.575511)))