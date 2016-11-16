clc
clear
figDir='D:\DML\Jafarzadeh Thesis\images\chapter4';
blue=[0,0.4470,0.7410];
red=[0.8500,0.3250,0.0980];
yellow=[0.9290,0.6940,0.1250];

title_val='';
ylabel_val='Accuracy';
xlabel_val='';
figName = 'location_prediction_accuracy_spatial_all_in_one_fig_in_real_data';


data=[0.0734  0.0315 0.0365;0.1477  0.0989 0.0949;0.1735  0.1304 0.1234];

y_labels={'STP','PETK','TIK'};
y_colors={red,yellow,blue};
y_lim=[0 0.2];

fig=figure;
%%-------True curves------%%

hold on

hb = bar(data);
set(hb(1), 'FaceColor',red);
set(hb(2), 'FaceColor',yellow);
set(hb(3), 'FaceColor',blue);

        

box on


legend(y_labels,'interpreter','latex','Location','northwest', 'orientation', 'vertical'); 

hold off

xlabel([xlabel_val],'interpreter','latex');
ylabel([ylabel_val],'interpreter','latex');
title(strcat('\texttt{',title_val,'}'), 'interpreter','latex')
ylim(y_lim);
set(gca, 'XTickLabelMode', 'Manual')
set(gca, 'XTick', [])
str = {'Top@1'; 'Top@3'; 'Top@10'};
set(gca, 'XTickLabel',str, 'XTick',1:numel(str))
grid on

set(findall(gca,'type','text'),'fontSize',12);%, 'fontweight','bold'); , 'LineSmoothing','on'
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0 0  14*3/4.5 12*5.5/8]);
print(fig, '-depsc',fullfile(figDir,figName)) %'-opengl' '-r600'


