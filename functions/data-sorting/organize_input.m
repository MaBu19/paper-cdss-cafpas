% saves input data from patient struct to cell of matrices - used in
% paper2 and paper3
%
% v2, MB 28.05.19
% 
% INPUT: 
% patients          struct containing patient data
% input_names       names of measurements (need to be field names of patients struct)
% ear_idx           index: which ear has higher PTA based on AG_AC (1: left
%                   or equal, 2: right), determined with sort_audiogram()
% OUTPUT: 
% input_data        cell containing the data for all patients sorted in
%                   matrices
% num_params        number of parameters for each measurement
% x_vec             cell containing the x-vectors for each measurement
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [input_data, num_params, x_vec, x_vec_h] = organize_input(patients,input_names,ear_idx)
% keyboard 
% check if input_names_test corresponds to any of the available training
% measures
num_match = 0;
for m = 1:length(input_names)
    if sum(strcmp(fields(patients),input_names{m})) > 0
        num_match = num_match + 1; 
    end
end
% --> funktioniert nicht, wenn ag --> _le/_ri noch hintendran, muss noch ergänzt werden 

% sort data 
if num_match == 0
    warning(['No test data is available for any of the measures given in input_names_test: ' strjoin(input_names,', ') '.'])
    return; 
else

    for m = 1:length(input_names)
        str_part = strsplit(input_names{m},';'); 
        input_names_m = str_part{1}; % to get only name of measurement, no (optional) choice of parameter subset 
        
        if strcmp(input_names_m,'ag_ac')
            data_le = create_matrix_field(patients,[input_names_m '_le']); 
            data_ri = create_matrix_field(patients,[input_names_m '_ri']); 
            input_data{m}(ear_idx==1,:) = data_le(ear_idx==1,:); 
            input_data{m}(ear_idx==2,:) = data_ri(ear_idx==2,:);  
            
        elseif strcmp(input_names_m,'ag_bc')
            data_le = create_matrix_field(patients,[input_names_m '_le']); 
            data_ri = create_matrix_field(patients,[input_names_m '_ri']); 
            input_data{m}(ear_idx==1,:) = data_le(ear_idx==1,:); 
            input_data{m}(ear_idx==2,:) = data_ri(ear_idx==2,:);  
            
        elseif strcmp(input_names_m,'ABG')
            data_le_ac = create_matrix_field(patients,['ag_ac_le']); 
            data_ri_ac = create_matrix_field(patients,['ag_ac_ri']); 
            data_le_bc = create_matrix_field(patients,['ag_bc_le']); 
            data_ri_bc = create_matrix_field(patients,['ag_bc_ri']); 
            ABG_le = data_le_ac - data_le_bc; 
            ABG_ri = data_ri_ac - data_ri_bc; 
            
            input_data{m}(ear_idx==1,:) = ABG_le(ear_idx==1,:); % added 06.08.19 for paper3_01_classification (check for consistency with other scripts)
            input_data{m}(ear_idx==2,:) = ABG_ri(ear_idx==2,:); 
            
            
        elseif strcmp(input_names_m,'acalos_1_5') || strcmp(input_names_m,'acalos_4')
            
            % use ear_idx to always use worse ear (according to AG-AC PTA)
           data_le = create_matrix_field(patients,[input_names_m '_le']); 
           data_ri = create_matrix_field(patients,[input_names_m '_ri']);
%            input_data{m}(ear_idx==1,1:3) = data_le(ear_idx==1,4:6);
%            input_data{m}(ear_idx==2,1:3) = data_ri(ear_idx==2,4:6);  
            % use parameters stored in databases (% LCUT, MLOW, MHIGH,
            % L2.5, L25, L50 )  - could be changed, use loudness curve
            % calculated from parameters? (check classification of loudness
            % curves - mail from Lisa Suck/Dirk Oetting)
           input_data{m}(ear_idx==1,:) = data_le(ear_idx==1,:); % all parameters -> needed e.g. in combined plots in paper2_02_distributions
           input_data{m}(ear_idx==2,:) = data_ri(ear_idx==2,:); 
        elseif strcmp(input_names_m,'goesa')
           data = create_matrix_field(patients,input_names_m); 
           input_data{m} = data(:,1); % SRT
        elseif strcmp(input_names_m,'earnoise') % include only the worse ear as given by ear_idx..:
           data = create_matrix_field(patients,input_names_m);  % [right,left]
           data = fliplr(data); % [left,right] - fit to ear_idx
           
           for k = 1:length(ear_idx)
               if ear_idx(k) == 0
                   ear_idx(k) = 1; % if no AG available
               end
               tmp(k,1) = data(k,ear_idx(k)); 
           end
           
           input_data{m} = tmp; 
           
        elseif strcmp(input_names_m,'wst_raw')
           data = create_matrix_field(patients,input_names_m); 
           z_scale = [-2.68 -2.42 -2.27 -2.15 -2.05 -1.96 -1.89 -1.81 -1.75 -1.68 -1.62 -1.56 -1.5 -1.44 -1.38 -1.32 -1.26 -1.19 -1.12 -1.06 -0.98 -0.91 -0.82 -0.74 -0.64 -0.54 -0.43 -0.32 -0.19 -0.05 0.1 0.26 0.45 0.67 0.9 1.18 1.43 1.68 1.94 2.22 2.61];
           
           tmp = nan(size(data)); 
           for k = 1:length(data) 
               if ~isnan(data(k))
               tmp(k,1) = z_scale(data(k)); 
               end
           end
           
           input_data{m} = tmp; % z_score calculated from WST raw score
        
        else 
            input_data{m} = create_matrix_field(patients,input_names_m);
            if strcmp(input_names_m,'cafpas')
                z_idx = find(input_data{m}<=0); 
                input_data{m}(z_idx) = 0.001; % beta distribution only defined in (0,1)
            end
        end
         
        % (could also be determined elsewhere)  
        num_params(m) = size(input_data{m},2); 
        [x_vec{m}, x_vec_h{m}] = choose_x_vec(input_names_m); % for calculation of pdf, plotting 

    end
end
end
