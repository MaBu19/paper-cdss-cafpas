% function plot_trafficlight_table_tl() plots CAFPA results in trafficlight
% representation as it was used in the expert survey
%
% (v1 MB 29.09.16)
% v2 MB 22.05.18 (adapted for plotting results of cafpa-survey-2: added stdprob for continuous CAFPAs)
% 29.05.18: added option for median and interquartile ranges
% 16.09.20: removed variability with num_lights (outdated) - num_lights = 1
% needed (kept for compatibility if function is called elsewhere)
%
% input:
% meanprob      vector of mean probabilities
% num_lights    number of traffic lights (typically 1)
% stdprob       (varargin{1}) vector of stds of probabilities
%
%
% output:
% fh,h      figure handles
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fh, h] = plot_trafficlight_table_tl(meanprob,num_lights,varargin)

%% Plotting details
width = 10;
height = 12;
plnumx = 4;  %ncols
plnumy = 4; %nrows

% margins
plytopmargin = 0.1; 
plybottommargin = 0.18; 
plxleftmargin = 0.02; 
plxrightmargin = 0.02; 

% distance between the small figures
plxdist = 0.00/plnumx;
plydist = 0.00/plnumy; 

% now calculate the size of the figures
plxsize = (1 - plxleftmargin - plxrightmargin - (plxdist*(plnumx-1)))/plnumx;
plysize = (1 - plytopmargin - plybottommargin - (plydist*(plnumy-1)))/plnumy;

visflag = 'on'; %default 

%% ordering of meanprob according to subplot order
order = [9,10,7,8,5,6,1,2,3,4];
meanprob_sp = meanprob(order); meanprob = meanprob_sp;

meanprob(isnan(meanprob)) = 0.5; % rarely happening

% fill box with respective traffic light color:
fill_flag = 1; % defaults: 1
% plot colormap inset plot
map_flag = 1; % default: 1


% check if standard deviation/interquartiles are given
std_flag = 0;
quart_flag = 0;
if ~isempty(varargin)
    stdprob = varargin{1};
    stdprob_sp = stdprob(order,:); stdprob = stdprob_sp;
    if size(stdprob,2) == 1;
        std_flag = 1; % plot mean and std
    elseif size(stdprob,2) == 2;
        quart_flag = 1;  % plot median and interquartiles
    end
    
    if length(varargin) == 2
        pp = varargin{2};
        width = pp.figwidth;
        height = pp.figheight;
        fsize = pp.fsize;
        vis_flag = pp.visible; 
    end
end

%% plotting
fh = figure('visible',vis_flag);
h = [];
map = calc_colormap(rgb('FireBrick'),rgb('Gold'),rgb('DarkGreen')); map = map';
% map = calc_colormap(rgb('DarkBlue'),rgb('CornflowerBlue'),rgb('White')); map = map';
% map = repmat(linspace(1,0,100)',1,3);
% map = [linspace(0,1,100)',linspace(0,1,100)',linspace(0.54,1,100)']; % Blau-Weiß
% map = [linspace(1,1,100)',linspace(0.4,1,100)',linspace(0,1,100)']; %
% Orange-Weiß (Medi-Vortrag 05.01.2021)


for actnumy = 1:3
    for actnumx = 1:2
        k = actnumx+2*(actnumy-1);
        h_tmp = subplot('position',[((actnumx-1)*(2*plxsize+plxdist) +plxleftmargin) ((actnumy-1)*(plysize+plydist) + plybottommargin) 2*plxsize plysize]);
        hold on
        axis([0 2 0 1]);
        if num_lights ~= 1
            ax2 = axes('position',[0.505*plxsize + ((actnumx-1)*(2*plxsize+plxdist) +plxleftmargin) 0.2*plysize + ((actnumy-1)*(plysize+plydist) + plybottommargin) 0.99*plxsize 0.99*0.5*plysize]); % oder vorne 0.2 und hinten 0.8*2, wenn Ampeln doppelt so groß wie Audiogramm-CAFPa-Ampeln sein duerfen
            set(ax2,'Visible','Off');
        else
            map_idx = ceil(meanprob(k)*100);
            if map_idx == 0
                map_idx = 1;
            end
            
            % fill box with respective traffic light color:
            if fill_flag
                color = map(map_idx,:);
                s = fill([0 2 2 0],[1 1 0 0],color);
            end
            
            % inset colormap:
            if map_flag
                ax3 = axes('position',[1.46*plxsize + ((actnumx-1)*(2*plxsize+plxdist) +plxleftmargin) 0.22*plysize + ((actnumy-1)*(plysize+plydist) + plybottommargin) 0.99*0.5*plxsize 0.99*0.5*0.5*plysize]);
                if std_flag
                    plot_colormap_p(h_tmp,map,meanprob(k),ax3,stdprob(k));
                elseif quart_flag
                    plot_colormap_p(h_tmp,map,meanprob(k),ax3,stdprob(k,:));
                else
                    plot_colormap_p(h_tmp,map,meanprob(k),ax3);
                end
            end
            
            % add CAFPA names here (octave)
            
        end
        
        
        box(h_tmp,'on');
        set(h_tmp, 'XTick', []);
        set(h_tmp, 'YTick', []);
        h = [h,h_tmp];
        
    end
end


actnumy = 4;
for actnumx = 1:4
    k = actnumx+6;
    h_tmp = subplot('position',[((actnumx-1)*(plxsize+plxdist) +plxleftmargin) ((actnumy-1)*(plysize+plydist) + plybottommargin) plxsize plysize]);
    hold on
    axis([0 1 0 1]);
    if num_lights ~= 1
        ax2 = axes('position',[0.005*plxsize + ((actnumx-1)*(plxsize+plxdist) +plxleftmargin) 0.2*plysize + ((actnumy-1)*(plysize+plydist) + plybottommargin) 0.99*plxsize 0.99*0.5*plysize]);
        set(ax2,'Visible','Off');
    else
        map_idx = ceil(meanprob(k)*100);
        if map_idx == 0
            map_idx = 1;
        end
        % fill box with respective traffic light color:
        if fill_flag
            color = map(map_idx,:);
            s = fill([0 1 1 0],[1 1 0 0],color);
        end
        % inset colormap:
        if map_flag
            ax3 = axes('position',[0.46*plxsize + ((actnumx-1)*(plxsize+plxdist) +plxleftmargin) 0.22*plysize + ((actnumy-1)*(plysize+plydist) + plybottommargin) 0.99*0.5*plxsize 0.99*0.5*0.5*plysize]);
            if std_flag
                plot_colormap_p(h_tmp,map,meanprob(k),ax3,stdprob(k));
            elseif quart_flag
                plot_colormap_p(h_tmp,map,meanprob(k),ax3,stdprob(k,:));
            else
                plot_colormap_p(h_tmp,map,meanprob(k),ax3);
            end
            
        end
    end
    
    box(h_tmp,'on');
    set(h_tmp, 'XTick', []);
    set(h_tmp, 'YTick', []);
    h = [h,h_tmp];
end

orient tall
fh = gcf; % 12.02.19 - to access whole figure with figure handle, and not the last subfigure

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 width height]);

end

