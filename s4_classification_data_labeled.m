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
% s4_classification_data_labeled.m
% This script performs classification in comparison sets based on expert
% and predicted CAFPAs, using expert training distributions.
%
% Mareike Buhl
% mareike.buhl@uol.de
%
% v1.1, 14.12.2021
% v1.0, 30.08.2020
%
% Matlab R2020b
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
clc;

addpath(genpath('./functions/'));

fig_folder = './plots/';
data_folder = './data/';
res_folder = './results/';

% change between first (0) and second (1) run:
add_w_flag = 0; % if additional weights should be used or not 
wadd_str = ['_wadd-' num2str(add_w_flag)];
debug_flag = '';

Y_th = 0.9; % relative threshold Y90 combinations

% choose training distributions
train_choice = 'experts';
if strcmp(train_choice,'matched')
    % classification is performed using the training distributions
    % generated using the respective expert/model datapoints
    add_str = '';
elseif strcmp(train_choice,'experts')
    % use expert training distributions for all classifications (expert and
    % model datapoints)
    add_str = '_train-experts';
end

% use pfig as dummy variable for parameter choice (paper_parameters):
pfig = 'p4-fig12';

%% load and organize test data
% load test data (expert cafpas)
d = load([data_folder 'expert_data_cafpas_id.mat']); test_patients = d.patients; % contains same comparison sets as training data (in comps loop)

% estimate worse ear - for audiogram, acalos and expert labels (reha/findings)
load([res_folder filesep 's1_preprocessing' filesep 'ear_idx.mat']); 

% organize test data (data-set specific)
input_names_test = {'cafpas';'cafpas';'cafpas';'cafpas'}; % property of data set

% correct one patient id (already correct in txt file from 19.11.21)
idx_cor = find([test_patients.patient_id]==55977);
test_patients(idx_cor).patient_id = 55597;

[meas_data, num_params, x_vec, x_vec_h] = organize_input(test_patients,input_names_test,ear_idx); % input_data 2-4 are dummy data that are replaced later

% load test data (predicted cafpas)
model_names = {'lasso','elasticNet','randomForest'};
model_names_add = [{'expert'}, model_names];
m_colors = [13 11 10 9]; % fit to Paper Saak et al. (2020)

patID_expert = create_matrix_field(test_patients,'patient_id');

% load predicted cafpas saved in 240x10 matrix for each
% model, along with associated vector of patient ids (sorting
% according to test indices does not take place here, but in 4_preprocessing)
ca_pred = load([res_folder 's1_preprocessing' filesep 'preprocessing_cafpas_pred_labeled_' strrep(strjoin(model_names),' ','-') '.mat']);
cafpas_pred = ca_pred.cafpas_pred;
patID_pred = ca_pred.patID_models;

[uID] = unique(patID_expert,'stable');
[C,ia,ib] = intersect(patID_pred,uID,'stable');
patID_exp = uID(ib); % cafpa data (expert) needs to be sorted in this order

kn = 1;
for k = 1:length(ia)
    tmp = find(patID_expert == patID_pred(k));
    if length(tmp) > 1
        % draw one of them
        rng(0);
        sort_idx(k) = tmp(randi(length(tmp)));
        
        % put all in new variable
        exp_data_more{kn} = [tmp, patID_expert(tmp), meas_data{1}(tmp,:)]; % use later if needed
        kn = kn+1;
    else
        sort_idx(k) = tmp;
    end
end
%  [patID_pred,patID_expert(sort_idx)]

input_data = [meas_data{1}(sort_idx,:), cafpas_pred];
% test_patients = test_patients(sort_idx); % --> done below

for m = 1:length(input_data)
    z_idx = find(input_data{m}<=0);
    input_data{m}(z_idx) = 0.001; % beta distribution only defined in (0,1)
end

%% data set-specific parameters
comparison = {'nh-hi','high-high+cond','high-high+recr','none-device','HA-CI','none-CI'}; % possibility: add 'legend' as comparison set - to be able to create legend easily

%% paper-figure-specific parameters (comparison sets)
[wp_idx,wm_idx,m_ex,pp] = paper_parameters(pfig);

wp = [];
wm = [];

% estimate weights
if ~isempty(wp_idx)
    wp = choose_weights_params(wp_idx,num_params);
    if ~isempty(wm_idx)
        ex_idx = strcmp(input_names_test,m_ex);
        wm = choose_weights_params(wm_idx,length(input_names_test),ex_idx);
    end
end

%% load weights for relative frequency of Youden index crit (Y90)
if add_w_flag
    % these files only exist after running scripts s4 and s5 with
    % add_w_flag = 0 first
    load([res_folder filesep 's5_eval-rel-freq' filesep 'weights_rel-freq_Y' num2str(Y_th*100) '_wadd-' num2str(0) debug_flag '.mat']); % weights, num_w (weights for experts or models)
    load([res_folder filesep 's5_eval-rel-freq' filesep 'exp-model-weights_rel-freq_Y' num2str(Y_th*100) '_wadd-' num2str(0) debug_flag '.mat']); % weights_com, num_w_com (common weights experts and models)
    load([res_folder filesep 's5_eval-rel-freq' filesep 'common_weights_rel-freq_Y' num2str(Y_th*100) '_wadd-' num2str(0) debug_flag '.mat']); % weights_com_all, num_w_com_all, idx_com_all  (common weights between experts and all models)
