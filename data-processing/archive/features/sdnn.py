#!/usr/bin/env python

#SDNN, the standard deviation of intervals between heartbeats

import math
import numpy as np

def sdnn(rr):
	return np.std(rr)