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
% s6_classification_tree.m
% This script performs classification in tree sets.
%
% Mareike Buhl
% mareike.buhl@uol.de
%
% v1.1, 14.12.2021
% v1.0, 14.09.2021
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

sflag = 1;
add_w_flag = 1; % if additional weights should be used or not --> fixed to 1 in this script
wadd_str = ['_wadd-' num2str(add_w_flag)]; 
add_str = ''; 
debug_flag = '';

comparison = {'nh-hi','high-high+cond','high-high+recr','none-device','HA-CI'};

%% load classification results (based on CAFPAs)
Y_th = 0.9;
load([res_folder 's4_classification' filesep 'classification_results_labeled_' num2str(Y_th*100) add_str wadd_str debug_flag '.mat']); % saved in s4_classification_data_labeled.m

%% load and organize test data (labeled)
% load test data (expert cafpas)
d = load([data_folder 'expert_data_cafpas_id.mat']); test_patients = d.patients;% contains same comparison sets as training data (in comps loop)
% estimate worse ear - for audiogram, acalos and expert labels (reha/findings)
load([res_folder filesep 's1_preprocessing' filesep 'ear_idx.mat']); 

% organize test data (data-set specific)
input_names = {'cafpas'};

% correct one patient id
idx_cor = find([test_patients.patient_id]==55977);
test_patients(idx_cor).patient_id = 55597;

[tmp_data, num_params, x_vec, x_vec_h] = organize_input(test_patients,input_names,ear_idx); % input_data 2-4 are dummy data that are replaced later
cafpa_names_lc = {'C_{A1}','C_{A2}','C_{A3}','C_{A4}','C_{U1}','C_{U2}','C_{B}','C_{N}','C_{C}','C_{E}'};

% load test data (predicted cafpas)
model_names = {'lasso','elasticNet','randomForest'};
model_names_add = [{'expert'}, model_names];
model_names_paper = {'Expert','Lasso Regression','Elastic Net','Random Forest'};
m_colors = [13 11 10 9]; % fit to Paper Saak et al. (2020)
patID_expert = create_matrix_field(test_patients(sort_idx),'patient_id');

% load predicted cafpas saved in 240x10 matrix for each
% model, along with associated vector of patient ids (sorting
% according to test indices does not take place here, but in s1_preprocessing)
ca_pred = load([res_folder 's1_preprocessing' filesep 'preprocessing_cafpas_pred_labeled_' strrep(strjoin(model_names),' ','-') '.mat']);
cafpas_pred = ca_pred.cafpas_pred;
patID_pred = ca_pred.patID_models; % the same as patID_expert

input_data = [tmp_data{1}(sort_idx,:), cafpas_pred]; % (sort_idx loaded from s4 results)

for m = 1:length(input_data)
    z_idx = find(input_data{m}<=0);
    input_data{m}(z_idx) = 0.001; % beta distribution only defined in (0,1)
