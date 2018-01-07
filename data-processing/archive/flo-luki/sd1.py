#!/usr/bin/env python

import math
import numpy as np

def sd1(rr):
	sdnn = np.std(rr)
	return math.sqrt(0.5 * sdnn * sdnn)