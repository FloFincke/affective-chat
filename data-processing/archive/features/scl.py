def sclScr(list):
	scl = []
	scr = []
	
	for i in range(0, len(list)):
		meanList = []

		#avoid null pointer
		for j in range(-2,3):
			if i+j>=0 and i+j<=len(list)-1:
				meanList.append(list[i+j])
				
		mean = np.mean([meanList])
		scl.append(mean)

	return(scl)		