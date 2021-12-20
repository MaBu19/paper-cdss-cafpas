% plot figure 6 of paper3 (Buhl et al. 2020b), weights of CAFPA/meas
% combinations yielding Youden index Y>=Y_th*max(Y) 
% 
% Mareike Buhl
% mareike.buhl@uol.de
% v1, 26.08.2019
% 
% 
% INPUT: 
% figh              figure handle 
% w_mat             matrix containing rows of weights [num_combi num_params] 
% pp                plot properties struct 
% 
% OUTPUT: 
% figh              figure handle 
% h                 subplot handles
% ppa               plot properties as applied here (maybe needed for
%                   titles outside)
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [figh,h,ppa] = plot_weights(figh,w_mat,pp)

num_sub = size(w_mat,1); 
num_params = size(w_mat,2); 
 
% parse input parameters (struct pp)
p = inputParser;
p.KeepUnmatched = true;
% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
addParameter(p, 'figheight', 3.9990  , @isnumeric);
addParameter(p, 'figwidth', 4.1850  , @isnumeric);
addParameter(p, 'fsize', 6, @isnumeric);
addParameter(p, 'xnames',{'C_{A1}','C_{A2}','C_{A3}','C_{A4}','C_{U1}','C_{U2}','C_{B}','C_{N}','C_{C}','C_{E}'}, @iscell);
addParameter(p, 'idx_empty', zeros(num_sub,1), @isnumeric);
parse(p,pp); % alles was nicht immer vorhanden ist, hier mit reinnehmen (pp.colors etc functioniert unten, darf aber auch nicht fehlen - hier könnte default definiert werden)
ppa = p.Results;

% handles
figure(figh); 
axh = axes('Parent', figh); 
hold(axh,'on'); 
box(axh,'on'); 

% margins etc. (to be optimized, see to do)
plnumx = 1;  %ncols
plnumy = num_sub; %nrows

% margins
plytopmargin = 0.05; % relative to 1
plybottommargin = 0.2; 
plxleftmargin = 0.15; 
plxrightmargin = 0.03; 

% distance between the small figures
plxdist = 0.00/plnumx;
plydist = 0.23/plnumy; 

% now calculate the size of the figures
plxsize = (1 - plxleftmargin - plxrightmargin - (plxdist*(plnumx-1)))/plnumx;
plysize = (1 - plytopmargin - plybottommargin - (plydist*(plnumy-1)))/plnumy;


% plot relative weight frequencies
for k = 1:num_sub
    actnumx = 1; actnumy = num_sub-(k-1); 
    h(k) = subplot('position',[((actnumx-1)*(2*plxsize+plxdist) +plxleftmargin) ((actnumy-1)*(plysize+plydist) + plybottommargin) plxsize plysize]);
     
    if ppa.idx_empty(k)
        bar(1:num_params,w_mat(k,:),'facecolor',mean([rgb('white');pp.colors{pp.point(2,1)}]));
    elseif ppa.idx_empty(k) == 0% standard case
        
        bar(1:num_params,w_mat(k,:),'facecolor',pp.colors{pp.point(2,1)});
    end
    
    axis([0.5 num_params+0.5 0 1]);
    ylim([0 1.05]);
%     set(gca,'YTick',[0.5 1],'FontSize',ppa.fsize-2);
    
    if k ~= num_sub
        set(gca,'XTick',[]);
    elseif k == num_sub
        set(gca,'XTick',1:num_params,'XTickLabel',ppa.xnames,'FontSize',ppa.fsize-1,'XTickLabelRotation',0); % ppa.fsize-2
    end   
    set(gca,'YTick',[0.5 1],'FontSize',ppa.fsize-2);

end

if isfield(ppa,'figwidth')
    if ~isempty(ppa.figwidth)
        set(figh, 'PaperPositionMode', 'manual');
        set(figh, 'PaperUnits', 'centimeters');
        set(figh, 'PaperPosition', [0 0 ppa.figwidth ppa.figheight]);
    end
end


end

