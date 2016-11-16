clc
clear
figDir='D:\DML\Jafarzadeh Thesis\images\chapter4';
blue=[0,0.4470,0.7410];
red=[0.8500,0.3250,0.0980];
yellow=[0.9290,0.6940,0.1250];

y_lim=[0 800];

title='';
ylabel='Number of Users';
xlabel='Methods';
figName = 'time_prediction_distance_ranking_between_three_models_in_real_data';

temporal_multihawkes=311;
temporal_stp=404;
temporal_hawkes=44;

y=[temporal_stp temporal_hawkes temporal_multihawkes];
y_labels={'STP','hawkes','multihawkes'};
y_colors={red,yellow,blue};
plot_bars(y,[],y_labels,y_colors,y_lim, xlabel,ylabel,title,figDir,figName );


title='';
xlabel='Methods';
figName = 'time_prediction_distance_ranking_between_pairwise_models_stp_exp_in_real_data';

y_lim=[0 800];
temporal_stp=640;
temporal_hawkes=118;

y=[temporal_stp temporal_hawkes];
y_labels={'STP','hawkes'};
y_colors={red,yellow};
plot_bars(y,[],y_labels,y_colors,y_lim, xlabel,ylabel,title,figDir,figName );


title='';
xlabel='Methods';
figName = 'time_prediction_distance_ranking_between_pairwise_models_stp_social_in_real_data';

temporal_multihawkes=335;
temporal_stp=423;

y=[ temporal_stp temporal_multihawkes];
y_labels={'STP','multihawkes'};
y_colors={red,blue};
plot_bars(y,[],y_labels,y_colors,y_lim, xlabel,ylabel,title,figDir,figName );
