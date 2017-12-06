from hrv.classical import frequency_domain
from hrv.utils import open_rri

rri = [0.116144, 0.8793759999999999, 0.813008, 0.8296, 0.8793759999999999, 0.862784, 0.813008, 0.8461919999999999, 0.813008, 0.796416, 0.779824, 0.813008, 0.796416, 0.9125599999999999, 0.713456, 0.74664, 0.796416, 0.796416, 0.796416, 0.8461919999999999, 0.8793759999999999, 0.895968, 0.895968, 0.895968, 0.929152, 0.962336, 0.680272, 0.779824, 0.74664, 0.7300479999999999, 0.7632319999999999, 0.8296, 0.862784, 0.813008, 1.1448479999999999, 0.7632319999999999, 0.713456, 0.862784, 0.813008, 0.813008, 0.779824, 0.7632319999999999, 0.813008, 0.862784, 0.9125599999999999, 0.9457439999999999, 0.9789279999999999, 0.8461919999999999, 0.779824, 0.779824, 0.779824, 0.8296, 0.8296, 0.8461919999999999, 0.8793759999999999, 0.962336, 0.8793759999999999, 0.7300479999999999, 0.796416, 0.8461919999999999, 0.8461919999999999, 0.895968, 1.012112, 0.813008, 1.012112, 0.8793759999999999, 0.8296, 0.779824, 0.6968639999999999, 0.9457439999999999, 0.597312, 0.779824, 0.6968639999999999, 0.680272, 0.18251199999999998, 0.8793759999999999, 0.613904, 0.464576, 0.929152, 0.680272, 0.033184, 0.38161599999999996, 0.315248, 0.199104, 0.38161599999999996, 0.033184, 0.232288, 0.36502399999999996, 0.597312, 0.464576, 0.597312, 0.597312, 0.033184, 0.564128, 0.58072, 0.547536, 0.630496, 0.613904, 0.895968, 0.6968639999999999, 0.7300479999999999, 0.547536, 0.713456, 0.8461919999999999, 0.7632319999999999, 0.74664, 0.74664, 0.779824, 0.8461919999999999, 0.8793759999999999, 0.895968, 0.813008, 0.99552, 0.962336, 0.9789279999999999, 0.796416, 0.8296, 0.813008, 0.779824, 0.779824, 0.713456, 0.713456, 0.74664, 0.862784, 0.895968, 0.929152, 0.99552, 0.7632319999999999, 0.929152, 0.74664, 0.929152, 1.0287039999999998, 0.9789279999999999, 1.012112, 1.2112159999999998, 0.9125599999999999, 0.4148, 0.481168, 0.813008, 0.08295999999999999, 0.779824, 0.066368, 0.149328, 1.2775839999999998, 0.9457439999999999, 0.962336, 0.9789279999999999, 0.9457439999999999, 0.9789279999999999, 0.8461919999999999, 0.8793759999999999, 0.8296, 0.7632319999999999, 0.9125599999999999, 0.9125599999999999, 0.9457439999999999, 0.929152, 0.895968, 0.8793759999999999, 0.862784, 0.8461919999999999, 0.647088, 0.6636799999999999, 0.8461919999999999, 0.8296, 0.6968639999999999, 0.779824, 0.8461919999999999, 0.862784, 0.8793759999999999, 0.8793759999999999, 0.8793759999999999, 0.929152, 0.9457439999999999, 0.9125599999999999, 0.9457439999999999, 0.895968, 0.9125599999999999, 0.8296, 0.862784, 0.862784, 0.8793759999999999, 0.8793759999999999, 0.862784, 0.8793759999999999, 0.862784, 0.895968, 0.862784, 0.862784, 0.862784, 0.8793759999999999, 0.8461919999999999, 0.8461919999999999, 0.8461919999999999, 0.8793759999999999, 0.862784, 0.862784, 0.862784, 0.8461919999999999, 0.8296, 0.813008, 0.796416, 0.8461919999999999, 0.813008, 0.813008, 0.8296, 0.8296, 1.178032, 0.862784, 0.895968, 0.7632319999999999, 0.680272, 0.929152, 0.613904, 0.862784, 0.680272, 0.813008, 0.862784, 1.227808, 0.99552, 0.74664, 0.8296, 0.8296, 0.813008, 0.813008, 0.8296, 0.862784, 0.862784, 0.862784, 0.9125599999999999, 0.929152, 0.9457439999999999, 0.9125599999999999, 0.8793759999999999, 0.8793759999999999, 0.862784, 0.862784, 0.8296, 0.8296, 0.813008, 0.8461919999999999, 0.8461919999999999, 0.813008, 0.813008, 0.813008, 0.8296, 1.045296, 0.8296, 0.8296, 0.9457439999999999, 1.41032, 0.58072, 0.962336, 0.282064, 0.630496, 0.862784, 0.680272, 0.895968, 0.315248, 0.18251199999999998, 0.6636799999999999, 0.8296, 0.796416, 0.8296, 0.8461919999999999, 0.8793759999999999, 0.9125599999999999, 0.8461919999999999, 0.8461919999999999, 0.813008, 0.779824, 0.779824, 0.8461919999999999, 0.9125599999999999, 0.9125599999999999, 0.895968, 0.9125599999999999, 0.9125599999999999, 0.929152, 0.9457439999999999, 0.8793759999999999, 0.8793759999999999, 1.045296, 0.647088, 0.7300479999999999, 0.796416, 0.779824, 0.813008, 0.779824, 0.813008, 0.862784, 0.8793759999999999, 0.929152, 0.895968, 1.012112, 0.813008, 0.7632319999999999, 0.796416, 0.7300479999999999, 0.74664, 0.813008, 0.8461919999999999, 0.862784, 0.862784, 0.862784, 0.8793759999999999, 0.895968, 0.862784, 0.8296, 0.8296, 0.862784, 0.8461919999999999, 0.8461919999999999, 0.8461919999999999, 0.8461919999999999, 0.8793759999999999, 0.8296, 0.862784, 1.045296, 0.8296, 0.481168, 0.8296, 0.862784, 0.8793759999999999, 0.895968, 0.8793759999999999, 0.9125599999999999, 0.895968, 0.9457439999999999, 0.929152, 0.9125599999999999, 0.929152, 0.9125599999999999, 0.895968, 0.813008, 0.613904, 0.613904, 0.9125599999999999, 1.1448479999999999, 0.895968, 0.862784, 0.796416, 0.6636799999999999, 0.813008, 0.8296, 0.862784, 0.895968, 0.862784, 0.8296, 0.713456, 0.6636799999999999, 0.796416, 0.7300479999999999, 0.895968, 1.128256, 0.8296, 0.564128, 0.647088, 0.813008, 0.7632319999999999, 0.9125599999999999, 1.0287039999999998, 0.8296, 0.862784, 0.7300479999999999, 0.8461919999999999]

results = frequency_domain(
    rri=rri,
    fs=1.0,
    method='welch',
    interp_method='cubic',
    detrend='linear'
)
print(results)

{'hf': 1874.6342520920668,
 'hfnu': 27.692517001462079,
 'lf': 4894.8271587038234,
 'lf_hf': 2.6110838171452708,
 'lfnu': 72.307482998537921,
 'total_power': 7396.0879278950533,
 'vlf': 626.62651709916258}