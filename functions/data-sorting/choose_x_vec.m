% define x-vector for measurement given by input_name - used in
% e.g. organize_input
% 
% v1, MB 28.05.19
% 
% INPUT: 
% input_name        name of measurement (needs to be fieldname in patients
%                   struct)
% 
% OUTPUT: 
% x_vec             x-vector 
% x_vec_h           version of x_vec for histogram 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x_vec, x_vec_h] = choose_x_vec(input_name)
        meas = input_name; 
        switch meas 
            case {'ag_ac', 'ag_bc','ABG'}
                x_vec = -10:1:120;
%                 x_vec_h = -5:10:115; 
                x_vec_h = -15:5:125; 
            case 'cafpas'
                x_vec = 0:0.01:1; 
%                 x_vec_h = 0.05:0.1:0.95; 
                x_vec_h = 0.05:0.05:0.95; 
            case 'deg_hl'
                x_vec = 0:0.1:5; 
                x_vec_h = 0.5:1:4.5; 
            case {'acalos_1_5','acalos_4'} 
                x_vec = 0:1:120; 
                x_vec_h = -5:10:115; 
            case 'swi_sum'
                x_vec = 0:0.1:21; 
%                 x_vec_h = 1.5:3:19.5; 
                x_vec_h = 1:1:21; 
            case 'goesa'
                x_vec = -15:0.1:15; 
%                 x_vec_h = -13.5:3:13.5; 
                x_vec_h = -14.5:1:14.5; 
            case 'earnoise'
                x_vec = 0:1;
                x_vec_h = 0:1; 
            case {'hp_quiet','hp_noise'} 
                x_vec = 0:0.1:5.5; 
                x_vec_h = 0:1:5; 
            case 'wst_raw'
                % z_score: 
                  x_vec = -3:0.1:3; 
                  x_vec_h = -3:0.5:3; 
            case 'demtect'
                x_vec = 0:0.01:19; 
%                 x_vec_h = 1.5:3:17; 
                x_vec_h = 0:2:18; 
            case 'age'
                x_vec = 0:100; 
                x_vec_h = 5:10:95; 
        end
end
