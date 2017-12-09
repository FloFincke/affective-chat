#!/usr/bin/env python

from hrv.classical import time_domain
import numpy as np
import math

def scl(gsr):
	scl = []
	
	for i in range(0, len(gsr)):
		meanList = []

		#avoid null pointer
		for j in range(-2,3):
			if i+j>=0 and i+j<=len(gsr)-1:
				meanList.append(gsr[i+j])
				
		mean = np.mean([meanList])
		scl.append(mean)

	return(scl)

def scr(gsr):
	scr = []
	
	for i in range(0, len(gsr)):
		meanList = []

		#avoid null pointer
		for j in range(-2,3):
			if i+j>=0 and i+j<=len(gsr)-1:
				meanList.append(gsr[i+j])
				
		mean = np.mean([meanList])
		scrVal = np.sqrt((gsr[i]-mean)**2)
		scr.append(scrVal)

	return(scr)		


def rr_calc(rr):
	results = time_domain(rr)
	return(results)