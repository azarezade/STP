%% delete perv. informations
clc
clear

%% Add Required Folders to Path
addpath(genpath('code'));
real_data=0;

%% Load pervious random initial point or start new random initial point
new_randomization=1;

%% minimum number of cores to use
% number_of_cores=2;
% delete(gcp)
% parpool(number_of_cores);

%% number of em iterations
em_iterations=40;

%% the percentage of dataset to use as train
dataset_size=[0.04 0.08 0.16 0.24 0.32 0.4 0.6 0.8];

%% the percentage of dataset to use as test
test_percentage=0.2;

%% synth OR real data informations
N=50; % number of users(nodes)
C=4; % number of Categories
L=ones(C,1)*8; % number of locations for each category

%% priodicity configurations
w=12; %% users Tao (period)
sigma_gaussian=0.5; % Standard deviation for truncated gaussians
sigma_exponential=0.5; % decade rate for exponential decaying functions in periodic point process

sigma_location_exponential=0.2;% decade rate in weight function of locations

%% synth dataset generation information
quantity=struct;
quantity.type='number'; %% you can specify the number of events OR the time span for simulation
quantity.value=10000; %% number of events OR simulation time

sp=0.2; %sparsity
max_mu=0.05;%base rate of users for generate an event (N*1 array)
max_eta=0.05;% orientation to choose new places in a category by a user (N*P matrix)
max_a=0.5;%connection weight in adjacency matrix
max_beta=0.1;
stationary=1;



%% model creation, data generation and loading ; as we only evalute the proposed method on synthetic data, please don't change to below informations unless it is neccessary
method_time='temporal_simple';
method_location='spatial_etk';
unknown_adjacency=0; % 0=the inference knows the true adjacency matrix;1=otherwise(e.g. link recovery experiment)

configure; %% create model and data(if it is synth.)
load('erdos');


%% random number generation
if(new_randomization==1)
    initvar_temporal_base_synth=0.01*[ones(model.categories,1);ones(length(model.a),1)]; % init variables of Mu and Beta (Problem temporal params)
    initvar_spatial_base_synth=5*[rand(length(model.a),1);2*randn(model.categories,1)];% init variables of Alpha and eta
    
    save('initial_random_values_synth.mat','initvar_temporal_base_synth','initvar_spatial_base_synth');
else
    load('initial_random_values_synth.mat');
end

problem_number=1;
problem_unique_name='temporal_simple';
algorithm_stp_synth;

problem_number=2;
problem_unique_name='spatial_etk';
algorithm_stp_synth;

