import io
import numpy as np
import pandas as pd
import rpy2.robjects as robjects
from   rpy2.robjects import pandas2ri
import struct
import sys
import threading
import tsfresh


class TsFresh(threading.Thread):
    dataset_lock = threading.Lock()
    result_lock = threading.Lock()
    result = None

    def __init__(self, first, lastexcl):
        threading.Thread.__init__(self)
        self.first = first
        self.lastexcl = lastexcl

    def run(self):
        TsFresh.dataset_lock.acquire()
        self_dataset = dataset.iloc[(T * self.first):(T * self.lastexcl)]
        # print(self_dataset.head())
        # print(self_dataset.tail())
        TsFresh.dataset_lock.release()

        extracted_features = tsfresh.extract_features(self_dataset, column_id="id", column_sort="time",
                                                      disable_progressbar = False, show_warnings = False, n_jobs = 0)
        TsFresh.result_lock.acquire()
        if TsFresh.result is None:
            TsFresh.result = extracted_features
        else:
            TsFresh.result = TsFresh.result.append(extracted_features, ignore_index = True)
        TsFresh.result_lock.release()

    def get_result(self):
        return TsFresh.result

if __name__ == "__main__":
    path = sys.argv[1]
    fn_dataset = sys.argv[2]
    fn_time = sys.argv[3]
    fn_result = sys.argv[4]
    I = int(sys.argv[5])
    T = int(sys.argv[6])
    n_jobs = int(sys.argv[7])

    fp_dataset = path + "/" + fn_dataset
    fp_time = path + "/" + fn_time
    fn_result = path + "/" + fn_result

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

    #extracted_features = tsfresh.extract_features(dataset, column_id="id", column_sort="time",
    #                                              disable_progressbar = False, show_warnings = False, n_jobs = n_jobs)

    threads = []
    for chunk in np.array_split(range(I), n_jobs):
        thread = TsFresh(min(chunk), max(chunk) + 1)
        threads += [thread]
        thread.start()

    for thread in threads:
        thread.join()
        
    threads[0].get_result().to_csv(fn_result, na_rep = 'NA')
