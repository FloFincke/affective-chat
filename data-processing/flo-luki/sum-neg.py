def sumNeg(list): #list needs to be normalized
	nsum = 0
	for i in range(0,len(list)):
		if list[i]<0:
			nsum -= list[i] 

	return -nsum