#!/usr/bin/env python

import math
import numpy as np

def sd2(rr):
	rrdiff = []
		
	for i in range(1, len(rr) - 1):
		rrdiff.append(rr[i - 1] - rr[i]);
	
	sdsd = np.std(rrdiff)
	sdnn = np.std(rr)
	
	val = 2 * sdsd * sdsd - 0.5 * sdnn * sdnn
	
	return math.sqrt(val)