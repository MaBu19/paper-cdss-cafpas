% function mat = create_matrix_field(structn,fieldn) sorts data from a given field
% in a struct to a matrix
%
% v1, MB 01.06.18 
% 
% INPUT: 
% structn   struct that contains the data
% fieldn    fieldname of struct (str)
%
% OUTPUT: 
% mat       matrix containing the collected data
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mat,idx] = create_matrix_field(structn,fieldn,varargin)
mat = [];
idx = zeros(length(structn),1); 

% needed if experts indicated different findings/reha for the two ears -> only consider worse ear 
if ~isempty(varargin)
    ear_idx = varargin{1};
    find_reha = {'findings','reha'}; 
end

% arrange data in matrix
for k = 1:length(structn)
    if isfield(structn(k),fieldn)
    if ~isempty(structn(k).(fieldn)) 
        mat = [mat;structn(k).(fieldn)];
        idx(k) = 1; 
    else
        mat =  [mat; NaN*ones(1,size(mat,2))]; 
    end
    
    end
end


% added 12.12.18: corrections of findings/reha for different ticks for left
% and right ear 
if ~isempty(varargin)
if strcmp(fieldn,'reha') || strcmp(fieldn,'findings')
    for k = 1:length(structn)
        if structn(k).find_reha_le_ri > 0 % add isfield() in previous line if necessary
            str = num2str(structn(k).find_reha_le_ri); % divide string
            num_entries = length(str)/3;
            for n = 1:num_entries
                strn = str(3*(n-1)+1:3*n); % only temp variable
                if ear_idx(k) == str2num(strn(3)) % info from str is maintained if corresponding to worse ear 
                elseif ear_idx(k) ~= str2num(strn(3)) && strcmp(find_reha{str2num(strn(1))},fieldn) % if not: delete respective expert tick -> 0 in mat  
                    mat(k,str2num(strn(2))) = 0; 
                end
            end
        end
    end
end
end
% Codierung: 1. Stelle: 1 findings/2 reha; 2. Stelle: findings/reha-idx laut Matrix; 3. Stelle: 1 left/2 right (siehe auch
% slides/analysis_07_audiogram.pptx) - beschreibt, welche
% reha/findings-ticks ggf. mit li/re getrennt angegeben wurden - kommt in
% 11 Fällen vor 

end