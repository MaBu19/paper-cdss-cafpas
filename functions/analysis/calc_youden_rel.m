% estimate datapoints with Youden index larger than th % of the
% maximum Youden index of the data 
% Y = sens + spec -1 
% 
% 
% Mareike Buhl
% mareike.buhl@uol.de
% v1 10.07.20
% adapted from opt_weights v1 19.08.19 
% 
% 
% INPUT: 
% spec              specificity cell/mat 
% sens              sensitivity cell/mat 
% th                threshold to be applied, e.g. 0.98 in Buhl et al. (2020b)
% 
% OUTPUT: 
% idx_choice
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [idx_choice] = calc_youden_rel(spec,sens,th)
 
if iscell(spec) 
    num_cell = length(spec); 
    for n = 1:num_cell
        % estimate youden index for spec{n}, sens{n}
        % estimate Y>th
        % save idx vector in idx_choice{n}
    end
elseif isnumeric(spec) % e.g. 'p3-fig5', 'p3-fig7'
        % estimate y for spec, sens
        y = sens + spec - 1; 
        % estimate Y>th
        ymax = th*max(y); 
        idx_choice = find(y>ymax);    
end
    



end
