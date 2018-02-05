import numpy as np
from hrv.classical import frequency_domain


def scl(gsr):
    scl = []

    for i in range(0, len(gsr)):
        meanList = []

        # avoid null pointer
        for j in range(-2, 3):
            if 0 <= i + j <= len(gsr) - 1:
                meanList.append(gsr[i + j])

        mean = np.mean([meanList])
        scl.append(mean)

    return (scl)


def scr(gsr):
    scr = []

    for i in range(0, len(gsr)):
        meanList = []

        # avoid null pointer
        for j in range(-2, 3):
            if 0 <= i + j <= len(gsr) - 1:
                meanList.append(gsr[i + j])

        mean = np.mean([meanList])
        scrVal = np.sqrt((gsr[i] - mean) ** 2)
        scr.append(scrVal)

    return (scr)


def rmssd(rr):
    sum = 0

    for i in range(1, len(rr) - 1):
        sum += (rr[i - 1] - rr[i]) * (rr[i - 1] - rr[i])

    return np.sqrt(sum / (len(rr) - 1))


def baevsky(rr):
    mode = 0
    maxCount = 0

    for anA in rr:
        count = 0
        for anA1 in rr:

            # Because the elements are of floating point precision they are
            # almost never the same.
            # Therefore they have to be in a certain range.
            if not ((anA1 > anA * 1.05) or (anA1 < anA * 0.95)):
                count += 1

        if count > maxCount:
            maxCount = count
            mode = anA

    counter = 0
    for aRrinterval in rr:
        if not ((aRrinterval > mode * 1.05) or (aRrinterval < mode * 0.95)):
            counter += 1

    amplitudeMode = counter / len(rr)

    mxdmn = max(rr) - min(rr)

    return amplitudeMode / (2 * mode * mxdmn)


def freq(rr):
    return frequency_domain(
        rri=rr,
        fs=1.0,
        method='welch',
        interp_method='cubic',
        detrend='linear'
    )
