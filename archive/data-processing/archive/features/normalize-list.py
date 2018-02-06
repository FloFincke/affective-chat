def normalizeList(list):
	nlist = []
	maxList = max(list)
	minList = min(list)
	meanList = np.mean([maxList,minList])

	for i in range(0, len(list)-1):
		nlist.append((list[i]-meanList)/meanList)

	return nlist