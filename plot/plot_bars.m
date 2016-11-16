function plot_bars(y,y_erros,y_names,y_colors,y_lim,xlabel_val,ylabel_val,title_val,figDir,figName )
fig=figure;
%%-------True curves------%%

hold on
x=1:1:length(y_names);

for i=1:1:length(x)
   
   b=bar(x(i),y(i),0.3);
   if(i==1)
       b.FaceColor=y_colors{i};    
   end
   
   if(i==2)
       b.FaceColor=y_colors{i};
   end
   if(i==3)
       b.FaceColor=y_colors{i};
   end
end
        


box on


legend(y_names,'interpreter','latex','Location','northwest', 'orientation', 'vertical'); 

if(length(y_erros)~=0)
for i=1:1:length(x)
   erb=errorbar(x(i),y(i),y_erros(i));
   erb.Color='black';    
end
end
hold off

xlabel([xlabel_val],'interpreter','latex');
ylabel([ylabel_val],'interpreter','latex');
title(strcat('\texttt{',title_val,'}'), 'interpreter','latex')
ylim(y_lim);
set(gca, 'XTickLabelMode', 'Manual')
set(gca, 'XTick', [])
grid on

set(findall(gca,'type','text'),'fontSize',12);%, 'fontweight','bold'); , 'LineSmoothing','on'
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0 0  14*3/4.5 12*5.5/8]);
print(fig, '-depsc',fullfile(figDir,figName)) %'-opengl' '-r600'

end