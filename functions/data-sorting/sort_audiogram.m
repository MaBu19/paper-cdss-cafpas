% extract audiogram data (left and right) from patient struct and sort according to worse PTA
%
% 
% v1, MB 13.05.19 
% 
% INPUT:
% data_struct     struct containing patient data 
% str_left        fieldname of struct - left audiogram data
% str_right       fieldname of struct - right audiogram data 
% 
% OUTPUT: 
% AG_worse        matrix containing all audiograms of ear with higher PTA 
% ear_idx         index: which ear has higher PTA (1: left or equal, 2: right)

function [AG_worse, ear_idx] = sort_audiogram(data_struct,str_left,str_right)
    [AG_le,AG_le_idx] = create_matrix_field(data_struct,str_left);
    [AG_ri,AG_ri_idx] = create_matrix_field(data_struct,str_right);
    [AG_worse,AG_b,ear_idx] = sort_data_left_right(AG_le,AG_ri);
end
