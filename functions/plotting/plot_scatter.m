% scatter plot of data in x and y
% 
% Mareike Buhl
% mareike.buhl@uol.de
%
% v1 13.11.20 (adapted from plot_roc_scatter)
% 
% INPUT: 
% figh
% x 
% y
% pp
% 
% OUTPUT: 
% figh 
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function figh = plot_scatter(figh,x,y,pp)
 
if isnumeric(x) % sens and spec needed as cell (to cover different lengths of data vectors)
    x = mat2cell(x,size(x,1),size(x,2)); 
    y = mat2cell(y,size(y,1),size(y,2)); 
%     warning('Sens and spec transformed to cell'); 
end

num_data = length(x); % for each n in num_data the same pp.point style is applied to whole included vector

% parse input parameters (struct pp)
p = inputParser;
p.KeepUnmatched = true;
% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
addParameter(p, 'figheight', 3.9990  , @isnumeric);
addParameter(p, 'figwidth', 4.1850  , @isnumeric);
addParameter(p, 'fsize', 6, @isnumeric);
addParameter(p, 'colors', {rgb('Blue'),rgb('DarkMagenta'),rgb('Indigo'),rgb('FireBrick'),rgb('Chocolate'),rgb('DarkOrange'),rgb('Gold'),rgb('LimeGreen'),rgb('DarkGreen'),rgb('MidnightBlue'),rgb('DeepSkyBlue'),rgb('RoyalBlue'),rgb('YellowGreen'),rgb('DeepPink'),'none',rgb('Gray'),rgb('Red'),rgb('Black'),rgb('DodgerBlue'),rgb('ForestGreen'),rgb('LightGray')}, @iscell); 
addParameter(p, 'point', [14 19 6; 14 19 6; 1 1 1], @isnumeric);
addParameter(p, 'symbols', {'o','s','v','<','*','>','+','d','^','p','h','x','o','s'}, @iscell); 
addParameter(p,'xlabel',{'p_{CAFPA} (observed)'}',@iscell); 
addParameter(p,'ylabel',{'p_{CAFPA} (predicted)'},@iscell); 
addParameter(p,'legend',{''},@iscell); 
parse(p,pp); % to do: add more defaults (everything that needs to be available, e.g. pp.colors, pp.symbols)
ppa = p.Results;


% handles
figure(figh); 
axh = axes('Parent', figh); 
hold(axh,'on'); 
box(axh,'on'); 
h = [];

% plot diagonal
x_pos = 0:0.01:1; 
plot(axh,x_pos,x_pos,'color',[0.5,0.5,0.5],'linestyle','--')

for n = 1:num_data
    htmp = plot(axh,x{n},y{n},ppa.symbols{ppa.point(3,n)},'color',ppa.colors{ppa.point(1,n)},'markerfacecolor',ppa.colors{ppa.point(2,n)},'linewidth',0.3,'markersize',2); 
    h = [h;htmp]; % used for legend (not included at the moment) 
end

xlabel(axh,ppa.xlabel,'FontSize',ppa.fsize);
ylabel(axh,ppa.ylabel,'FontSize',ppa.fsize); 
set(axh,'XTick',0:0.2:1,'FontSize',ppa.fsize);
set(axh,'YTick',0:0.2:1,'FontSize',ppa.fsize);
axis([0 1 0 1]); 

set(figh, 'PaperPositionMode', 'manual');
set(figh, 'PaperUnits', 'centimeters');
set(figh, 'PaperPosition', [0 0 ppa.figwidth ppa.figheight]);

end
