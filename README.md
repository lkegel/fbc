
# Feature-based Time Series Classification (Supporting Material)
Time series classification relies on time series with class labels. A classifier infers the class from a time series, which is crucial for many domains, often for supporting human classification decisions or for fully automatizing processes. A multitude of engineering techniques have been proposed which consider datasets with tens of thousands of time series, but the time series length is rather short. Thus, they do not focus on efficiency, and do not tackle the challenges of big time series datasets.  
Our objective is to design a classification technique for datasets with long time series, i.e., consisting of tens of thousands of values. This technique should be effective, i.e., have a high forecast accuracy, and efficient, i.e., have a short overall runtime for representation and classification.

## Scripts
The directory *Implementation* contains the scripts to carry out the evaluation:

 - *init.R*: loads libraries and scripts from *sources*
 - *main.R*: bundles initialization, calibration and classification
 - *sources* (in logical order):
     - *method.R*: construction of representation technique based on configuration and dataset parameters
     - *represent.R*: transformation of a time series dataset into representation
     - *scale.R*: techniques for normalizing representations
     - *feature_selection.R*: techniques for feature selection
     - *validate.R*: configuration of classifiers based on training dataset
     - *classify.R*: estimation and use of classifiers
     - *run.R*: helper methods for all steps of classification
     - *util.R*: helper methods for file management and data frames
     - *eval.R*: textual and visual evaluation of results
     - *raw_convert.R*: helper methods for Raw
     - *tsfresh-\**: methods for tsfresh
 - *configs*: configuration parameters for all steps and dataset parameters
 - *c*: sources for Raw
 
Required packages:

 - classrepr (see below)
 - stringr
 - data.table
 - idxrepr
 - R.utils
 - TST
 - caret
 - rpart
 - e1071
 - xgboost
 - ggplot2
 - ggrepel
 - directlabels
 - latticeExtra
 - grDevices
 - extrafont
 - Rttf2pt1 and ghostscript 9.27 must be installed for plots with suitable fonts
 
## Datasets
The directory *Data* contains the datasets together with representations, intermediate and final results of the evaluation.

 - *Metering* dataset
	 - This dataset has to be included manually from [Irish Social Science Data Archive](http://www.ucd.ie/issda).
	 - It is the dataset "CER Smart Metering Project" of the Commission for Energy Regulation.
	 - Select 4,710 time series from households and businesses and expand the time series for extracting the yearly season.
	 - Store the dataset in Data/Metering_I_4710_T_35040/dataset.rds.
 - *Payment* dataset
     - This dataset has to be included manually from [IJCAI 2017 - Data Mining Contest](https://tianchi.aliyun.com/competition/entrance/231591/information).
	 - Select 2,000 time series, set missing values to zero, and aggregate to 6-hourly granularity.
	 - Store the dataset in Data/Payment_I_2000_T_11856/dataset.rds.
     
## Representation Techniques

The *classrepr* package contains the representation techniques: [https://github.com/lkegel/classrepr](https://github.com/lkegel/classrepr). Install this package to run the evaluation.

## Software Environment
The accuracy experiments have been tested under

 - Windows 10 with R 3.4.4 and Rtools 3.4.0.1964
 - Linux Ubuntu 14.04.6 LTS with R 3.4.4 and gcc 4.8.4