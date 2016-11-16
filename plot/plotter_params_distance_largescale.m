figDir='D:\DML\Jafarzadeh Thesis\images\chapter4';
markers={'o','s','d','*'};

blue=[0,0.4470,0.7410];
red=[0.8500,0.3250,0.0980];
yellow=[0.9290,0.6940,0.1250];


title='';
xlabel='Events per User';
ylabel='MSE';

figName = 'synth_data_params_mse_error_temporal';
events_per_user=[16 32 48 64 80 120 160];
temporal_stp=[0.00102639694495872;0.000454405057578077;0.000422287553987266;0.000228049398450434;0.000209847687616411;0.000188653343542821;0.000108255734693884];
plot_diags(events_per_user,[temporal_stp],{'STP'},{blue},xlabel,ylabel,title,figDir,figName,markers );

figName = 'synth_data_params_mre_error_temporal';
ylabel='MRE';

temporal_stp=[0.674243129370212;0.460286843058900;0.431826156729838;0.387646655809756;0.372320737141338;0.272048121567165;0.354030338928988];
plot_diags(events_per_user,[temporal_stp],{'STP'},{blue},xlabel,ylabel,title,figDir,figName,markers );

figName = 'synth_data_params_mae_error_temporal';
ylabel='MAE';

temporal_stp=[0.0181303894945978;0.0119412374815993;0.0106295117162058;0.00902734285224897;0.00836940820346435;0.00742995916085317;0.00598855794731572];
plot_diags(events_per_user,[temporal_stp],{'STP'},{blue},xlabel,ylabel,title,figDir,figName,markers );


title='';
ylabel='Log MSE';

figName = 'synth_data_params_mse_error_spatial_largescale';
events_per_user=[16 32 48 64 80 120 160];
spatial_stp=[619970150.053247;59007319.0296148;703991.371448346;695182.553618667;20403.6452986594;60909.0298584516;17.3094829757928];
spatial_stp=log(spatial_stp);
plot_diags(events_per_user,[spatial_stp],{'STP'},{blue},xlabel,ylabel,title,figDir,figName,markers );

figName = 'synth_data_params_mre_error_spatial_largescale';
ylabel='Log MRE';

spatial_stp=[2143.63482564347;343.504115857713;44.5426458040051;58.6378015756793;10.3866825381398;13.2131069732915;1.56752848533213];
spatial_stp=log(spatial_stp);
plot_diags(events_per_user,[spatial_stp],{'STP'},{blue},xlabel,ylabel,title,figDir,figName,markers );

figName = 'synth_data_params_mae_error_spatial_largescale';
ylabel='Log MAE';

spatial_stp=[2336.78795837155;372.520037869449;48.3535176919535;62.7988574359136;11.1028903608736;14.2343445928011;1.66411008849524];
spatial_stp=log(spatial_stp);
plot_diags(events_per_user,[spatial_stp],{'STP'},{blue},xlabel,ylabel,title,figDir,figName,markers );

