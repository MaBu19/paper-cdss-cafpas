% estimate classification for single patient, interpreting the binary tree of
% categories (Buhl et al., 2020; 2021) --> category and certainties 
% 
% Mareike Buhl
% mareike.buhl@uol.de
% v1, 10.09.21
% 
% 
% INPUT: 
% cats              matrix [k x 5] containing the classified categories for
%                   five comparison sets (0: comp set not assessed, 1:
%                   cat1, 2: cat2; for k patients
% cert              matrix [k x 5 x 2] containing certainties of
%                   classification in each comparison set, 3. dim: cat1 and
%                   cat2 
% diagcase_flag     flag defining which part of tree is evaluated: 
%                       'findings1': NH vs. high vs. high+cond
%                       'findings2': NH vs. high vs. high+recr
%                       'treat': none vs. HA vs. CI
% 
% OUTPUT: 
% cat_tree          index of classified categories (after passing the tree, 1/2/3/(0)) 
% cert_tree         vector of certainties for respective categories [3 x 1]
% 
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cat_tree,cert_tree] = classification_tree(cats,cert,diagcase_flag)
% keyboard
cat_tree = zeros(size(cats,1),1); 
% cert_tree = zeros(size(cats,1),3); 

switch diagcase_flag 
    case 'findings1'
        cats_dc = cats(:,[1 2]); 
        cert_dc = cert(:,[1 2],:); 
    case 'findings2'
        cats_dc = cats(:,[1 3]); 
        cert_dc = cert(:,[1 3],:); 
    case 'treat'
        cats_dc = cats(:,[4 5]); 
        cert_dc = cert(:,[4 5],:); 
end
% common for all three cases: first category is end of tree, second divides
% into two additional categories


for k = 1:size(cats,1)
    if cats_dc(k,1) == 1
        cat_tree(k) = 1; 
    elseif cats_dc(k,1) == 2
        if cats_dc(k,2) == 1
            cat_tree(k) = 2; 
        elseif cats_dc(k,2) == 2
            cat_tree(k) = 3; 
        end
    end
    
end
       
   cert_tree = [cert_dc(:,1,1),cert_dc(:,1,2).*cert_dc(:,2,1),cert_dc(:,1,2).*cert_dc(:,2,2)]; 
   
end
    

