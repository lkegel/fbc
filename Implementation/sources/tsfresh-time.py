import io
import sys
import struct

import os

os.environ.update(
        OMP_NUM_THREADS = '1',
        OPENBLAS_NUM_THREADS = '1',
        NUMEXPR_NUM_THREADS = '1',
        MKL_NUM_THREADS = '1',
    )
    
import pandas as pd
import numpy as np


import threading
import tsfresh
from tsfresh.feature_extraction import EfficientFCParameters
import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
import time

if __name__ == "__main__":
    path = sys.argv[1]
    fn_dataset = sys.argv[2]
    fn_time = sys.argv[3]
    I = int(sys.argv[4])
    T = int(sys.argv[5])
    n_jobs = int(sys.argv[6])

    fp_dataset = path + "/" + fn_dataset
    fp_time = path + "/" + fn_time

    struct_format = str(I * T) + 'd'
    struct_size = I * T * 8
    with open(fp_dataset, "rb") as f:
        data = f.read(struct_size)
        values = list(struct.unpack(struct_format, data))

    # Timestamps
    pandas2ri.activate()
    readRDS = robjects.r['readRDS']
    df_time = readRDS(fp_time)
    df_time = list(pandas2ri.ri2py(df_time))[0:T]
    # df_time["time"] = pd.to_datetime(dataset["time"], format="%Y-%m-%d %H:%M:%S", utc = True)

    dataset = pd.DataFrame({'id': np.repeat(range(I), T),
                            'time': df_time * I,
                            'value': values})

    print(dataset.head())
    print(dataset.tail())
    
    settings = EfficientFCParameters()

    
    start_time = time.time()
    extracted_features = tsfresh.extract_features(dataset, column_id="id", column_sort="time",
                                                  disable_progressbar = False, show_warnings = False, n_jobs = n_jobs, default_fc_parameters = settings)
    print("--- %s seconds ---" % (time.time() - start_time))
