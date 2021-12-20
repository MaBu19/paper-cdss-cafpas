% function that plots whole range of current colormap and current value (in
% plot_trafficlight_table_tl) 
% 
% MB, v1, 29.09.2016
% 
% input: 
% h     figure handle
% map   colormap to be plotted
% p     value between 0 and 1 indicating the current value of CAFPA
% hax   axis handle
% 
% output: 
% h     figure handle 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = plot_colormap_p(h,map,p,hax,varargin)
fsize = 6; 

if isempty(h)
    h = figure; 
end 
if isempty(map)
    map = calc_colormap(rgb('FireBrick'),rgb('Gold'),rgb('DarkGreen')); map = map';
end
if isempty(p)
    p = 0.5; 
end
if isempty(hax)
    hax = gca;
end
if ~isempty(varargin)
    stdprob = varargin{1};   
    if length(varargin) == 2
        pp = varargin{2}; 
        fsize = pp.fize; 
    end
end 

len = length(map); 
line_x = round(p*len);
if ~isempty(varargin)
line_std = round(stdprob*len); 
end 
hold on 
% h = imagesc(hax,[1:len]); % uni
h = imagesc([1:len]); % laptop 
colormap(map);
line([line_x line_x],[0.5 1.5],'color','k','linewidth',1);
if ~isempty(varargin)
    add_std(line_x,line_std);
end
axis([1 len 0.5 1.5]);     
set(gca,'XTick',[1 len],'XTickLabel',[],'YTick',[],'FontSize',fsize-2,'fontWeight','bold')

box on 
set(gca, 'Layer', 'top')
    
end