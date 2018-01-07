#!/usr/bin/env python

#pNN50, the proportion of differences greater than 50ms

import math

def nn50(rr):
	threshold = 0.05; #50 if in milliseconds
	nn50 = 0
	i = 0
	while i < len(rr) - 1:
		if (math.fabs(rr[i] - rr[i + 1]) > threshold):
			nn50 += 1;
		i += 1
		
	return nn50

def pnn50(rr):
	return nn50(rr) / (len(rr) - 1) * 100;