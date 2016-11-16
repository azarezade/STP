# STP: Spatio-Temporal Modeling of Check-ins in Location-Based Social Networks
![Build Status](https://img.shields.io/teamcity/codebetter/bt428.svg)
![License](https://img.shields.io/badge/license-BSD-blue.svg)

STP is a model and inference algorithm of users behaviours in spatio-temporal social networks. The code and dataset can be used for academic purpose only.
## Features
* It includes a large scale dataset including the adjacency matrix and information of more than 60000 checkins for 1000 users within a same geographical area (brasil country).
* It includes the implementation of our proposed method plus a set of baseline methods to compare with.
* A collection of standard evaluation measures for evalution of time and location prediction of diffrent methods
* A set of m-files for plotting competing models performance.

## Execution and Results
The project is executed successfully on Matlab R2015a. You also may need to install the Optimization toolbox beforehand.
For reproduce the results on synthetic data, you should run the *exec_synth.m*. In the case of real data, you can use the *exec_real.m*.
You can configure model parameters through those files as well. *dataset_final.mat* is the main data of the project and it consists of more than 60000 events of 1000 brazilian users and the corresponding adjacency matrix.
All the results will be saved in `Result` folder.
For the edge recovery evaluation of algorithm using the AUC measure on synth data, you need to run *exec_synth_recovery_test.m*. The results will be saved in `Results_unknown_adjacency` folder.
Please note that this script works only if you perform the *exec_synth.m* with the option of `unknown_adjacency beforehand`. 
