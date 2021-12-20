% calculate ROC parameters: sensitivity, specificity 
% 
% v1, MB 01.08.19
% 
% according to Hedderich and Sachs (2018), p. 186 ff. 
% Spezifität: P(T-|nK), Anteil negativer Testergebnisse unter den Gesunden
%
% assumption: two distinct categories are compared, i.e. cat2 = ~cat1
% identify  "test" with "classification", T+ = cat1, T- = cat2 
%           "ill/not ill" with "expert tick" (ground truth), [1 0] = cat1,
%           [0 1] = cat2
% 
% INPUT: 
% 
% 
% OUTPUT: 
% sens      sensitivity
% spec      specificity
% evtl. weitere (s. Berechnungen unten)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sens,spec] = calc_ROC_parameters(tick_mat,classifier)

if size(tick_mat,1)< size(tick_mat,2)
    tick_mat = tick_mat'; 
end 

if size(tick_mat,1) ~= length(classifier)
    error('true labels (tick_mat) and classifier need to have the same length!')
end

%% Sensitivity and Specificity 

cat1_idx = find(tick_mat(:,1)); 
cat2_idx = find(tick_mat(:,2)); 

cat1_classified = classifier(cat1_idx); % describes the categories that were classified for datapoints with "truth" cat1 
cat2_classified = classifier(cat2_idx); 

a_b = hist(cat1_classified,[1,2]); % definition of a,b,c,d as in Hedderich Tabelle 4.6 (Vierfeldertafel)
c_d = hist(cat2_classified,[1,2]); 

a = a_b(1); b = a_b(2); c = c_d(1); d = c_d(2); 
n = a+b+c+d; 

sens = a/(a+b); 
spec = d/(c+d);  


%% additional possible quantities: 
% aufpassen mit Bedeutung von Sensitivität und Spezifität: hier quasi
% symmetrisch, hohe sens bedeutet dass cat1 (z.B. NH) mit hoher WK richtig
% erkannt wird, hohe spec analog mit cat2 

% "Prävalenz": hier: relative Häufigkeiten cat1 und cat2 
prev_cat1 = (a+b)/(a+b+c+d); 
prev_cat2 = (c+d)/(a+b+c+d); 

% Youden-Index: Maß für Güte eines diagnostischen Tests (nahe 1 gut,
% Wertebereich [-1 1])
youden = sens + spec -1;

% Negativer Voraussagewert p(cat2 true|cat2 classified) - predictive value
% of negative test result
pred_neg = d/(b+d);

% Positiver Voraussagewert p(cat1 true|cat1 classified) - predictive value
% of positive test results (Achtung, auch hier symmetrisch mit pred_neg:
% das eine bezieht sich auf cat1, das andere auf cat2)
pred_pos = a/(a+c);

% result validity (max 2)
p_pos_result = pred_neg + pred_pos;




    








end