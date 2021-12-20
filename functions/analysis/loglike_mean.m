% calculate average likelihood per datapoint (within category) and sum over
% categories (within certain distribution)
% - assumes that 
% 
% v1, MB 11.06.19
% 
% INPUT: 
% logL      logL values calculated by train_dist_params [{m},k,num_p,c,N (number of iterations)]
% num_data  number of datapoints per category [{m},k,num_p,c]
% norm_flag 'cat': normalize log_cat to number of datapoints per category and 
%           then log_sum to number of categories (each category counts the
%           same)
%           'datapoints': don't normalize log_cat, normalize log_sum to total number
%           of datapoint (each datapoint counts the same) 
% 
% OUTPUT: 
% log_sum   sum over categories; normalization according to norm_flag; [{m},k,num_p]
% log_cat   mean logL contribution per datapoint; normalization according to norm_flag; [{m},k,num_p,c]
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [log_sum log_cat] = loglike_mean(logL,num_data,norm_flag)

for m = 1:length(logL)
    
    if strcmp(norm_flag,'cat')
        log_cat{m} = logL{m}(:,:,:,end)./num_data{m}(:,:,:);
        log_sum{m} = sum(log_cat{m}(:,:,:),3)./size(logL{m},3);
    elseif strcmp(norm_flag,'datapoints')
        log_cat{m} = logL{m}(:,:,:,end);
        log_sum{m} = sum(log_cat{m}(:,:,:),3)./sum(num_data{m},3);
    end 
    

%     % for calculating a factor... (adapt if needed)
%     for d1 = 1:length(dist_type)
%         for d2 = 1:length(dist_type)
%             fsum(d1,d2) = exp(log_sum(d1,end)-log_sum(d2,end)); % <1 for log_sum(d1,end) < log_sum(d2,end), >1 for log_sum(d1,end) > log_sum(d2,end)
%         end
%     end
%     fsum
end
