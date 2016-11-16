clc
clear

figDir='D:\DML\Jafarzadeh Thesis\images\chapter4';
blue=[0,0.4470,0.7410];
red=[0.8500,0.3250,0.0980];
yellow=[0.9290,0.6940,0.1250];

title='';
ylabel='Accuracy';
xlabel='Methods';
figName = 'location_prediction_accuracy_spatial_top1_in_real_data';


spatial_stp=0.0734;
spatial_petk=0.0315;
spatial_tik=0.0365;


y=[ spatial_stp spatial_petk spatial_tik];
y_err=[0 0 0];
y_labels={'STP','PETK','TIK'};
y_colors={red,yellow,blue};
y_lim=[0 0.1];
plot_bars(y,y_err,y_labels,y_colors,y_lim,xlabel,ylabel,title,figDir,figName );



figName = 'location_prediction_accuracy_spatial_top3_in_real_data';


spatial_stp=0.1477;
spatial_petk=0.0989;
spatial_tik=0.0949;

y=[spatial_stp spatial_petk spatial_tik];


y_lim=[0 0.2];
plot_bars(y,y_err,y_labels,y_colors,y_lim,xlabel,ylabel,title,figDir,figName );


figName = 'location_prediction_accuracy_spatial_top10_in_real_data';


spatial_stp=0.1735;
spatial_petk=0.1304;
spatial_tik=0.1234;

y=[ spatial_stp spatial_petk spatial_tik];

y_lim=[0 0.2];
plot_bars(y,y_err,y_labels,y_colors,y_lim,xlabel,ylabel,title,figDir,figName );
