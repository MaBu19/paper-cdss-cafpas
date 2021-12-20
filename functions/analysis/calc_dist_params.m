function [p1,p2,weight,logL] = calc_dist_params(data_vec,input_name,x_vec,dist_type)
  


stepsize = x_vec(2)-x_vec(1);
weight = 1; % default 


% if strcmp(dist_type,'manual')
    % if subset of parameters is indicated within input_name
%     str_part = strsplit(input_name,';');
%     input_name = str_part{1};
    
    switch dist_type
        case {'gmm-1'}
%     switch input_name
%         case {'ag_ac','ag_bc','deg_hl','acalos_1_5','acalos_4','swi_sum','goesa','hp_quiet','hp_noise','wst_raw','demtect','age','ABG'} % acalos: Verteilung noch checken: welche passt am besten... 
            [p1,p2] = normfit(data_vec); % mu, sigma
            
            %         phat = betafit((data_vec+10)/130);
            %         p1 = phat(1); % beta parameter a
            %         p2 = phat(2); % beta parameter b
            
            
            % for likelihood: (sollte in diesem Fall identisch zu gmm-1
            % sein - ist auch der Fall )             
            log_likelihood = 0;
            for k = 1:length(data_vec)
                p = stepsize*normpdf(data_vec(k),p1,p2); 
               
                log_likelihood = log_likelihood + log(p); 
                
            end            
        case 'beta'
%             keyboard 
            if length(data_vec)>1
                phat = betafit(data_vec);
                p1 = phat(1); % beta parameter a
                p2 = phat(2); % beta parameter b
                
                %         [p1,p2] = normfit(data_vec); % mu, sigma
                
                % hiermit würde man erreichen, dass Beta-Verteilungen durch (0,0)
                % und (1,0) gehen - dafür muss a>1 und b>1 gelten (aber
                % mathematisch nicht korrekt gelöst, da man vor dem Fit die Werte
                % ausschließen müsste und nicht nachträglich manipulieren - aber
                % sowieso nach Diskussion mit Marcel (13.02.19) entschieden, dass
                % es mit der "korrekten" Beta-Verteilung passt (und
                % Klassifikationsergebnisse sind auch ähnlich in beiden Versionen)
                %         p1 = max(phat(1),1.2); % beta parameter a, Schwellen ggf. anpassen
                %         p2 = max(phat(2),1.2); % beta parameter b
                
                
                % for likelihood:
                log_likelihood = 0;
                for k = 1:length(data_vec)
                    p = stepsize*betapdf(data_vec(k),p1,p2);
                    
                    log_likelihood = log_likelihood + log(p);
                    
                end
                
                % transform to mu and sig:
                [p1,p2] = beta_mu_sig(p1,p2);
            else
                log_likelihood = nan; 
                p1 = nan; p2 = nan;
            end

        case 'cat' 
          a = hist(data_vec,0:1); 
          tmp = a/sum(a); % just probabilities --> directly estimated the (binary) distribution 
          p1 = tmp(1); 
          p2 = tmp(2); 
          
          
          % for likelihood:               
            log_likelihood = 0;
            for k = 1:length(data_vec)
                p = stepsize*betapdf(data_vec(k),p1,p2); 
                
                log_likelihood = log_likelihood + log(p); 
                
            end
            
        case 'gmm-2' % gmm-1 could also be determined using em_gmm()
            str_dist = strsplit(dist_type,'-');
            dist_type = str_dist{1};
            if length(str_dist) > 1
                K = str2num(str_dist{2}); % number of GMM components
            end
            
            N = 10; % number of EM iterations
            adapt_flag = 0; % 1: adaptive number of GMM components (with K initial number), 0: else (could be coded in dist-type)
            
            if ~isempty(data_vec) % possibly add additional condition, e.g. length(data_vec) > xy (assume valid distribution estimation)
                [weight, mu, sigma, logL] = em_gmm(x_vec, data_vec, K, N, adapt_flag);
                %         [mean(data_vec),std(data_vec)]
            else
                weight = nan(1,K);
                mu = nan(1,K);
                sigma = nan(1,K);
                logL = nan(1,N);
            end
            
            p1 = mu;
            p2 = sigma;
            log_likelihood = logL; 
            
    end
%     weight = 1; % nach oben 
    logL = log_likelihood; 
 
% elseif strcmp(dist_type,'gmm-2') % als case nach oben, gmm-1 könnte natürlich weiterhin auch so bestimmt werden 
    
    

% end
% für Vergleichbarkeit mit anderen dist_types (Matrixgrößen) - am Ende wird
% eh nur logL(end) genommen
if length(logL) == 1 
%     keyboard 
    logL = [zeros(1,9) logL]; 
end

end