% function plot_audiogram_dist() combines multiple audiograms to one
% audiogram distribution (in contrast to results from the first survey,
% each single audiogram consists of one line)
%
% v1, MB 07.08.18
% v2, MB 18.09.20: updated compatibility to paper 2 (Buhl et al. 2020a),
% removed distribution calculation - to be done outside this function
%
% INPUT:
% figh          figure handle
% AG            matrix containing AG data (row-wise)
% pp            plot properties 
%
% OUTPUT:
% figh          updated figure handle
%
%
% to do: 
% - generalize x-axis (frequency vector) 
% - check code for plot_type = '2d-histo' (formerly 'dist', from Buhl et
% al. 2019)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [figh] = plot_audiogram_dist(figh,AG,pp)


% parse input parameters (struct pp)
p = inputParser;
p.KeepUnmatched = true;
addParameter(p, 'figheight', 3.5  , @isnumeric);
addParameter(p, 'figwidth', 5.8  , @isnumeric);
addParameter(p, 'fsize', 6, @isnumeric);
addParameter(p, 'plot_type', 'dist-fun', @ischar); % 'lines' dabehalten, dist --> raus oder besseren Namen (2d-histo?)
addParameter(p, 'cmax', 0.04, @isnumeric);
% addParameter(p, 'point', [14 19 6; 14 19 6; 1 1 1], @isnumeric);
parse(p,pp);

mergestructs = @(x,y) cell2struct([struct2cell(x);struct2cell(y)],[fieldnames(x);fieldnames(y)]);
pp = mergestructs(p.Results,p.Unmatched);



% graphical representation as used for Paper 2 Figure 7 (p2-fig7)
if strcmp(pp.plot_type,'dist-fun') % 25.06.19 - if parameters of audiogram (gmm-1) should be combined in known plot design
    imagesc([1,3,5,6,7,8,9,10,11,12,13],1:131,AG);
    
    % plot settings
    axis ij
    map = colormap('gray'); map = 1-map; colormap(map);
    caxis([0 pp.cmax]); 
    cbh = colorbar;
    
    %     cbh=colorbar('h'); % needed in octave?
    set(cbh,'YTick',[0:0.01:pp.cmax])
    
elseif strcmp(pp.plot_type,'lines') % p2-fig5
    hold on;
    h = [];
    
    for k = 1:size(AG,1);
        
        htmp = plot([1,3,5,6,7,8,9,10,11,12,13],AG(k,:));
        set(htmp,'Marker',pp.symbols{pp.point(3,mod(k,5)+1)},'LineWidth',0.3,'Markersize',2,'Color',pp.colors{pp.point(1,mod(k,5)+1)}); % marker size etc mit theo_ROC vergleichen
        h = [h;htmp]; % only needed for legend 
    end
    
    
    set(gca,'YTick',0:20:120,'FontSize',pp.fsize);
    
    ylim([-5 120]);
    axis ij
    box on;
elseif strcmp(pp.plot_type,'2d-histo') % (formerly 'dist')
    % add here/check: plot of 2D histograms as used in paper 1
    norm_val = 1; % normalization
    [C1,h1] = contourf([1,3,5,6,7,8,9,10,11,12,13],1:14,AG_mat/norm_val);  % logarithmic x-axis
    
    % plot settings
    axis ij
    map = colormap('gray'); map = 1-map; colormap(map);
    %h1.linecolor = 'none'; % matlab
    set(h1,'linecolor','none'); % octave
    %caxis(h1.Parent,[0 0.6]);
    caxis([0 0.6]); % octave;
    colorbar;
    
    
end


%% plot properties
set(gca,'XTick',[1,3,5,7,9,11,13]);
set(gca,'XTickLabel',[0.125,0.25,0.5,1,2,4,8],'FontSize',pp.fsize-2);

if strcmp(pp.plot_type,'dist')
    set(gca,'YTick',[2:2:14]);
    set(gca,'YTickLabel',[0:20:120],'FontSize',pp.fsize);
    ylim([1.5 14]);
    if ~isempty(AG)
        text(1.5,13.5,['\itN = ' num2str(size(AG,1))],'FontSize',pp.fsize); % {\itN}
    end
elseif strcmp(pp.plot_type,'dist-fun')
    set(gca,'YTick',[11:20:131]);
    set(gca,'YTickLabel',[0:20:120],'FontSize',pp.fsize-2);
    axh = gca;
    ylim([5 131]);
    
end

xlim([0.5 13.5]);
xlabel('Frequency [kHz]','FontSize',pp.fsize);
ylabel('Hearing loss [dB HL]','FontSize',pp.fsize);


set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 pp.figwidth pp.figheight]);

end