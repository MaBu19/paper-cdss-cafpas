% small function for plotting std errorbar with length stdprob at position x_line 
% (CAFPA trafficlight plots)
% 
% v1, MB 22.05.18
% 05.02.19: added possibility to plot error bar vertically - variable dir 
% 
% INPUT: 
% meanprob      mean (x_line, where vertical bar is located in the colormap
% inset plot)
% stdprob       std corresponding to mean/median 
% dir           direction of errorbar: 1: horizontal, 2: vertical
% [pos width]   position of errorbar (mean/median) and width of bar ends
% 
% OUTPUT: 
% directly plot errorbar in the inset plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function add_std(meanprob, stdprob, varargin)
if ~isempty(varargin)
    dir = varargin{1};
    if length(varargin) == 2
        pos = varargin{2}(1); 
        width = varargin{2}(2); 
    else 
        pos = 1; % ypos for dir == 1, xpos for dir == 2
        width = 0.1; % width of end of bar in x direction for dir == 1, in y direction for dir == 2 
    end
else 
    dir = 1; % default - for CAFPA plots
    pos = 1; 
    width = 0.1; 
end




if dir == 1 % plot horizontally
    if length(stdprob) == 1 % mean and std
        line([meanprob-stdprob meanprob+stdprob],[pos pos],'color','k','linewidth',1); % vorher [1,1]
        line([meanprob-stdprob meanprob-stdprob],[pos-width pos+width],'color','k','linewidth',1); % [0.9 1.1]
        line([meanprob+stdprob meanprob+stdprob],[pos-width pos+width],'color','k','linewidth',1); % [0.9 1.1] 
    elseif length(stdprob) == 2 % median and interquartile ranges
        line([stdprob(1) stdprob(2)],[pos pos],'color','k','linewidth',1);
        line([stdprob(1) stdprob(1)],[pos-width pos+width],'color','k','linewidth',1);
        line([stdprob(2) stdprob(2)],[pos-width pos+width],'color','k','linewidth',1);
        %     keyboard
    end
elseif dir == 2 % plot vertically
    if length(stdprob) == 1 
        line([pos pos],[meanprob-stdprob meanprob+stdprob],'color','k','linewidth',1);
        line([pos-width pos+width],[meanprob-stdprob meanprob-stdprob],'color','k','linewidth',1);
        line([pos-width pos+width],[meanprob+stdprob meanprob+stdprob],'color','k','linewidth',1);
    elseif length(stdprob) == 2
        line([pos pos],[stdprob(1) stdprob(2)],'color','k','linewidth',1);
        line([pos-width pos+width],[stdprob(1) stdprob(1)],'color','k','linewidth',1);
        line([pos-width pos+width],[stdprob(2) stdprob(2)],'color','k','linewidth',1);
    end
        
    
end
end