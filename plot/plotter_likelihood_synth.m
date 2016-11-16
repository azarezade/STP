figDir='D:\DML\Jafarzadeh Thesis\images\chapter4';

blue=[0,0.4470,0.7410];
red=[0.8500,0.3250,0.0980];
yellow=[0.9290,0.6940,0.1250];

markers={'o','s','d','*'};

title='';
xlabel='Events per User';
ylabel='Avg. LogLikelihood';

figName = 'synth_data_likelihood_temporal';
events_per_user=[16 32 48 64 80 120 160];
temporal_stp=-1*[4.82688279062199;4.58684031544419;4.52789477973779;4.46705638460275;4.46761654328357;4.46387768354385;4.44839216842719];
plot_diags(events_per_user,[temporal_stp],{'STP'},{blue},xlabel,ylabel,title,figDir,figName,markers )

title='';
figName = 'synth_data_likelihood_spatial';
events_per_user=[16 32 48 64 80 120 160];
spatial_stp=-1*[2.042209234003505;1.748893096186296;1.711991444471538;1.686801775438884;1.675006846663013;1.653449727298824;1.650163015313534];
plot_diags(events_per_user,[spatial_stp],{'STP'},{blue},xlabel,ylabel,title,figDir,figName,markers );


