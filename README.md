# STP: Spatio-Temporal Modeling of Check-ins in Location-Based Social Networks
![Build Status](https://img.shields.io/teamcity/codebetter/bt428.svg)
![License](https://img.shields.io/badge/license-BSD-blue.svg)

STP is the generative model and inference algorithm for the users' behaviours in location-based social networks (LBSN). The MATLAB source codes and datasets can be used only for academic purposes. More at project [website](https://azarezade.github.io/STP/).

## Features
* The implementations of our method and the baselines.
* A dataset including the adjacency matrix and information of about 60000 checkins of 1000 users in Brazil.
* A collection of standard evaluation measures for the temporal and spatial predictions
* m-files for plotting the performance measures.

## Execution and Results
The project is executed successfully on Matlab R2015a. You also may need to install the Optimization toolbox beforehand.
To reproduce the results on synthetic data, run the *exec_synth.m*. For the real data, use the *exec_real.m*.
You can configure model parameters through those files as well. *dataset_final.mat* is the main data of the project and it consists of more than 60000 events of 1000 the Brazilian users and the corresponding adjacency matrix.
Results will be saved in `Result` folder.
For the edge recovery evaluation of algorithm using the AUC measure on synth data, you need to run *exec_synth_recovery_test.m*. The results will be saved in `Results_unknown_adjacency` folder.
Please note that this script works only if you perform the *exec_synth.m* with the option of `unknown_adjacency` beforehand. 
The results are plotted with the code within the `plot` folder. Each m-file is associated with a single experiment results.
