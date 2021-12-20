% perform classification (max of p_eval for compared categories)
% 
% 
% Mareike Buhl
% mareike.buhl@uol.de
% v1 09.07.20
% 
% parts taken from classify_max, v1, MB 13.08.19
% 
% INPUT: 
% p_eval        probability evaluated at x-position defined by test
%               datapoint k [k,num_p,c] 
% 
% OUTPUT: 
% classifier    contains indices of classified categories (0 = no
%               classification possible due to nan values) [k,num_p]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [classifier] = classify_data(p_eval)

classifier = zeros(size(p_eval,1),size(p_eval,2));
nan_idx = ~isnan(p_eval);

[~,tmp_classifier] = max(p_eval,[],3); % [k x num_p]
classifier(nan_idx(:,:,1)) = tmp_classifier(nan_idx(:,:,1)); % zero where no probabilities were available - needs to be considered in histogram 

end