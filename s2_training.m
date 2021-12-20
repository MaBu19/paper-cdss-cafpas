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
% s2_training.m
% This script calculates training distributions based on expert and
% predicted CAFPAs, with patients sorted according to expert labels of Buhl
% et al. (2020).
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

addpath(genpath('./functions/'));

fig_folder = './plots/';
data_folder = './data/';
res_folder = './results/';

if ~exist([res_folder filesep 's2_training'], 'dir')
    mkdir([res_folder filesep 's2_training']);
end

% check if running Matlab or Octave:
isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0; % 0 in Matlab, 1 in Octave

sflag = 1; % save (plots)
sflag_txt = 1; % save txt file (distribution parameters)
add_str = '';

logL_flag = 'cat'; % 'cat' - used in Buhl et al. (2020) | 'datapoints'
cross_validation = 1; % 1: k-fold, 0: none

% new parameters (predicted CAFPAs):
num_folds = 5;

pfig = 's2_training'; % for new plots and correct folder names
pfig2 = 'p2-fig8'; % for paper_parameters (same plots as in paper2); p2-fig8, p2-fig9, p4-fig7

if ~exist([fig_folder '/' pfig], 'dir')
    mkdir([fig_folder '/' pfig]);
end

%% load and organize data
% load expert cafpas
d = load([data_folder 'expert_data_cafpas_id.mat']); patients = d.patients;

% estimate worse ear - for audiogram, acalos and expert labels (reha/findings)
load([res_folder filesep 's1_preprocessing' filesep 'ear_idx.mat']); % ear_idx needed for sorting of expert labels (reha/findings) in organize_input

% organize data (data-set specific)
input_names = {'cafpas';'cafpas';'cafpas';'cafpas'}; % for properties, later input_data for models is replaced
dist_type = {'beta','beta','beta','beta'};

% correct one patient id (already correct in txt file from 19.11.21)
idx_cor = find([patients.patient_id]==55977);
patients(idx_cor).patient_id = 55597;

[input_data, num_params, x_vec, x_vec_h] = organize_input(patients,input_names,ear_idx); % input_names needs to be cell

% load test data (predicted cafpas)
model_names = {'lasso','elasticNet','randomForest'};
model_names_add = [{'expert'}, model_names];

cafpa_data = {};
cafpa_data{1} = input_data{1};
patID_expert = create_matrix_field(patients,'patient_id');

%% load predicted cafpas saved in 240x10 matrix for each model, along with associated vector of patient ids (sorting
% according to test indices does not take place here, but in s1_preprocessing)
ca_pred = load([res_folder filesep 's1_preprocessing' filesep 'preprocessing_cafpas_pred_labeled_' strrep(strjoin(model_names),' ','-') '.mat']);
cafpas_pred = ca_pred.cafpas_pred;
patID_pred = ca_pred.patID_models;

%% sort patients for expert and predicted CAFPAs (same order)
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
        exp_data_more{kn} = [tmp, patID_expert(tmp), input_data{1}(tmp,:)]; % use later if needed
        kn = kn+1;
    else
        sort_idx(k) = tmp;
        
    end
    
end
%  [patID_pred,patID_expert(sort_idx)]

input_data = [input_data{1}(sort_idx,:), cafpas_pred];
patients = patients(sort_idx); % also filter to obtain corresponding data to predicted CAFPAs

for m = 1:length(input_data)
    z_idx = find(input_data{m}<=0);
    input_data{m}(z_idx) = 0.001; % beta distribution only defined in (0,1)
end

%% data set-specific parameters
comparison = {'nh-hi','high-high+cond','high-high+recr','none-device','HA-CI','none-CI'};

%% paper-figure-specific parameters (comparison sets)
[wp_idx,wm_idx,m_ex,pp] = paper_parameters(pfig2);

%% add paper-independent plot properties'training' filesep
pp.visible = 'off';

