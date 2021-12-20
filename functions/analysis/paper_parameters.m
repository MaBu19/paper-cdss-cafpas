% definition of classification parameters to reproduce figures (of paper 3)
% 
% 
% Mareike Buhl
% mareike.buhl@uol.de
% v1 09.07.20
% 
% 
% INPUT: 
% paper_figure      string containing paper and figure number 
% 
% OUTPUT: 
% wp_idx            idx for choice of weights according to
%                   choose_weights_params (between parameters)
% wm_idx            idx for choice of weights according to
%                   choose_weights_params (between measures/including the 
%                   weighted probs using wp_idx)
% m_ex              indices of params/meas to be excluded in weights (e.g.
%                   CAFPAs from combination of all measures) 
% pp                struct containing plot properties 
% 	pp.point 		first row: color, second row: markerfacecolor, third row: symbol
%   pp.data_choice  1: lines, 2: lines and bars, 3: bars (tinnitus), 4: only bars
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [wp_idx, wm_idx, m_ex, pp] = paper_parameters(paper_figure)
wp_idx = ''; 
wm_idx = ''; 
m_ex = ''; 

switch paper_figure
    case 'p2-fig5'
        pp.point = [20 6 4 2 3; 20 6 4 2 3 ; 1 1 1 1 1];  
        pp.figwidth = 4.0; 
    case 'p2-fig6'
        pp.data_choice = 2; % lines and bars 
        pp.linestyles = {'-','-','-'}; 
        pp.cflag = 'sep'; 
        pp.point = [14 19 6; 21 21 21; 1 1 1]; 
        pp.fig = 'p2-fig6'; 
    case 'p2-fig8'; 
        

    case 'p3-fig4'
        wp_idx = 'uniform'; 
        wm_idx = ''; 
        pp.point = [3*ones(1,14); [3 3 15 15 15 15 15 15 15 3 3 3 3 15]; [8 2 5 7 10 11 12 6 2 3 9 4 1 1]]; % color-line, color-fill, symbol (cf. coloridx)
    case 'p3-fig5'
        wp_idx = 'all-binary'; 
        wm_idx = ''; 
        pp.point = [1 17; 1 17; 1 1]; % color is replaced by m in loop over measures 
    case 'p3-fig6'
        wp_idx = 'all-binary'; 
        wm_idx = ''; 
        pp.point = [13 17; 13 17; 1 1]; 
    case 'p3-fig7'
        wp_idx = 'uniform'; 
        wm_idx = 'all-binary'; 
        m_ex = 'cafpas'; % 13, to exclude CAFPAs from measures combinations 
        pp.point = [1 13 17 17; 1 15 17 15; 8 1 8 1]; % blue-d green-o red-d red-o
    case 'p4-fig7'
    case 'p4-fig11'
        pp.point = [ones(1,10); ones(1,10); 1:10]; 
        pp.legend = {'C_{A1}','C_{A2}','C_{A3}','C_{A4}','C_{U1}','C_{U2}','C_{B}','C_{N}','C_{C}','C_{E}'};
    case 'p4-fig12' 
        wp_idx = 'all-binary'; 
        wm_idx = ''; 
        pp.point = [1 17; 1 17; 1 1]; % color is replaced by in loop over measures 
    case 'p4-fig13'
        wp_idx = 'all-binary'; 
        wm_idx = ''; 
        pp.point = [13 17; 13 17; 1 1]; 
    case 'p4-fig14'
        wp_idx = 'all-binary'; 
        wm_idx = ''; 
        pp.point = [13 17; 13 17; 1 1]; 
    case 'p4-fig15'
        pp.cflag = 'sep'; 
        wp_idx = 'all-binary'; 
        wm_idx = ''; 
        pp.point = [13 17; 13 17; 1 1]; 
    case 'p4-fig16'
        wp_idx = 'all-binary'; 
        wm_idx = ''; 
        pp.point = [13 17; 15 15; 1 1]; 
    case 'p4-fig18'
        wp_idx = 'all-binary'; 
        wm_idx = ''; 
        pp.point = [13 17; 15 15; 1 1]; % update?
        
end



% for figure filenames 
pp.wstr = strjoin({wp_idx,wm_idx},'_'); 
if strcmp(pp.wstr(end),'_') 
    pp.wstr(end) = ''; 
end




end 
