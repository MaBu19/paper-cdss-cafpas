% plot_cafpas_survey_2(patients_filt, ...)
% 
% v1, MB 22.05.18
% MB 29.05.18: added estimation of median and interquartile ranges,
% moved plot properties into this function 
% MB 03.09.18: reorganized function, introduced plot_option 
% 
% INPUT: 
% structn       struct (or matrix) containing (filtered) data 
% plot_option   1: cafpa pattern; 2: imagesc all cases; 3: histograms
% pp            plot_properties
%  
% 
% OUTPUT: 
% figh 
% axh 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [figh,axh,varargout] = plot_cafpas_survey_2(structn,plot_option,pp)

% parse input parameters (struct pp)
p = inputParser;
p.KeepUnmatched = true;
% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
addParameter(p, 'figheight', 4.7, @isnumeric);
addParameter(p, 'figwidth', 4, @isnumeric); 
addParameter(p, 'fsize', 6, @isnumeric);
addParameter(p, 'calc_flag', 'median', @ischar); % median | mean (median used in papers)

parse(p,pp);  

mergestructs = @(x,y) cell2struct([struct2cell(x);struct2cell(y)],[fieldnames(x);fieldnames(y)]);
pp = mergestructs(p.Results,p.Unmatched);


% check data format 
if isstruct(structn)
    cafpas_mat = create_matrix_field(structn,'cafpas');
elseif isnumeric(structn)
    cafpas_mat = structn;
end


% calculate median/mean, quartiles 
% calc_flag = 'median'; % median | mean (median used in papers)

if strcmp(pp.calc_flag,'mean')
    cafpas_m = nanmean(cafpas_mat,1);
    cafpas_s = nanstd(cafpas_mat,[],1);
    cafpas_p25_50_75 = [cafpas_m'-cafpas_s',cafpas_m',cafpas_m'+cafpas_s']; 
elseif strcmp(pp.calc_flag,'median')
    cafpas_p25_50_75 = [];
    for ca = 1:10
        [cafpas_25,cafpas_50,cafpas_75] = calc_interquartiles(cafpas_mat(:,ca));
        cafpas_p25_50_75 = [cafpas_p25_50_75;cafpas_25,cafpas_50,cafpas_75];
    end
end

% plotting
if plot_option == 1 % typical "cafpa pattern"
    if strcmp(pp.calc_flag,'mean')
        [figh,axh] = plot_trafficlight_table_tl(cafpas_m,1,cafpas_s',pp);
    elseif strcmp(pp.calc_flag,'median')
        [figh,axh] = plot_trafficlight_table_tl(cafpas_p25_50_75(:,2),1,[cafpas_p25_50_75(:,1),cafpas_p25_50_75(:,3)],pp);
    end
    
    if pp.isOctave == 0 % needs to be included in plot_trafficlight_table_tl for usage in Octave
        % add CAFPA names
        cafpa_names_lc = {'C_{A1}','C_{A2}','C_{A3}','C_{A4}','C_{U1}','C_{U2}','C_{B}','C_{N}','C_{C}','C_{E}'};
        order = [7,8,9,10,5,6,3,4,1,2];
        for ca = 1:10
            text(axh(order(ca)),0.05,0.82,cafpa_names_lc{ca},'FontSize',pp.fsize); % y = 0.85
            
            if ca == 9
                text(axh(order(ca)),0.05,0.2,['{\itN} = ' num2str(size(cafpas_mat,1))],'FontSize',pp.fsize-2); % _{TN}
            end
        end
    end
    
elseif plot_option == 2 % matrix, single patients
    % add median/mean to matrix to be plotted
    tmp = cafpas_p25_50_75(:,2);
    cafpas_mat = [cafpas_mat; tmp'];
    % check cafpas
    figh = figure;
    axh = gca;
    imagesc(cafpas_mat);
    map = calc_colormap(rgb('FireBrick'),rgb('Gold'),rgb('DarkGreen')); map = map';
    colormap(map);
    colorbar
    caxis([0 1])
    t = text(0,size(cafpas_mat,1),'m');
    
    
elseif plot_option == 3 % only used for inspecting details (distribution) 
    %% Plotting details
    width = 20;
    height = 10;
    plnumx = 5;  %ncols
    plnumy = 2; %nrows
    
    % margins
    plytopmargin = 0.1; 
    plybottommargin = 0.05; 
    plxleftmargin = 0.1; 
    plxrightmargin = 0.1; 
    
    % distance between the small figures
    plxdist = 0.00/plnumx;
    plydist = 0.00/plnumy; 
    
    % now calculate the size of the figures
    plxsize = (1 - plxleftmargin - plxrightmargin - (plxdist*(plnumx-1)))/plnumx;
    plysize = (1 - plytopmargin - plybottommargin - (plydist*(plnumy-1)))/plnumy;
    
    cafpa_names_lc = {'C_{A1}','C_{A2}','C_{A3}','C_{A4}','C_{U1}','C_{U2}','C_{B}','C_{N}','C_{C}','C_{E}'};
    
    figh = figure;
    axh = [];
    for k = 1:10
        if k <=5
            actnumx = k;
            actnumy = 1;
        else
            actnumx = k-5;
            actnumy = 2;
        end
        h_tmp = subplot('position',[((actnumx-1)*(1*plxsize+plxdist) +plxleftmargin) ((actnumy-1)*(plysize+plydist) + plybottommargin) 1*plxsize plysize]);
        hold on
        x = 0:0.05:1; yl = 0; yu = size(cafpas_mat,1)*1.1;
        
        line([cafpas_p25_50_75(k,1) cafpas_p25_50_75(k,1)],[yl yu],[0 0],'color','b','Linestyle','--');
        line([cafpas_p25_50_75(k,2) cafpas_p25_50_75(k,2)],[yl yu],[0 0],'color','b','Linestyle','-');
        line([cafpas_p25_50_75(k,3) cafpas_p25_50_75(k,3)],[yl yu],[0 0],'color','b','Linestyle','--');
        
        [histo, xs, s] = calc_histo_mean_std(cafpas_mat(:,k),x);
        bar(h_tmp,x,histo);
        xlim([0 1]);
        
        ylim([yl yu]);
        
        t = text(0.8,0.92*yu,cafpa_names_lc{k});
        if any([2,3,4,5,7,8,9,10]==k)
            set(h_tmp,'YTick',[]);
        end
        if any([6,7,8,9,10]==k)
            set(h_tmp,'XTick',[]);
        else
            set(h_tmp,'XTick',[0.5,1]);
        end
        
        box on
        axh = [axh,h_tmp];
       
    end
end

varargout{1} = cafpas_p25_50_75; % for mean or median        

end
