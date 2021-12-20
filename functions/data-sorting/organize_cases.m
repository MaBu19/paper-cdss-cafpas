% organize matrix with ticked findings/reha for given cats choice, one
% patient (survey sheet) per row
% 
% v1, MB 28.05.19
% ((v1.2, MB 24.10.21: added cases_mat_all))
% 
% INPUT: 
% patients          struct containing patient data
% filter_crit       'reha' or 'findings'
% ear_idx           index: which ear has higher PTA based on AG_AC (1: left
%                   or equal, 2: right), determined with sort_audiogram()
% cats              cell containing the indices (or group of indices) of
%                   to-be-compared reha/finding categories
% single_flag       1 if only single-ticked cases shall be considered, 0
%                   consider all ticks; 2 consider exact combinations of ticks  
% 
% OUTPUT: 
% cases_mat         matrix [k length(cats)] containing 1 for ticked cases 
% idx_single        indices which of the patients have only one ticked case (one of the respective categories)
% cases_mat_all     as cases_mat, but without filtering according to
%                   idx_single (nur ausprobiert, dann doch verworfen)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cases_mat,idx_single] = organize_cases(patients,filter_crit,ear_idx,cats,single_flag)
cases_mat_all = create_matrix_field(patients,filter_crit,ear_idx);
cases_mat = zeros(size(cases_mat_all,1),length(cats)); 

if single_flag == 2 % per category: all reha/findings shall be active (ticked by expert) 
    cats_tot = [];
    for n = 1:length(cats)
        cats_tot = [cats_tot cats{n}]; 
    end
    cats_tot = unique(cats_tot); 
    tmp = cases_mat_all(:,cats_tot); 
   
    for n = 1:length(cats)
        [cat_pattern,ia,~] = intersect(cats_tot,cats{n});
        cat_pattern = zeros(size(cats_tot)); 
        cat_pattern(ia) = 1; 
        
        idx_pattern = sum(tmp == repmat(cat_pattern, size(cases_mat_all,1),1),2) == length(cat_pattern); 
        
        cases_mat(idx_pattern>0,n) = 1; 
        
    end

    % extract all rows containing exactly one 1
    idx_single = sum(cases_mat,2);
    idx_single = find(idx_single == 1);
%     cases_mat_all = cases_mat; 
    cases_mat = cases_mat(idx_single,:); 

elseif single_flag == 0 || single_flag == 1 
    idx_single = []; 
    for n = 1:length(cats)
        tmp = cases_mat_all(:,cats{n});
        tmp2 = sum(tmp,2); 
        cases_mat(tmp2>0,n) = 1;
    end
    
    % check single ticks: "single tick after combining categories to comparison set" --> for example "hearing aid" (HA): keep patient cases with ticks for "open" and "closed", but not those with "none" and "open"
    if single_flag == 1 
        idx_single = sum(cases_mat,2);
        idx_single = find(idx_single == 1);
%         cases_mat_all = cases_mat; 
        cases_mat = cases_mat(idx_single,:); 
    end
    
    
end
end


