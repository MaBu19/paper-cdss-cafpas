% combine parameters of different measurements (e.g., paper 3) for
% classification - by multiplication of probabilities and applying weights
% (exponents)
% (calculations done in log space: log(p) and multiplication of weights)
% 
% v3, MB 09.07.20 (removed classification from this function)
% v2, MB 28.02.20 (changed from cells to matrices)
% (v1, MB 13.08.19)
% 
% 
% INPUT: 
% log_p_eval        log(p), probability functions evaluated at x-positions
%                   given by datapoints [k,num_p,c], in logarithmic space
% w                 matrix containing rows of weights (all to-be-tested
%                   combinations) [num_w_vec,num_p], weights are used as 
%                   factors in a linear-combination of the probabilities (log!) 
% 
% p_sum             probability of combined parameters, log space {num_w_vec}[k,c]
% classifier_out    contains indices of classified categories (0 = no
%                   classification possible due to nan values) [k,num_w_vec] 
% 
% Note: changed from cell (v1) to matrix format (v2) for compatibility
% reasons in main_v0_1 and module_analysis() - then this function can be
% applied several times (e.g., first apply weights within measurement and
% then across measurements)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p_sum] = combine_parameters(log_p_eval,w)

num_w_vecs = size(w,1); 
num_c = size(log_p_eval,3);

for ws = 1:num_w_vecs % (all-binary: time-consuming)
    for c = 1:num_c 
        p_w(:,ws,:) = log_p_eval(:,:,c).*repmat(w(ws,:),size(log_p_eval,1),1); 
        
        for k = 1:size(p_w,1)
            p_sum(k,ws,c) = sum(p_w(k,ws,~isnan(p_w(k,ws,:))));
        end
    end
      
end
end