% define plot_header
% 
% v1, MB 06.08.19
% 
% INPUT: 
% cats              cell with index combination for comparison 
% filter_crit       'reha'/'findings'
% 
% OUTPUT: 
% plot_header       for axes etc. 
% plot_header_long  for titles etc. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [plot_header, plot_header_long] = define_plot_header(cats,filter_crit)

% definitions 
findings_header = {'nh','high','low','mid','bb','cond', ...
    'cent','recr','fluct'}; 
findings_header_long = {'Normal hearing','High-freq. HL','Low-freq. HL','Middle-freq. HL','Broadband HL','Conductive HL','Central HL','Recruitment','Fluctuating HL'}; 
reha_header = {'CI','EAS','closed','HiPow', ...
    'none','bone','MEI','open','other'}; 
reha_header_long = {'Cochlear implant','Electroacoustic stimulation','Closed hearing aid','High-power hearing aid','No provision','Bone-anch. hearing aid','Middle-ear implant','Open hearing aid','Other'};
reha_order = [5,8,3,4,2,1,6,7,9]; 

if strcmp(filter_crit,'reha')
    filter_header = reha_header; 
    filter_header_long = reha_header_long; 
elseif strcmp(filter_crit,'findings')
    filter_header = findings_header; 
    filter_header_long = findings_header_long; 
end



%% for plotting - strings 
% title_cats = ''; 
if strcmp(filter_crit,'reha')
    for c = 1:length(cats)
        if length(cats{c}) == 1
            plot_header(c) = filter_header(cats{c});
            plot_header_long(c) = filter_header_long(cats{c});
        elseif length(cats{c}) == 3 && sum(cats{c} == [8,3,4]) == 3; % sum durch all ersetzen
            plot_header(c) = {'HA'};
            plot_header_long(c) = {'Hearing aid'}; 
        elseif length(cats{c}) == 2 && sum(cats{c} == [6,7]) == 2;
            plot_header(c) = {'bone'};
            plot_header_long(c) = {'Bone-anch. device'}; 
        elseif length(cats{c}) == 8 && sum(cats{c} == [1 2 3 4 6 7 8 9]) == 8;
            plot_header(c) = {'device'};
            plot_header_long(c) = {'Hearing device'}; 
        end
    end
elseif strcmp(filter_crit,'findings')
    for c = 1:length(cats)
        if length(cats{c}) == 1
            plot_header(c) = filter_header(cats{c});
            plot_header_long(c) = filter_header_long(cats{c});
        elseif length(cats{c}) == 4 && sum(cats{c} == [2,3,4,5]) == 4 ;
            plot_header(c) = {'cochl'};
            plot_header_long(c) = {'Cochlear HL'}; 
        elseif length(cats{c}) == 2 && sum(cats{c} == [2,6]) == 2;
            plot_header(c) = {'high+cond'};
            plot_header_long(c) = {'High-freq. & cond. HL'}; 
        elseif length(cats{c}) == 2 && sum(cats{c} == [2,8]) == 2;
            plot_header(c) = {'high+recr'};
            plot_header_long(c) = {'High-freq. & Recruitment'}; 
        elseif length(cats{c}) == 8 && sum(cats{c} == [2:9]) == 8;
            plot_header(c) = {'hi'};
            plot_header_long(c) = {'Hearing impaired'}; 
        end
    end
end


end