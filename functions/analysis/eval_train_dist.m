% evaluate training distribution at position given by test datapoints
% (measure/CAFPA results)
% 
% Mareike Buhl
% mareike.buhl@uol.de
% v1 09.07.20
% 
% parts taken from classify_max, v1, MB 13.08.19
% 
% INPUT: 
% x             x-vector for probability density function 
% data          test datapoints for given measurement [k,num_params]
% mu            distribution parameter mu [num_p,c] 
% sig           distribution parameter sigma [num_p,c]
% dist_type     defines which distribution is used as probability density
%               function ('manual'(beta for cafpas)/'gmm-1')
% 
% 
% OUTPUT: 
% p_eval        probability evaluated at x-position defined by test
%               datapoint k [k,num_p,c] 
% lh            uncertainty values of category 1 and 2 (3rd dim: c)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p_eval,lh,pdf_vec] = eval_train_dist(x,data,mu,sig,dist_type)
stepsize = x(2)-x(1); 
num_params = size(mu,1); 
num_c = size(mu,2); 
num_k = size(data,1); 

%% evaluate distribution functions for compared categories at x-position defined by data
for num_p = 1:num_params
    for c = 1:num_c
        pdf_vec(num_p,c,:) = calc_npdf(x,mu(num_p,c),sig(num_p,c),1,stepsize,dist_type);      
        for k = 1:num_k
            p_eval(k,num_p,c) = interp1(x,squeeze(pdf_vec(num_p,c,:))',data(k,num_p),'nearest'); % hier sicherstellen, dass CAFPAs nicht negativ max(data,0) --> sonst komische Klassifikation, da auch negative WK oder Sicherheit passieren kann
        end
    end
end   


 
% uncertainty measure
lh_tmp1 = p_eval(:,:,1)./(sum(p_eval,3)+eps);
lh_tmp2 = p_eval(:,:,2)./(sum(p_eval,3)+eps); 

idx0 = logical((lh_tmp1==0) .*(lh_tmp2==0));
lh_tmp1(idx0) = 0.5;  % 0 happens if both p_eval values are 0 --> same values, certainty 0.5
lh_tmp2(idx0) = 0.5; 
lh = cat(3,lh_tmp1,lh_tmp2);

lh(isnan(lh)) = 0.5; % nan happens if no data are available for a CAFPA --> certainty 0.5

% 
% figure; imagesc(lh1)
% figure; imagesc(lh2)
% % figure; imagesc(lh1+lh2) % check --> 1 
% 
% % plot für alle möglichen Werte von data 
% figure; 
% hold on;
% box on; 
% plot(x,squeeze(pdf_vec(10,1,:)),'r')
% plot(x,squeeze(pdf_vec(10,2,:)),'b')
% 
% figure; 
% hold on; 
% box on; 
% plot(data(:,10),lh1(:,10),'rx')
% plot(data(:,10),lh2(:,10),'bx')

    
end