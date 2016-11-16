clc
clear
figDir='D:\DML\Jafarzadeh Thesis\images\chapter4';
blue=[0,0.4470,0.7410];
red=[0.8500,0.3250,0.0980];
yellow=[0.9290,0.6940,0.1250];

title='';
ylabel='Prediction Distance';
xlabel='Methods';
figName = 'time_prediction_distance_in_real_data';

temporal_multihawkes=1.91581;
temporal_multihawkes_err=1.099496021220159e-04;
temporal_stp=1.89671;
temporal_stp_err=1.019973474801061e-04;
temporal_hawkes=2.02625;
temporal_hawkes_err=1.318726790450928e-04;
y=[temporal_stp temporal_hawkes temporal_multihawkes];
y_err=[temporal_stp_err temporal_hawkes_err temporal_multihawkes_err ];
y_labels={'STP','hawkes','multihawkes'};
y_colors={red,yellow,blue};
y_lim=[0 3];
plot_bars(y,y_err,y_labels,y_colors,y_lim,xlabel,ylabel,title,figDir,figName );

