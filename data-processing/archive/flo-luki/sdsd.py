#!/usr/bin/env python

#SDSD, the standard deviation of successive differences between adjacent R-R intervals

import math
import numpy as np

def sdsd(rr):
	rrdiff = []
		
	for i in range(1, len(rr) - 1):
		rrdiff.append(rr[i - 1] - rr[i]);
	
	return np.std(rrdiff)
	