% Copyright (C) 2020-2021 Mareike Buhl 
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
% 
% 
% s1_preprocessing.m
% This script sorts predicted CAFPAs from different cross-validation folds
% (prediction according to Saak et al. (2020)) to a matrix to be used in
% following scripts.
%
% Mareike Buhl
% mareike.buhl@uol.de
%
% v1.1, 14.12.2021
% v1.0, 03.11.2020
%
% Matlab R2020b
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
clc;

addpath(genpath('./functions'));

fig_folder = './plots/';
data_folder = './data/';
res_folder = './results/';

if ~exist(fig_folder, 'dir')
    mkdir(fig_folder);
end

logL_flag = 'cat'; % 'cat' - used in Buhl et al. (2020) | 'datapoints'
cross_validation = 1; % 1: k-fold, 0: none

% new parameter (predicted CAFPAs):
num_folds = 5;


%% load and organize data
d = load([data_folder 'expert_data_cafpas_id.mat']); patients = d.patients;

% organize data (data-set specific)
input_names = {'cafpas'}; % property of data set
dist_type = {'beta'}; % {'gmm-1','beta','cat'};
[input_data, num_params, x_vec, x_vec_h] = organize_input(patients,input_names,[]); % ear_idx not needed in case of 'cafpas'

model_names = {'lasso','elasticNet','randomForest'};

% correct one patient id
idx_cor = find([patients.patient_id]==55977);
patients(idx_cor).patient_id = 55597;

% first analysis: check if expert cafpas loaded directly and saved in R
% correspond
for m = 1:length(input_names)
    if strcmp(input_names{m},'cafpas')
        cafpas_expert = input_data{m};
        patID_expert = create_matrix_field(patients,'patient_id');
        
        data_modelbuilding = load([data_folder 'predicted/patient_ids_preprocessing/cafpas_patientID_labeled.mat']); % contains expert cafpas, patient id, expert id
        patID_models = data_modelbuilding.pat_ID_labeled;
        
        cafpas_expert_modelbuilding = data_modelbuilding.expCAFPAs;
        
        [C,ia,ic] = intersect(patID_expert, patID_models);
        %% check if expert cafpas loaded directly and saved in R (model building) correspond:
        % [patID_expert(ia),patID_models(ic)] % --> equal
        % [cafpas_expert(ia,10),cafpas_expert_modelbuilding.c_c_e(ic)] % --> equal for all cafpas
        
        for f = 1:num_folds
            ca_models = load([data_folder 'predicted/pred_CAFPAS_all_models_cv_fold_' num2str(f) '.mat']); % predicted cafpas have the same order as the patient id in patID_models loaded above
            
            cafpas_model{1}(:,:,f) = ca_models.CAFPA_lasso;
            cafpas_model{2}(:,:,f) = ca_models.CAFPA_enet;
            cafpas_model{3}(:,:,f) = ca_models.CAFPA_rf;
        end
         
        %% combine test indices from different folds
        for i_model = 1:3
            for ca = 1:10
                test_idx_combi = [];
                test_idx = {};
                fold_idx = nan(240,1);
                
                for f = 1:num_folds
                    
                    ind_models{i_model} = load([data_folder 'predicted/indices_mat_' model_names{i_model} '/pred_indices_cafpa_' num2str(ca) '_fold_' num2str(f) '.mat']);
                    test_idx_tmp = ind_models{i_model}.test_idx;
                    test_idx_combi = [test_idx_combi; ind_models{i_model}.test_idx];  % contains all those cafpas 5 times that were not available by experts (not available for training --> can be used as test datapoint)
                    
                    % put fold idx into one vector --> use for combining
                    % predicted cafpas from different folds
                    fold_idx(test_idx_tmp) = f;
                end
                
                % replace those indices in fold_idx that were used as test
                % datapoint several times by random idx 1:5:
                h_test = hist(test_idx_combi,1:1:240);
                multiple_idx = find(h_test ~= 1);
                for k = 1:length(multiple_idx)
                    fold_idx(multiple_idx(k)) = randi(num_folds);
                end
                
                % sort cafpas to matrix (using fold_idx)
                for np = 1:length(fold_idx)
                    cafpas_pred_tmp(np,ca) = cafpas_model{i_model}(np,ca,fold_idx(np));
                end
            end
            
            idx_all = 1:240;
            cafpas_pred{i_model} = cafpas_pred_tmp(idx_all,:);
            
        end % model loop
        
        if ~exist([res_folder filesep 's1_preprocessing'], 'dir')
            mkdir([res_folder filesep 's1_preprocessing']);
        end
        
        save([res_folder filesep 's1_preprocessing' filesep 'preprocessing_cafpas_pred_labeled_' strrep(strjoin(model_names),' ','-') '.mat'],'cafpas_pred','patID_models');
    end
end
