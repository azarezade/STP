function plot_diags(x,y_matrix,y_names,y_colors,xlabel_val,ylabel_val,title_val,figDir,figName,markers )

fig=figure;
%%-------True curves------%%

hold on


for i=1:1:size(y_matrix,2)
   y=y_matrix(:,i);
   p=plot(x,y, 'LineWidth',1.3);
   p.Marker=markers{i};
   %plot(x,y,'linestyle','-.', 'LineWidth',1.3);
    p.Color=y_colors{i};
end

hold off
box on

%%-------Smooth curves example------%%
% [xx1,yy1] = smoothLine(x, y1);
% [xx2,yy2] = smoothLine(x, y2);
% [xx3,yy3] = smoothLine(x, y3);
% [xx4,yy4] = smoothLine(x, y4);
% plot(xx1,yy1, xx2,yy2, xx3,yy3, xx4,yy4, 'LineWidth',1.3);
if(length(y_names)>=2)
legend(y_names,'interpreter','latex','Location','northwest', 'orientation', 'vertical');     
end

xlabel(xlabel_val,'interpreter','latex')
ylabel(ylabel_val,'interpreter','latex')
title(strcat('\texttt{',title_val,'}'), 'interpreter','latex')
grid on

set(findall(gca,'type','text'),'fontSize',12);%, 'fontweight','bold'); , 'LineSmoothing','on'
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0 0  14*3/4.5 10*5.5/8]);
print(fig, '-depsc',fullfile(figDir,figName)) %'-opengl' '-r600'
end

