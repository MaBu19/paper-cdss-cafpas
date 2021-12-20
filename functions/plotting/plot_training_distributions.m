% plot training distributions for paper2 (manual choice vs. gmm-1 vs.
% gmm-2)
% 
% v2, MB 29.05.19 --> adapted from plot_classication_check
% 
% INPUT: 
% x         x vector for data{m}
% x_h       x vector for histogram 
% n_pdf     normpdf data for given num_p and k (defined outside) 
% hist_mat  histograms of underlying data [cats x bins], do not display if
% isempty
% meas_name string indicating the measure to be plotted (needed for default
%           xlabels etc. 
% pp        plot properties 
%
% OUTPUT: 
% figh      figure handle
% axh
% ph
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [figh,axh,ph] = plot_training_distributions(x, n_pdf_d, x_h, hist_mat, meas_name, ppa ) % , m, mu, sig, weight, dist_type, input_names  )%n_pdf,p_B,data_test,max_val,colorstyle,hist_mat,plot_header)

% parse input parameters (struct pp)
p = inputParser;
p.KeepUnmatched = true;
% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
addParameter(p, 'figheight', 3  , @isnumeric);
addParameter(p, 'figwidth', 4.8  , @isnumeric); % (4.5)
addParameter(p, 'fsize', 6, @isnumeric);
addParameter(p, 'colors', {rgb('Blue'),rgb('DarkMagenta'),rgb('Indigo'),rgb('FireBrick'),rgb('Chocolate'),rgb('DarkOrange'),rgb('Gold'),rgb('LimeGreen'),rgb('DarkGreen'),rgb('MidnightBlue'),rgb('DeepSkyBlue'),rgb('RoyalBlue'),rgb('YellowGreen'),rgb('DeepPink'),'none',rgb('Gray'),rgb('Red'),rgb('Black'),rgb('DodgerBlue'),rgb('ForestGreen'),rgb('LightGray')}, @iscell); 
addParameter(p, 'point', [14 19 6; 14 19 6; 1 1 1], @isnumeric);
addParameter(p, 'linestyles', {'-','--','-.','-','--','-.','-','--','-.'}, @iscell); 
addParameter(p,'reflines',[],@isnumeric); 
addParameter(p,'reflabels',{},@iscell); 
addParameter(p,'xlabel',plot_property(meas_name,'xlabel'),@iscell); 
addParameter(p,'ylabel',plot_property(meas_name,'ylabel'),@iscell); 
addParameter(p,'ylim',plot_property(meas_name,'ylim'),@isnumeric); 
addParameter(p,'xticks',plot_property(meas_name,'xticks'),@isnumeric); 
addParameter(p,'cflag','all',@ischar); % alternative: 'sep' (plot distributions in same or separate figures) 
addParameter(p,'fig','any',@ischar); % e.g. needed in paper2_fig6
addParameter(p,'visible','on',@ischar); % alternative: 'off'
addParameter(p,'data_choice',plot_property(meas_name,'data_choice'),@isnumeric);
addParameter(p,'d_vec',1,@isnumeric); % e.g. 1:3 needed in paper2_fig3
parse(p,ppa);  
 
mergestructs = @(x,y) cell2struct([struct2cell(x);struct2cell(y)],[fieldnames(x);fieldnames(y)]);
ppa = mergestructs(p.Results,p.Unmatched);

hist_mat = squeeze(hist_mat);   

% normalize histogram to visualize in the same plot with pdf 
stepsize_x = x(2)-x(1); 
if ~isempty(hist_mat)
    stepsize_x_h = x_h(2)-x_h(1);
    num_c = sum(hist_mat,2);
    hist_norm = 1./num_c * stepsize_x/stepsize_x_h; % difference in normalization depends on sampling (x vectors)
end

yrange = ppa.ylim; 
y_exponent = floor(log10(yrange(3))); % for ytick representation 
if strcmp(meas_name,'cafpas') % also ag_ac/ag_bc?
    y_exponent = -2; 
end

 
% plot distributions in same or separate figures
if strcmp(ppa.cflag,'all') % same figure
    figh = figure('visible',ppa.visible); 
