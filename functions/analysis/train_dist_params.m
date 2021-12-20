% estimate parameters and weights of training distributions 
% 
% v1, MB 28.05.19
% 
% INPUT: 
% input_data
% cases_mat 
% idx_single
% num_params 
% x_vec 
% input_names
% dist_type 
% cross_validation      flag for cross-validation: 1: perform k-fold
%                       cross-validation, 0: do not perform cross-validation 
% 
% OUTPUT: 
% mu 
% sig 
% weight            % 3-4D: k, num_p, c, K (GMM components)
% logL 
% num_data          % exact number of datapoints available for each
%                   category, parameter, and k 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mu, sig, weight,logL,num_data] = train_dist_params(input_data,cases_mat,idx_single,num_params,x_vec,input_names,dist_type,cross_validation)
for m = 1:length(num_params)
    if ~isempty(idx_single)
        data = input_data{m}(idx_single,:);
    else 
        data = input_data{m}; 
    end
    
	% calculate parameters including *all* datapoints of one class - always
	% needed if regarded test datapoint is from different class 
    for c = 1:size(cases_mat,2)
        cases_idx = find(cases_mat(:,c));
        for num_p = 1:num_params(m)
            data_idx = ~isnan(data(cases_idx,num_p));
%             keyboard 
            [mu_all(num_p,c,:),sig_all(num_p,c,:),weight_all(num_p,c,:),logL_all(num_p,c,:)] = calc_dist_params(data(cases_idx(data_idx),num_p),input_names{m},x_vec{m},dist_type{m}); 
            num_data_all(num_p,c) = length(data(cases_idx(data_idx)));
        end
    end

if cross_validation 
    for c = 1:size(cases_mat,2)
%       c
        cases_idx = find(cases_mat(:,c));
        for num_p = 1:num_params(m)
%             num_p
                for k = 1:size(cases_mat,1)
                    if any(cases_idx == k) % 1,6,7
%                         disp(['datapoint ' num2str(k) ' (c = ' num2str(c) ') sorted out']); 
                        cv_idx = 1:length(cases_idx);
                        cv_idx = cv_idx(cases_idx ~= k); % raus: position von k in cases_idx 
                        data_idx = ~isnan(data(cases_idx(cv_idx),num_p));
                         
                        % berechne mu und sig (beta dist: transformed from a and b) ohne den Datenpunkt k
                        [mu_m(k,num_p,c,:),sig_m(k,num_p,c,:),weight_m(k,num_p,c,:),logL_m(k,num_p,c,:)] = calc_dist_params(data(cases_idx(cv_idx(data_idx)),num_p),input_names{m},x_vec{m},dist_type{m});  
                        num_data_m(k,num_p,c) = length(data(cases_idx(cv_idx(data_idx)))); 
%                        keyboard 
                    else
%                         disp(['set mu-all and sig-all for k = ' num2str(k) ' and c = ' num2str(c)]); 
                        % setze mu_all and sig_all ein 
                        mu_m(k,num_p,c,:) = mu_all(num_p,c,:); 
                        sig_m(k,num_p,c,:) = sig_all(num_p,c,:); 
                        weight_m(k,num_p,c,:) = weight_all(num_p,c,:); 
                        logL_m(k,num_p,c,:) = logL_all(num_p,c,:); 
                        num_data_m(k,num_p,c) = num_data_all(num_p,c); 
                    end 
%                      figure; plot(x_vec{m},gmm(weight_m(k,num_p,c,:),mu_m(k,num_p,c,:),sig_m(k,num_p,c,:),x_vec{m}))
%                     keyboard 
                end
        end
    end
    
else % cross_validation == 0 
    mu_m = reshape(mu_all,[1 size(mu_all)]); % 1. Dim. eigentlich nicht mehr benötigt, müsste dann aber in paper2_02_distributions auch angepasst werden - wäre effizienter, falls cross-validation nie gebraucht wird (Fall aber aktivierbar halten, Alternative wäre noch, k als letzte Dimension zu nehmen) 
    sig_m = reshape(sig_all,[1 size(sig_all)]); % reshape: add first dimension (singleton, but compatible to code in paper2_02_distributions)
    weight_m = reshape(weight_all,[1 size(weight_all)]); 
    logL_m = reshape(logL_all,[1 size(logL_all)]);
    num_data_m = reshape(num_data_all,[1 size(num_data_all)]); 
    
%     keyboard 
end

%    figure; plot(squeeze(logL_m(:,1,1,:))')
   
    
% Achtung, 1. Dimension nicht da, wenn keine 
    mu{m} = mu_m; % 3D: k, num_p, c 
    sig{m} = sig_m; % 3D: k, num_p, c 
    weight{m} = weight_m; % 3-4D: k, num_p, c, K (GMM components)
    logL{m} = logL_m; 
    num_data{m} = num_data_m; 
    
    
    clear mu_m;
    clear mu_all; 
    clear sig_m;
    clear sig_all; 
    clear weight_all; 
    clear weight_m;
    clear logL_all; 
    clear logL_m; 
    clear num_data_all; 
    clear num_data_m; 
    
    
end
end