end
% input_data 2-4: predicted CAFPAs
% save input data save([res_folder filesep 
if ~exist([res_folder filesep 's6_eval_cafpas_labeled'], 'dir')
    mkdir([res_folder filesep 's6_eval_cafpas_labeled']);
end
 
save([res_folder filesep 's6_eval_cafpas_labeled' filesep 'cafpas_' strrep(strjoin(model_names_add),' ','-') '.mat'],'input_data'); % use in s7 

%% add paper-independent plot properties
pp.visible = 'off';
pp.colors = {rgb('Blue'),rgb('DarkMagenta'),rgb('Indigo'),rgb('FireBrick'),rgb('Chocolate'),rgb('DarkOrange'),rgb('Gold'),rgb('LimeGreen'),rgb('DarkGreen'),rgb('MidnightBlue'),rgb('DeepSkyBlue'),rgb('RoyalBlue'),rgb('YellowGreen'),rgb('DeepPink'),'none',rgb('Gray'),rgb('Red'),rgb('Black'),rgb('DodgerBlue'),rgb('ForestGreen'),rgb('LightGray')}; % ggf. wiederholen/mit weiteren Farben ergänzen
pp.symbols = {'o','s','v','<','*','>','+','d','^','p','h','x','o','s'};

%% load classification thresholds
for comps = 1:length(comparison)
    ca_tmp = load([res_folder filesep 's3_classification_thresholds' filesep 'ca_threshold_' comparison{comps} '.mat']);
    ca_th(comps,:) = ca_tmp.ca_th;
end

%% sort indices according to binary category tree (exclude indices that have been assigned to other category in previous step)
% --> i_model, because tree-like
% classification for one patient works for one model from top to bottom
% difference to unlabeled cases: here, the number of cases in
% classifier_comps changes with comp-set

% extend classifier (and cases_mat) to 240 cases using idx_single
for comps = 1:5
    cases_mat_ext{comps}(idx_single_comps{comps},:) = cases_mat_comps{comps};
end

% transform cases_mat_ext to true_cat --> index of category as in
% classifier (zero means that patient has no expert label in "single" sense (not included in idx_single))
true_cat = zeros(size(cases_mat_ext{1},1),5);
cert_true_cat = zeros(size(cases_mat_ext{1},1),5,2);
for comps = 1:5
    true_cat(cases_mat_ext{comps}(:,1)==1,comps) = 1;
    true_cat(cases_mat_ext{comps}(:,2)==1,comps) = 2;
    cert_true_cat(:,comps,:) = cases_mat_ext{comps}; % needed in classification_tree, true label is always 100 % certain
end
% transform to true_cat_idx{comps} (set columns to 0 if previous comp set
% classified the other category)
true_cat_idx(:,1) = true_cat(:,1);
true_cat_idx(true_cat(:,1)==2,2) = true_cat(true_cat(:,1)==2,2);
true_cat_idx(true_cat(:,1)==2,3) = true_cat(true_cat(:,1)==2,3);
true_cat_idx(:,4) = true_cat(:,4);
true_cat_idx(true_cat(:,4)==2,5) = true_cat(true_cat(:,4)==2,5);
% --> can be used like cl_comps_idx in classification_tree

% estimate cl_comps_idx --> as classifier, but rows set to zero where
% patient was classified into other category in previous comparison set
% single cafpas
for i_model = 1:length(model_names_add)
    % findings
    % (1) NH-HI, (2) high-high+cond, (3) high-high+rec
    cl_comps_idx{1}{i_model}= classifier_comps{1}{i_model};
    for ca = 1:10
        cl_comps_idx{2}{i_model}(classifier_comps{1}{i_model}(:,ca)== 2,ca) = classifier_comps{2}{i_model}(classifier_comps{1}{i_model}(:,ca)== 2,ca);
        cl_comps_idx{3}{i_model}(classifier_comps{1}{i_model}(:,ca)== 2,ca) = classifier_comps{3}{i_model}(classifier_comps{1}{i_model}(:,ca)== 2,ca);
        
    end
    
    % treatment recommendations
    % (4) none-device, (5) HA-CI
    cl_comps_idx{4}{i_model}= classifier_comps{4}{i_model};
    for ca = 1:10
        cl_comps_idx{5}{i_model}(classifier_comps{4}{i_model}(:,ca)== 2,ca) = classifier_comps{5}{i_model}(classifier_comps{4}{i_model}(:,ca)== 2,ca);
    end
end

% combined parameters
for i_model = 1:length(model_names_add)
    % findings
    % (1) NH-HI, (2) high-high+cond, (3) high-high+rec
    cl_p_comps_idx{1}{i_model}= classifier_p_comps{1}{i_model};
    for w = 1:size(classifier_p_comps{1}{i_model},2)
        cl_p_comps_idx{2}{i_model}(classifier_p_comps{1}{i_model}(:,w)== 2,w) = classifier_p_comps{2}{i_model}(classifier_p_comps{1}{i_model}(:,w)== 2,w);
        cl_p_comps_idx{3}{i_model}(classifier_p_comps{1}{i_model}(:,w)== 2,w) = classifier_p_comps{3}{i_model}(classifier_p_comps{1}{i_model}(:,w)== 2,w);
        
    end
    
    % treatment recommendations
    % (4) none-device, (5) HA-CI
    cl_p_comps_idx{4}{i_model}= classifier_p_comps{4}{i_model};
    for w = 1:size(classifier_p_comps{1}{i_model},2)
        cl_p_comps_idx{5}{i_model}(classifier_p_comps{4}{i_model}(:,w)== 2,w) = classifier_p_comps{5}{i_model}(classifier_p_comps{4}{i_model}(:,w)== 2,w);
    end
end

%% perform tree classification
diagcase_flags = {'findings1','findings2','treat'};
dc_legend{1} = {'NH','high','high+cond'};
dc_legend{2} = {'NH','high','high+recr'};
dc_legend{3} = {'none','HA','CI'};

for i_model = 1:4
    for w = 1:size(classifier_p_comps{1}{i_model},2)
        % combine cl_p_comps_idx over comparison sets to matrix
        cat_comps_w(i_model,w,:,:) = [cl_p_comps_idx{1}{i_model}(:,w),cl_p_comps_idx{2}{i_model}(:,w),cl_p_comps_idx{3}{i_model}(:,w),cl_p_comps_idx{4}{i_model}(:,w),cl_p_comps_idx{5}{i_model}(:,w)];
        %       dim: i_model x w x k x comps
        cert_comps_w(i_model,w,:,:,:) = [cert_psum_comps{1}{i_model}(:,w,:),cert_psum_comps{2}{i_model}(:,w,:),cert_psum_comps{3}{i_model}(:,w,:),cert_psum_comps{4}{i_model}(:,w,:),cert_psum_comps{5}{i_model}(:,w,:)];
        %       dim: i_model x w x k x comps x 2cats x dc
        for dc = 1:length(diagcase_flags)
            [cat_comps_tree(i_model,w,:,dc),cert_comps_tree(i_model,w,:,:,dc)] = classification_tree(squeeze(cat_comps_w(i_model,w,:,:)),squeeze(cert_comps_w(i_model,w,:,:,:)),diagcase_flags{dc}); % für alle 3 machen
            %       dim: i_model x w x k (x 3cats) x dc
        end % (i_model,w,:)
    end
end

% estimate true category after tree (derived from cases_mat_comps)
for dc = 1:length(diagcase_flags)
    [true_cat_tree(:,dc),true_cert_tree(:,:,dc)] = classification_tree(true_cat_idx,cert_true_cat,diagcase_flags{dc});
end

% save results
save([res_folder filesep 's6_eval_cafpas_labeled' filesep 'tree_true_cats_vs_classified_' strrep(strjoin(model_names_add),' ','-') wadd_str debug_flag '.mat'],'cat_comps_tree','true_cat_tree','cert_comps_tree','true_cert_tree');