%% loop over comparison sets
for comps = 1:5
    % load parameters for respective comparison set
    [filter_crit,cats,single_flag,plot_header,~] = definition_comparisons(comparison{comps});
    % load expert ticks for findings/reha
    [cases_mat,idx_single] = organize_cases(patients,filter_crit,ear_idx,cats,single_flag);
    
    
    %% number of cases per category - for likelihood calculation
    if strcmp(logL_flag,'cat')
        % average over categories
        num_c = sum(cases_mat); % number of datapoints per category as in database/used for fitting
        num_n = length(cats); % divide logL by number of categories to make logL factor comparable over versions of calculation
    elseif strcmp(logL_flag,'datapoints')
        % average over datapoints
        num_c = ones(size(cats)); % if each datapoint should contribute equally (V2 in notes 11.06.19)
        num_n = sum(sum(cases_mat)); % divide logL by total number of datapoints
    end
    
    %% for plotting/saving - strings
    title_cats = strrep(strjoin(plot_header),' ','-');
    
    dist_type_str = strrep(strjoin(unique(dist_type)),' ','-');
    
    input_names_str = '';
    for m = 1:length(input_names)
        input_names_str = [input_names_str input_names{m} '-'];
    end
    
    %% determine distribution parameters
    disp('--- determine distribution parameters ---');
    
    [mu, sig, weight, logL, num_data] = train_dist_params(input_data,cases_mat,idx_single,num_params,x_vec,input_names,dist_type,cross_validation);
    
    % calculate log-likelihood per category and sum of log-likelihood per dist
    [log_sum,log_cat] = loglike_mean(logL,num_data,logL_flag);
    
    if sflag_txt
        save([res_folder filesep 's2_training' filesep filter_crit '_' title_cats '_' dist_type_str '_' strrep(input_names_str,'_','-') '.mat'],'mu','sig','weight','log_cat','log_sum','num_data'); % date
        write_table_txt_paper2_02([res_folder 's2_training' filesep],input_names,num_params,filter_crit,single_flag,plot_header,dist_type,cross_validation,logL_flag,mu,sig,weight,log_cat,log_sum,num_data);
    end
    
    %% calculate normpdfs - loop over all parameters
    if cross_validation
        num_k = size(cases_mat,1);
    else
        num_k = 1;
    end
    
    disp('--- calculate normpdfs ---');
    
    for m = 1:length(input_names)
        n_pdf{m} = nan(num_k,num_params(m),length(cats),length(x_vec{m}));
        stepsize_x = x_vec{m}(2)-x_vec{m}(1);
        for k = 1:num_k
            for c = 1:length(cats)
                for num_p = 1:num_params(m)
                    n_pdf{m}(k,num_p,c,:) = calc_npdf(x_vec{m},mu{m}(k,num_p,c,:),sig{m}(k,num_p,c,:),weight{m}(k,num_p,c,:),stepsize_x,dist_type{m});
                    % figure; plot(x_vec{m},squeeze(n_pdf{m}(k,num_p,c,:)))
                    
                end
            end
        end
    end
    
    %% calculate histograms
    disp('--- calculate histogram ---');
    for m = 1:length(input_names)
        % use all data or only single ticks (single_flag = 1 or single_flag = 2)
        if ~isempty(idx_single)
            data = input_data{m}(idx_single,:);
        else
            data = input_data{m};
        end
        
        for c = 1:length(cats)
            % determine histograms for all categories c and parameters num_p
            for num_p = 1:num_params(m)
                data_tmp = data(find(cases_mat(:,c)),num_p);
                histc(num_p,c,:) = hist(data_tmp(~isnan(data_tmp)),x_vec_h{m});
            end
        end
        
        histo{m} = histc;
        clear histc;
        
    end
    
    %% organize data and plot
    
    disp('--- organize data and plot ---');
    
    % parameters for which plot should be done
    for m = 1:length(input_names)
        disp(['*** ' input_names{m} ' ***']);
        
        k = 1; % only change if all k cross-validation distributions shall be plotted
        for num_p = 1:num_params(m)
            for c = 1:length(cats)
                if cross_validation
                    if size(n_pdf{m},1) ~= 1
                        tmp = mean(squeeze(n_pdf{m}(:,num_p,c,:)));
                    else
                        warning('Check dimensions!'); %
                    end
                else
                    tmp = squeeze(n_pdf{m}(k,num_p,c,:));
                end
                n_pdf_d{c}(1,:) = tmp;
            end
            
            if strcmp(pfig2,'p2-fig8')
                % plot properties (non-default)
                pp.reflines = plot_property(input_names{m},'reflines');
                pp.reflabels = plot_property(input_names{m},'reflabels');
                
                if isOctave == 1
                    pp.isOctave = 1;
                else
                    pp.isOctave = 0;
                end
                
                [figh(m,num_p,:),axh,ph] = plot_training_distributions(x_vec{m}, n_pdf_d(find(num_c)), x_vec_h{m}, histo{m}(num_p,find(num_c),:), input_names{m},pp );  % figh(m,num_p,k,:)
                
                % add legend here if desired
                
                for c = 1:size(figh,3)
                    if size(figh,3) > 1
                        title_cats2 = plot_header{c};
                    else
                        title_cats2 = title_cats;
                    end
                    
                    % add title here if desired
                    
                    if sflag
                        print(figh(m,num_p,c),[fig_folder filesep pfig filesep 'train_dist_' title_cats2 '-' dist_type{m} '-' strrep(input_names{m},'_','-') '-p' num2str(num_p) add_str '-' model_names_add{m} '.eps'],'-painters','-depsc','-r600');
                        print(figh(m,num_p,c),[fig_folder filesep pfig filesep 'train_dist_' title_cats2 '-' dist_type{m} '-' strrep(input_names{m},'_','-') '-p' num2str(num_p) add_str '-' model_names_add{m} '.png'],'-dpng','-r600');
                        
                    end
                end
            end
            clear n_pdf_d; % size changes with m
            
        end % num_p
    end % m
    close all;  
end % comps
