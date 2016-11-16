figDir='D:\DML\Jafarzadeh Thesis\images\chapter4';
markers={'o','s','d','*'};

blue=[0,0.4470,0.7410];
red=[0.8500,0.3250,0.0980];
yellow=[0.9290,0.6940,0.1250];

title='';
xlabel='Events per User';
ylabel='AUC';

figName = 'synth_data_AUC_spatial';
events_per_user=[8 16 32 48 64 80 120 160];
spatial_stp=[0.528824690261354,0.514246585231209,0.512621965963503,0.521308211960890,0.525254653774818,0.529462133471097,0.559641668276518,0.657594973792593];
plot_diags(events_per_user,[spatial_stp'],{'STP'},{blue},xlabel,ylabel,title,figDir,figName,markers );