end

%% add paper-independent plot properties
pp.visible = 'on';
pp.colors = {rgb('Blue'),rgb('DarkMagenta'),rgb('Indigo'),rgb('FireBrick'),rgb('Chocolate'),rgb('DarkOrange'),rgb('Gold'),rgb('LimeGreen'),rgb('DarkGreen'),rgb('MidnightBlue'),rgb('DeepSkyBlue'),rgb('RoyalBlue'),rgb('YellowGreen'),rgb('DeepPink'),'none',rgb('Gray'),rgb('Red'),rgb('Black')}; % ggf. wiederholen/mit weiteren Farben ergänzen
pp.symbols = {'o','s','v','<','*','>','+','d','^','p','h','x','o','s'};

%% classification loop over comparison sets (here, no changes should be required if a new data set was used)
for comps = 1:5
    % load training data
    [filter_crit,cats,single_flag,~,~] = definition_comparisons(comparison{comps});
    
    % training data may be distributed over several files
    files = dir([res_folder 's2_training/*' comparison{comps} '*cv1.txt']); % -12-Nov-2020
    [input_names_training,mu,sig,dist_type] = read_table_txt_paper2_02([res_folder 's2_training/'],files,length(cats));
    
    [cases_mat,idx_single] = organize_cases(test_patients(sort_idx),filter_crit,ear_idx(sort_idx),cats,single_flag);
    
    %% classification
    for m = 1:length(input_names_test)
        data{m} = input_data{m};
        
        % evaluate training distributions at x-positions given by test datapoints
        if strcmp(train_choice,'matched')
            [p_eval{m},cert{m}] = eval_train_dist(x_vec{m},data{m},mu{m},sig{m},dist_type{m});
        elseif strcmp(train_choice,'experts')
            [p_eval{m},cert{m}] = eval_train_dist(x_vec{m},data{m},mu{1},sig{1},dist_type{1}); % includes certainty calculation (property: sum(c) = 1)
        end
        
        % estimate classified category (all datapoints of respective comparison set and all parameters)
        classifier{m} = classify_data(p_eval{m});
        
        % add additional weights (if required)
        if add_w_flag 
            if m == 1
                wp{m}(1024,:) = weights{m}(comps,:)/sum(weights{m}(comps,:));
            elseif m > 1
                wp{m}(1024,:) = weights_com{m-1}(comps,:)/sum(weights_com{m-1}(comps,:)); % length = 3 (only models)
            end
            wp{m}(1025,:) = weights_com_all{m}(comps,:)/sum(weights_com_all{m}(comps,:));
        end
        
        % combine parameters according to definition for paper-figure
        % above
        if ~isempty(wp_idx)
            p_psum{m} = combine_parameters(log(p_eval{m}),wp{m});
            classifier_p{m} = classify_data(p_psum{m}); % includes all measures with only one parameter/measurement (not explicitly needed, but consistent cells available)
            
            % combine certainty (corresponding to weights of parameters)
            cert_psum{m} = combine_parameters(cert{m},wp{m});
        end
    end
    data_comps{comps} = data;
    clear data;
    
    %% evaluate classification performance - sensitivity and specificity
    for m = 1:length(input_names_test)
        % for single parameters (CAFPAs)
        for num_p = 1:size(classifier{m},2) % number of parameters
            [sens{m}{num_p},spec{m}{num_p}] = calc_ROC_parameters(cases_mat,classifier{m}(idx_single,num_p));
        end
        
        if num_params(m) > 1
            % for combined parameters
            for num_p = 1:size(classifier_p{m},2) % number of weight vectors (combinations)
                [sens_p{m}(num_p,1),spec_p{m}(num_p,1)] = calc_ROC_parameters(cases_mat,classifier_p{m}(idx_single,num_p));
            end
        end
    end
    
    
    cases_mat_comps{comps} = cases_mat;
    clear cases_mat;
    idx_single_comps{comps} = idx_single; % (can be used to only show/filter idx_single)
    clear idx_single;
    
    classifier_comps{comps} = classifier;
    clear classifier;
    cert_comps{comps} = cert;
    clear cert;
    
    classifier_p_comps{comps} = classifier_p;
    clear classifier_p;
    cert_psum_comps{comps} = cert_psum;
    clear cert_psum;
    
    sens_comps{comps} = sens;
    spec_comps{comps} = spec;
    sens_p_comps{comps} = sens_p;
    spec_p_comps{comps} = spec_p;
    wp_comps{comps} = wp;
    
end % comps

if ~exist([res_folder filesep 's4_classification'], 'dir')
    mkdir([res_folder filesep 's4_classification']);
end

save([res_folder filesep 's4_classification' filesep 'classification_results_labeled_' num2str(Y_th*100) wadd_str debug_flag '.mat'],'cases_mat_comps','sort_idx','idx_single_comps','classifier_comps','cert_comps','classifier_p_comps','cert_psum_comps','sens_comps','spec_comps','sens_p_comps','spec_p_comps','wp_comps')

