figDir='D:\DML\Jafarzadeh Thesis\images\chapter4';
blue=[0,0.4470,0.7410];
red=[0.8500,0.3250,0.0980];
yellow=[0.9290,0.6940,0.1250];
y_colors={red,yellow,blue};

markers={'o','s','d','*'};


title='';
xlabel='Weeks';
ylabel='CPU Time';

figName = 'temporal_models_optimization_time_in_real_data';
weeks=[1 2 3 4 6 8];
temporal_multihawkes=[590.719999999998;1501.76999999999;2566.51000000000;2580.43000000000;7841.52000000000;11157.8500000000];
temporal_stp=[283.290000000000;630.170000000000;950.809999999999;951.310000000001;2276.18000000000;3018.62000000000];
temporal_hawkes=[132.810000000001;349.480000000001;583.810000000003;571.660000000011;1473.79000000001;2172.00000000001];
plot_diags(weeks,[ temporal_stp temporal_hawkes temporal_multihawkes],{'STP','hawkes','multihawkes'},y_colors,xlabel,ylabel,title,figDir,figName,markers )
