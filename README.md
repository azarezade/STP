# STP: Spatio-Temporal Modeling of Check-ins in Location-Based Social Networks
![Build Status](https://img.shields.io/teamcity/codebetter/bt428.svg)
![License](https://img.shields.io/badge/license-BSD-blue.svg)

STP is a model and inference algorithm of users behaviours in spatio-temporal social networks. This framework is designed for research purpose only.
## Features
* It includes a large scale dataset including the adjacency matrix and information of more than 60000 checkins for 1000 users within a same georaphical area (brasil country).
* It includes the implementation of our proposed method plus a set of baseline methods to comprare with.
* A collection of standard evaluation measures for evalution of time and location prediction of diffrent methods
* A set of m-files for plotting competing models performance.

## Execution and Results
The project is executed successfully on Matlab R2015a. You also may need to install the Optimization toolbox beforehand.
For reproduce the results on synthetic data, you should run the *exec_synth.m*. In the case of real data, you can use the *exec_real*.
You can configure model parameters through those files as well. *dataset_final.m* is the main data of the project and consists of more than 60000 events of 1000 brazilian users and the corrosponding adjacency matrix.
All results are in Result folder.
For the edge recovery evaluation of algorithm using the AUC measure on synth data, you need to run *exec_synth_recovery_test.m*. The results are in Results_unknown_adjacency folder.
Please note that this script works only if you perform the *exec_synth.m* with the option of unknown_matrix beforehand. 


## References
1. Zarezade A., Rabiee H. R., Soltani-Farani A., and Khajenezhad A., “Patchwise Joint Sparse Tracking with Occlusion Detection”, IEEE Transactions on Image Processing (TIP), 2014. [download](http://ieeexplore.ieee.org/document/6873285/)
2. Soltani-Farani, Ali, Hamid R. Rabiee, and Ali Zarezade. "Collaborating frames: Temporally weighted sparse representation for visual tracking.", IEEE International Conference on Image Processing (ICIP), 2014. [download](http://ieeexplore.ieee.org/document/7025091/)
3. Bao, Chenglong, et al. "Real time robust l1 tracker using accelerated proximal gradient approach." Computer Vision and Pattern Recognition (CVPR), 2012 IEEE Conference on. IEEE, 2012.
4. Ross, David A., et al. "Incremental learning for robust visual tracking." International Journal of Computer Vision 77.1-3 (2008): 125-141.
5. Babenko, Boris, Ming-Hsuan Yang, and Serge Belongie. "Robust object tracking with online multiple instance learning." IEEE Transactions on Pattern Analysis and Machine Intelligence 33.8 (2011): 1619-1632.
6. Zhang, Tianzhu, et al. "Robust visual tracking via multi-task sparse learning." Computer Vision and Pattern Recognition (CVPR), 2012 IEEE Conference on. IEEE, 2012.
7. http://spams-devel.gforge.inria.fr/downloads.html
8. http://www.vlfeat.org/install-matlab.html
