%%restoredefaultpath
%% delete perv. informations
clc
clear
real_data=1;
events=0; %% initalizing

load('dataset_final');
addpath(genpath('code'));

%% load perv. random initial point or start new random initial point
new_randomization=1; % create new random initial point for optimization problem or the last used one.

%% number of em iterations
em_iterations=10; % number of iterations of EM algorithm

%% the percentage of dataset to use as train
%dataset_size_in_days=[7 14 21 28 42 52];
dataset_size_in_days=[52 42 28 21 14 7]; % number of train data days for each experiment (to show the trend for diffrent size of train data)
%dataset_size_in_days=[25 50 75 100 150 200];
%% the percentage of dataset to use as test
test_size_in_days=14;
%test_size_in_days=70;

%% convert of dataset size from days to percent
dataset_size=zeros(size(dataset_size_in_days));
inds=find(events(:,2)>=(events(end,2)-day2hour(test_size_in_days)));
test_percentage=length(inds)/size(events,1);

for i=1:1:length(dataset_size_in_days)
    inds=find(events(:,2)>(events(end,2)-day2hour(dataset_size_in_days(i)+test_size_in_days)) & events(:,2)<(events(end,2)-day2hour(test_size_in_days)));
    dataset_size(i)=length(inds)/size(events,1);    
end



%% synth OR real data informations
N=1400; % number of users(nodes)
C=10; % number of Categories
%C=9
%L=[5590;2861;437;14503;4607;5646;11028;6076;20218;4597]; % raw dataset
%L=[1791;957;146;5159;1503;2433;3599;2407;6780;1611]; % supercleaned dataset
L=[658;409;47;1970;520;1191;1370;1136;2710;639]; % supercleaned_location_frequency_cleaned dataset:10650  avg events per location:6

%L=[1011;603;5444;3132;1143;1422;798;3100;2252];

nodes_for_experiment=1000; %% number of nodes which we will use in experiments.
users_top=find_top_users(events,nodes_for_experiment);
%users_top=setdiff(users_top,97);
%nodes_for_experiment=99;

%% priodicity configurations
w=24; %% users period
%w=24*4;

sigma_gaussian=1; %% the Standard Deviation of truncated gussian
%sigma_gaussian=5;
 
%sigma_exponential=20; %% fixed by evaluation on the activest user(raw dataset)
sigma_exponential=2; %% the decay rate of the 

sigma_location_exponential=0.5;

%% model creation, data generation and loading
%configure; %% create model and data(if it is synth.)
load('4sq');



%% random number generation preced.
if(new_randomization==1)
    initvar_temporal_base_real=0.01*[ones(model.categories,1);ones(length(model.a),1)]; % init variables of Mu and Beta (Problem temporal params)
    initvar_spatial_base_real=0.1*[rand(length(model.a),1);2*randn(model.categories,1)];% init variables of Alpha and eta
    save('initial_random_values_real.mat','initvar_temporal_base_real','initvar_spatial_base_real');
else
    load('initial_random_values_real.mat');
end


 problem_number=1;

 problem_unique_name='temporal_simple';
 algorithm_stp_real;

 problem_unique_name='temporal_exp';
 algorithm_stp_real;
 
 problem_unique_name='temporal_social';
 algorithm_stp_real;

problem_number=2;

problem_unique_name='spatial_etk';
algorithm_stp_real;
 
problem_unique_name='spatial_tik';
algorithm_stp_real;
 
problem_unique_name='spatial_etk_period_consideration';
algorithm_stp_real;


train_set_number=1; %% we perform some evaluations on the first element of dataset_size_in_days because it is the compelete train data.
number_of_simulation_iters=1;
 
% offline experiment(location)
update_mode=1; %% if update_mode==1 for evaluting an event location we assume we know the ground truth for previous events.
algorithms={'etk','tik','etk_period_consideration'};
predictivity_test_stp_based_methods_in_location 

%% offline experiment(time)
number_of_bins_time=28;
algorithms={'simple','exp','social'};
predictivity_test_stp_based_methods_in_time
