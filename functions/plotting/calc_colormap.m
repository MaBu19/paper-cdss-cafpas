% function calculates personalized colormap given 3 RGB triplets
% 
% MB v1 19.07.2016

function p_colormap = calc_colormap(color_top,color_middle,color_bottom)
x = linspace(0,1,100); 

slope_low = (color_middle-color_bottom)/0.5; 

map_bottom1 = color_bottom(1)+slope_low(1)*x(1:50); 
map_bottom2 = color_bottom(2)+slope_low(2)*x(1:50); 
map_bottom3 = color_bottom(3)+slope_low(3)*x(1:50); 

slope_high = abs(color_top-color_middle)/0.5; 

map_top1 = 0.5*slope_high(1)+color_middle(1)-slope_high(1)*x(51:end); % +/- hängt von Farbe ab --> für eine allgemeinere Funktion müsste man gucken, welcher Wert jeweils größer 
map_top2 = 0.5*slope_high(2)+color_middle(2)-slope_high(2)*x(51:end); 
map_top3 = -0.5*slope_high(3)+color_middle(3)+slope_high(3)*x(51:end); 

p_colormap = [map_bottom1, map_top1; map_bottom2, map_top2; map_bottom3, map_top3]; 

% % check 
% figure; 
% plot(x(1),color_bottom(1),'x','color',color_bottom)
% hold on 
% plot(x(50),color_middle(1),'x','color',color_middle)
% plot(x(100),color_top(1),'x','color',color_top)
% plot(x,p_colormap(1,:),'--')
% 
% plot(x(1),color_bottom(2),'x','color',color_bottom)
% plot(x(50),color_middle(2),'x','color',color_middle)
% plot(x(100),color_top(2),'x','color',color_top)
% plot(x,p_colormap(2,:),'--')
% 
% plot(x(1),color_bottom(3),'x','color',color_bottom)
% plot(x(50),color_middle(3),'x','color',color_middle)
% plot(x(100),color_top(3),'x','color',color_top)
% plot(x,p_colormap(3,:),'--')
% 

end