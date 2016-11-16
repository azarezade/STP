
blue=[0,0.4470,0.7410];
red=[0.8500,0.3250,0.0980];
yellow=[0.9290,0.6940,0.1250];

y_colors={red,yellow,blue};

figDir='D:\DML\Jafarzadeh Thesis\images\chapter4';
markers={'o','s','d','*'};

title='';
xlabel='Weeks';
ylabel='Avg. LogLikelihood';

figName = 'likelihood_temporal_model_in_real_data';
weeks=[8 6 4 3 2 1];
temporal_multihawkes=-1*[8.61863882902265;8.66579647796288;9.12180289629568;9.12061964044113;9.33382429056271;9.77490847501796];
temporal_stp=-1*[5.50981866389952;5.53751728044221;5.98481101880873;5.96197155140793;6.19904592586810;6.61021303894462];
temporal_hawkes=-1*[5.75253025195134;5.81618929728594;6.32297610666970;6.31118121467390;6.61901669547271;7.18765447484137];
plot_diags(weeks,[temporal_stp temporal_hawkes temporal_multihawkes],{'STP','hawkes','multihawkes'},y_colors,xlabel,ylabel,title,figDir,figName,markers )

title='';

figName = 'likelihood_spatial_model_in_real_data';
weeks=[8 6 4 3 2 1];
spatial_tik=-1*[5.71193533395272;5.78441783708582;6.04588390931215;6.04152090669186;6.15247976603549;6.33512964849245];
spatial_stp=-1*[5.77237831093574;5.78255980450078;5.83601003757217;5.83495040329293;5.90036076694180;5.93220901380074];
spatial_petk=-1*[8.81907683937112;8.79079849439801;8.95499079781263;8.96252219675907;8.99565952313694;9.10192608622468];



plot_diags(weeks,[spatial_stp spatial_petk spatial_tik],{'STP','PETK','TIK'},y_colors,xlabel,ylabel,title,figDir,figName,markers);
