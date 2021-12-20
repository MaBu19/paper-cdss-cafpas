% define all characteristic properties of (binary) comparison sets of categories as
% used in paper 2 (Buhl et al. 2020a) and paper 3 (Buhl et al. 2020b)
% 
% Mareike Buhl
% mareike.buhl@uol.de
% v1 09.07.20
% 
% parts taken from definition_comparisons, v1, MB 06.08.19
% 
% INPUT: 
% comp              string containing the compared categories: 'cat1-cat2'
% 
% OUTPUT: 
% filter_crit       'reha'/'findings'    
% cats              cell with index combination 
% single_flag       0: all ticks, 
%                   1: "single tick" (datapoint must belong to one of the distinct categories, datapoints with both ticks are excluded), 
%                   2: "joint tick" (compare exact datapoint combinations as given by cats) 
% 
% plot_header       to have some strings available for plotting 
% plot_header_long 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [filter_crit,cats,single_flag,plot_header,plot_header_long] = definition_comparisons(comp)

switch comp
    case 'nh-hi' % 1
        filter_crit = 'findings';
        cats = {1,[2:9]};
        single_flag = 1;
    case 'high-high+cond' % 2
        filter_crit = 'findings';
        cats = {2,[2,6]};
        single_flag = 2;
    case 'high-high+recr' % 3
        filter_crit = 'findings';
        cats = {2,[2,8]};
        single_flag = 2;
    case 'none-device' % 4
        filter_crit = 'reha';
        cats = {5,[1 2 3 4 6 7 8 9]};
        single_flag = 1;
    case 'HA-CI' % 5
        filter_crit = 'reha';
        cats = {[8,3,4],1};
        single_flag = 1;
    case 'none-CI' % 6
        filter_crit = 'reha';
        cats = {5,1};
        single_flag = 1;
end

% --> could be called everywhere/also outside this function: 
% define plot_header according to categories and filter_crit
[plot_header, plot_header_long] = define_plot_header(cats,filter_crit); 

end