end 
 
for c = 1:length(n_pdf_d) % separate figures
    if strcmp(ppa.cflag,'sep')
        figh(c) = figure('visible',ppa.visible);
    end
    
    hold on;
    box on;
    
    % reference lines if needed 
    if ~isempty(ppa.reflines)
        for k = 1:length(ppa.reflines)
            line([ppa.reflines(k) ppa.reflines(k)],[yrange(1) yrange(end)],'linestyle','--','color',[0.5 0.5 0.5]);
        end
        xpos = [x(1) ppa.reflines x(end)];

        for k = 1:length(ppa.reflabels)
            if ~isempty(ppa.reflabels{k}) 
                text(xpos(k)+(xpos(k+1)-xpos(k))/2,0.87*(yrange(end)-yrange(1)),ppa.reflabels{k},'horizontalalignment','center','fontsize',ppa.fsize-2,'color',[0.3 0.3 0.3]);
            end
        end
        
    end
      
    % Plot histograms
    if ppa.data_choice == 2 || ppa.data_choice == 4
        b(c) = bar(x_h,hist_norm(c)*hist_mat(c,:),'facecolor',ppa.colors{ppa.point(2,c)}); % (0.35*) 
    end

    if ppa.data_choice == 3 % tinnitus 
        xshift = [-0.22,+0.22];
        b(c) = bar(x_h+xshift(c),hist_norm(c)*hist_mat(c,:),0.4,'facecolor',ppa.colors{ppa.point(1,c)}); 
    end     
       
    % Plot distributions
    if ppa.data_choice == 1 || ppa.data_choice == 2
        for d = ppa.d_vec
            if length(ppa.d_vec)>1 && strcmp(ppa.fig,'p2-fig6') % needed for p2-fig6 (different colors not accessible by pp.point for different d)
                tmp_point = ppa.point;
                if d == 1 
                    ppa.point(1,c) = ppa.point(1,d);
                elseif d == 2
                    ppa.point(1,c) = ppa.point(1,d);
                elseif d == 3
                    ppa.point(1,c) = ppa.point(1,d);
                end
            end
            
            ph(c,d) = plot(x,n_pdf_d{c}(d,:),'color',ppa.colors{ppa.point(1,c)},'linewidth',1.5,'linestyle',ppa.linestyles{d});
            
            if length(ppa.d_vec)>1 && strcmp(ppa.fig,'p2-fig6')
                ppa.point = tmp_point;
            end
        end
    else
        ph = [];
    end   
     
    xlabel(ppa.xlabel,'FontSize',ppa.fsize); 
    yl = ylabel(ppa.ylabel,'FontSize',ppa.fsize);     
    set(yl, 'Units', 'Normalized', 'Position', [-0.1, 0.5, 0]); % more space for yticklabels
    
    if ~isempty(ppa.xticks)
        if all(ppa.xticks == [0 1]) % only tinnitus
            x(1) = -0.5;
            x(end) = 1.5;
            ppa.xticklabel = {'no','yes'}; 
        end
        set(gca,'FontSize',ppa.fsize,'XTick',ppa.xticks,'XTickLabel',ppa.xticklabel);
    end
    
    xlim([x(1) x(end)]);
    ylim(yrange([1,3])); 
    set(gca,'FontSize',ppa.fsize,'YTick',yrange(1):yrange(2):yrange(3)); 
    
     
    axh(c) = gca; 
    if isfield(ppa,'isOctave') % more complicated in Octave - needs to be done 
      if ppa.isOctave == 0
        axh(c).YAxis.Exponent = y_exponent; 
      else
        warning('Fix yticklabels in Octave'); 
      end
    end

   

    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 ppa.figwidth ppa.figheight]);

end

if strcmp(ppa.cflag,'all')
    if ppa.data_choice == 1 || ppa.data_choice == 2
        % sort lines such that all calculated distributions are visible (in
        % front of the bar plots)
        for c = 1:length(n_pdf_d) 
            for d = 1:size(n_pdf_d{c},1)
                uistack(ph(c,d),'top')
            end
        end
    end
    
end

end