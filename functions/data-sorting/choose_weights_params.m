% choose_weights_params: choose weights to be used in classification
% (parameters of measure/combinations of measures)
%
% Mareike Buhl 
% mareike.buhl@uol.de
% v1, 09.07.20 
% 
% adapted from definition_weights_params, v2
% 
% Functionality: 
% 
% INPUT: 
% weights_idx       1: uniform weights, 2: all binary combinations
% num_params        number of parameters (of measure)
% varargin          {1} m_ex: indices of measures that should be excluded
%                   from weights (e.g. CAFPAs in all measure combinations)
% 
% OUTPUT: 
% w_params          weight matrix [num_w, num_params]
% 
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w_params = choose_weights_params(weights_idx,num_params,varargin)

m_ex = []; 
if ~isempty(varargin)
    m_ex = varargin{1}; 
end

switch weights_idx
    case 'uniform' % uniform weights
        for m = 1:length(num_params)
            w_params{m} = [ones(1,num_params(m))/num_params(m)];
        end
    case 'all-binary' % all binary combinations
        for m = 1:length(num_params)
            w_params{m} = dec2bin(1:2^num_params(m)-1)-'0';
            if ~isempty(m_ex)
                ex_idx = find(w_params{m}(:,m_ex)); 
                w_params{m}(ex_idx,:) = []; % delete rows where col m_ex = 1 
            end
            w_params{m} = w_params{m}./repmat(sum(w_params{m},2),1,num_params(m));
            
        end
end


end