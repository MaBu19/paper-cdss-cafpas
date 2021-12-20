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
% s7_plots_results_II_individual.m
% This script evaluates classification in tree sets and plots results.
%
% Mareike Buhl
% mareike.buhl@uol.de
%
% v1.1, 14.12.2021
% v1.0, 24.10.2021
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
add_w_flag = 1; % if additional weights are used or not - only use 1 in this script
wadd_str = ['_wadd-' num2str(add_w_flag)];
add_str = '';

pfig = 's7_results_II';
if ~exist([fig_folder filesep pfig], 'dir')
    mkdir([fig_folder filesep pfig]);
end

debug_flag = '';

% check if running Matlab or Octave:
isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0; % 0 in Matlab, 1 in Octave

%% parameters
comparison = {'nh-hi','high-high+cond','high-high+recr','none-device','HA-CI'};
model_names = {'lasso','elasticNet','randomForest'};
model_names_add = [{'expert'}, model_names];
model_names_paper = {'Expert','Lasso Regression','Elastic Net','Random Forest'};

m_colors = [13 11 10 9]; % fit to Paper Saak et al. (2020)

Y_th = 0.9;

diagcase_flags = {'findings1','findings2','treat'};
dc_legend{1} = {'NH','high','high+cond'};
dc_legend{2} = {'NH','high','high+recr'};
dc_legend{3} = {'None','HA','CI'};

cafpa_names_lc = {'C_{A1}','C_{A2}','C_{A3}','C_{A4}','C_{U1}','C_{U2}','C_{B}','C_{N}','C_{C}','C_{E}'};

%% add paper-independent plot properties
pp.visible = 'off';
pp.colors = {rgb('Blue'),rgb('DarkMagenta'),rgb('Indigo'),rgb('FireBrick'),rgb('Chocolate'),rgb('DarkOrange'),rgb('Gold'),rgb('LimeGreen'),rgb('DarkGreen'),rgb('MidnightBlue'),rgb('DeepSkyBlue'),rgb('RoyalBlue'),rgb('YellowGreen'),rgb('DeepPink'),'none',rgb('Gray'),rgb('Red'),rgb('Black'),rgb('DodgerBlue'),rgb('ForestGreen'),rgb('LightGray')}; % ggf. wiederholen/mit weiteren Farben ergänzen
pp.symbols = {'o','s','v','<','*','>','+','d','^','p','h','x','o','s'};


%% adapt classification from binary comparison sets to tree sets (2 cats -> 3 cats)
% load results from s6_classification_tree
load([res_folder filesep 's6_eval_cafpas_labeled' filesep 'tree_true_cats_vs_classified_' strrep(strjoin(model_names_add),' ','-') wadd_str debug_flag '.mat']);

% load CAFPAs
load([res_folder filesep 's6_eval_cafpas_labeled' filesep 'cafpas_' strrep(strjoin(model_names_add),' ','-') '.mat']);

%% load classification thresholds (comparison sets)
for comps = 1:length(comparison)
    ca_tmp = load([res_folder filesep 's3_classification_thresholds' filesep 'ca_threshold_' comparison{comps} '.mat']);
    ca_th(comps,:) = ca_tmp.ca_th;
end


%% 1) plot (median) CAFPA patterns for patients sorted to the three categories (3x: for findings1, findings2, treatment)

pp.calc_flag = 'median';

for dc = 1:3
    idx_label{dc} = find(true_cat_tree(:,dc)); % only use patients for which label is available - fair comparison
end

% plot CAFPAs for classified categories - by expert or predicted CAFPAs
for w_choice = [1023,1024,1025]
    if 1 % activate again
        for i_model = 1:4
            for cat_idx = 1:3 % 3 cats within diagcase group
                for dc = 1:3 % diagcase_flags
                    
                    %                     idx_label = find(true_cat_tree(:,dc)); % only use pset(gca,'XTick',1:1:10,'XTickLabel',cafpa_names_lc)atients for which label is available - fair comparison
                    
                    if isOctave == 1
                        pp.isOctave = 1;
                    else
                        pp.isOctave = 0;
                    end
                    
                    %                     length(input_data{i_model}(cat_comps_tree(i_model,w_choice,idx_label{dc},dc) == cat_idx,:)) % --> hier fehlen alle anderen Kombinationen von true-cats --> 0 bedeutet nicht "nicht klassifiziert", sondern andere Kategorie(nkombination)
                    %                     length(input_data{i_model}(cat_comps_tree(i_model,w_choice,:,dc) == cat_idx,:)) % --> hiermit können Plots aus paper4_eval_meas reproduziert werden; genutzt für Paper
                    [figh30(i_model,cat_idx,dc),axh,pmedian] = plot_cafpas_survey_2(input_data{i_model}(cat_comps_tree(i_model,w_choice,:,dc) == cat_idx,:),1,pp);
                    
                    if sflag
                        print(figh30(i_model,cat_idx,dc),[fig_folder filesep pfig filesep 'cafpas_train_dist_combined_tree_dc-' diagcase_flags{dc} '-' num2str(cat_idx) '_' model_names_add{i_model} '_Y' num2str(Y_th*100) '_w' num2str(w_choice) wadd_str debug_flag '.eps'],'-painters','-depsc','-r600');
                        print(figh30(i_model,cat_idx,dc),[fig_folder filesep pfig filesep 'cafpas_train_dist_combined_tree_dc-' diagcase_flags{dc} '-' num2str(cat_idx) '_' model_names_add{i_model} '_Y' num2str(Y_th*100) '_w' num2str(w_choice) wadd_str debug_flag '.png'],'-dpng','-r600');
                        
                    end
                end
            end
        end
    end
end

%% 2) estimate and plot confusion matrices --> evaluate performance
% --> expert vs. models

% comparison classified categories cafpas expert vs. models
conf_mat = nan(3,3,3,3,3);
for w = [1023 1024 1025]
    for dc = 1:3
        for i_model = 1:3
            [Cmat_model_m,iua_model_m,iuc_model_m] = unique(squeeze(cat_comps_tree([1 i_model+1],w,:,dc))','rows'); % for confusion matrix expert vs. 1 model
            
            % confusion matrix numbers (expert
            % and 1 model)
            hist_conf2D = zeros(3,3);
            hist_conf = hist(iuc_model_m,[1:max(iuc_model_m)]);
            for ni1 = 1:3 % expert dimension
                for ni2 = 1:3 % predicted dimension (y-axis in plot)
                    c_idx = find(sum(Cmat_model_m == [ni1 ni2],2) == 2);
                    if ~isempty(c_idx)
                        hist_conf2D(ni1,ni2) = hist_conf(c_idx);
                    end
                end
            end
            
            accuracy_m(w-1022,dc,i_model) = sum(diag(hist_conf2D)/sum(sum(hist_conf2D))); % proportion correctly classified of all classifications
            conf_mat(w-1022,dc,i_model,:,:) = hist_conf2D;
            
            figh30j(w,i_model,dc) = figure('visible',pp.visible);
            imagesc(hist_conf2D'./sum(hist_conf2D',1))
            colormap('gray')
            colorbar;
            axis xy;
            xlabel('Category (expert)') % not expert label --> category predicted based on expert CAFPAs
            set(gca,'XTick',1:1:3,'XTickLabels',dc_legend{dc})
            ylabel('Category (predicted)')
            set(gca,'YTick',1:1:3,'YTickLabels',dc_legend{dc})
            caxis([0 1])
            for ni1 = 1:3
                for ni2 = 1:3
                    if hist_conf2D(ni1,ni2)/sum(hist_conf2D(ni1,:),2) > 0.4
                        text(ni1,ni2,1,num2str(hist_conf2D(ni1,ni2)),'horizontalalignment','center');
                    else
                        text(ni1,ni2,1,num2str(hist_conf2D(ni1,ni2)),'horizontalalignment','center','color','w');
                    end
                end
            end
            
            set(figh30j(w,i_model,dc), 'PaperPositionMode', 'manual');
            set(figh30j(w,i_model,dc), 'PaperUnits', 'centimeters');
            if dc == 1 || dc == 2
                set(figh30j(w,i_model,dc), 'PaperPosition', [0 0 12 8.5]); % 11
            elseif dc == 3 % different width due to YTickLabel!
                set(figh30j(w,i_model,dc), 'PaperPosition', [0 0 11 8.5]); % 11
            end
            
            if sflag
                print(figh30j(w,i_model,dc),[fig_folder filesep pfig filesep 'conf-mat_expert_dc-' diagcase_flags{dc} '-' model_names{i_model} '_Y' num2str(Y_th*100) '_w' num2str(w) wadd_str debug_flag '.eps'],'-painters','-depsc','-r600');
                print(figh30j(w,i_model,dc),[fig_folder filesep pfig filesep 'conf-mat_expert_dc-' diagcase_flags{dc} '-' model_names{i_model} '_Y' num2str(Y_th*100) '_w' num2str(w) wadd_str debug_flag '.png'],'-dpng','-r600');
                
            end
            
            %% 3) Difference between expert/predicted CAFPA and classification threshold
            
            
            for g = 1:max(iuc_model_m)
                idx_g = find(iuc_model_m == g);
                
                if abs(Cmat_model_m(g,2)-Cmat_model_m(g,1))>0
                    
                    switch diagcase_flags{dc}
                        case 'findings1'
                            if sum(Cmat_model_m(g,:) == [1 2]) == 2 || sum(Cmat_model_m(g,:) == [1 3]) == 2 || sum(Cmat_model_m(g,:) == [2 1]) == 2 || sum(Cmat_model_m(g,:) == [3 1]) == 2
                                ca_th_idx = 1; % classification threshold of first comparison set
                            elseif sum(Cmat_model_m(g,:) == [2 3]) == 2 || sum(Cmat_model_m(g,:) == [3 2]) == 2
                                ca_th_idx = 2; % classification threshold of second comparison set
                            end
                        case 'findings2'
                            if sum(Cmat_model_m(g,:) == [1 2]) == 2 || sum(Cmat_model_m(g,:) == [1 3]) == 2 || sum(Cmat_model_m(g,:) == [2 1]) == 2 || sum(Cmat_model_m(g,:) == [3 1]) == 2
                                ca_th_idx = 1;
                            elseif sum(Cmat_model_m(g,:) == [2 3]) == 2 || sum(Cmat_model_m(g,:) == [3 2]) == 2
                                ca_th_idx = 3;
                            end
                        case 'treat'
                            if sum(Cmat_model_m(g,:) == [1 2]) == 2 || sum(Cmat_model_m(g,:) == [1 3]) == 2 || sum(Cmat_model_m(g,:) == [2 1]) == 2 || sum(Cmat_model_m(g,:) == [3 1]) == 2
                                ca_th_idx = 4;
                            elseif sum(Cmat_model_m(g,:) == [2 3]) == 2 || sum(Cmat_model_m(g,:) == [3 2]) == 2
                                ca_th_idx = 5;
                            end
                    end
                    
                    figh30d(i_model,dc) = figure('visible',pp.visible);
                    hold on;
                    plot([0.5:1:10.5],zeros(11,1),'-.','color',[0.5 0.5 0.5],'linewidth',1);
                    b1 = boxplot(input_data{1+i_model}(idx_g,:)-ca_th(ca_th_idx,:));
                    b1 = handle(b1); for ib = 1:7, set(b1(ib,:),'LineWidth', 1.5,'color',pp.colors{m_colors(i_model+1)}); end
                    
                    ylim([-0.7 0.7])
                    title(model_names_paper{i_model+1});
                    % title(['[' num2str(Cmat(g,:)) '] (N = ' num2str(length(idx_sort)) '), expert'])
                    % xlabel('CAFPAs')
                    set(gca, 'TickLabelInterpreter', 'tex');
                    set(gca,'XTick',1:1:10,'XTickLabels',cafpa_names_lc)
                    ylabel('{\it \Deltap_{CAFPA,predicted}}')
                    
                    text(8.8,0.63,['{\itN} = ' num2str(length(idx_g))]);
                    
                    set(figh30d(i_model,dc), 'PaperPositionMode', 'manual');
                    set(figh30d(i_model,dc), 'PaperUnits', 'centimeters');
                    set(figh30d(i_model,dc), 'PaperPosition', [0 0 11 8.5]);
                    
                    if sflag
                        print(figh30d(i_model,dc),[fig_folder filesep pfig filesep 'cafpas_agreement_model-diff_dc-' diagcase_flags{dc} '_' model_names{i_model} '_Y' num2str(Y_th*100) '_w' num2str(w) '_' strrep(num2str(Cmat_model_m(g,:)),'  ','-') wadd_str debug_flag '.eps'],'-painters','-depsc','-r600');
                        print(figh30d(i_model,dc),[fig_folder filesep pfig filesep 'cafpas_agreement_model-diff_dc-' diagcase_flags{dc} '_' model_names{i_model} '_Y' num2str(Y_th*100) '_w' num2str(w) '_' strrep(num2str(Cmat_model_m(g,:)),'  ','-') wadd_str debug_flag '.png'],'-dpng','-r600'); % (-r1000 for disputation/talks)
                        
                    end
                end
            end
            
            
            
            % 3) here for expert:
            for g = 1:max(iuc_model_m)
                idx_g = find(iuc_model_m == g); % depends on model with which confusion occured
                
                if abs(Cmat_model_m(g,2)-Cmat_model_m(g,1))>0
                    
                    switch diagcase_flags{dc}
                        case 'findings1'
                            if sum(Cmat_model_m(g,:) == [1 2]) == 2 || sum(Cmat_model_m(g,:) == [1 3]) == 2 || sum(Cmat_model_m(g,:) == [2 1]) == 2 || sum(Cmat_model_m(g,:) == [3 1]) == 2
                                ca_th_idx = 1; % classification threshold of first comparison set
                            elseif sum(Cmat_model_m(g,:) == [2 3]) == 2 || sum(Cmat_model_m(g,:) == [3 2]) == 2
                                ca_th_idx = 2;
                            end
                        case 'findings2'
                            if sum(Cmat_model_m(g,:) == [1 2]) == 2 || sum(Cmat_model_m(g,:) == [1 3]) == 2 || sum(Cmat_model_m(g,:) == [2 1]) == 2 || sum(Cmat_model_m(g,:) == [3 1]) == 2
                                ca_th_idx = 1;
                            elseif sum(Cmat_model_m(g,:) == [2 3]) == 2 || sum(Cmat_model_m(g,:) == [3 2]) == 2
                                ca_th_idx = 3;
                            end
                        case 'treat'
                            if sum(Cmat_model_m(g,:) == [1 2]) == 2 || sum(Cmat_model_m(g,:) == [1 3]) == 2 || sum(Cmat_model_m(g,:) == [2 1]) == 2 || sum(Cmat_model_m(g,:) == [3 1]) == 2
                                ca_th_idx = 4;
                            elseif sum(Cmat_model_m(g,:) == [2 3]) == 2 || sum(Cmat_model_m(g,:) == [3 2]) == 2
                                ca_th_idx = 5;
                            end
                    end
                    
                    figh30d(dc) = figure('visible',pp.visible);
                    
                    hold on;
                    plot([0.5:1:10.5],zeros(11,1),'-.','color',[0.5 0.5 0.5],'linewidth',1);
                    b1 = boxplot(input_data{1}(idx_g,:)-ca_th(ca_th_idx,:));
                    b1 = handle(b1); for ib = 1:7, set(b1(ib,:),'LineWidth', 1.5,'color',pp.colors{m_colors(1)}); end
                    
                    ylim([-0.7 0.7])
                    title(model_names_paper{1});
                    % title(['[' num2str(Cmat(g,:)) '] (N = ' num2str(length(idx_sort)) '), expert'])
                    % xlabel('CAFPAs')
                    set(gca, 'TickLabelInterpreter', 'tex');
                    set(gca,'XTick',1:1:10,'XTickLabels',cafpa_names_lc);
                    ylabel('{\it \Deltap_{CAFPA,expert}}');
                    text(8.8,0.63,['{\itN} = ' num2str(length(idx_g))]);
                    
                    set(figh30d(dc), 'PaperPositionMode', 'manual');
                    set(figh30d(dc), 'PaperUnits', 'centimeters');
                    set(figh30d(dc), 'PaperPosition', [0 0 11 8.5]);
                    
                    if sflag
                        print(figh30d(dc),[fig_folder filesep pfig filesep 'cafpas_agreement_expert-diff_dc-' diagcase_flags{dc} '_' model_names_add{1} '-' model_names{i_model} '_Y' num2str(Y_th*100) '_w' num2str(w) '_' strrep(num2str(Cmat_model_m(g,:)),'  ','-') wadd_str debug_flag '.eps'],'-painters','-depsc','-r600');
                        print(figh30d(dc),[fig_folder filesep pfig filesep 'cafpas_agreement_expert-diff_dc-' diagcase_flags{dc} '_' model_names_add{1} '-' model_names{i_model} '_Y' num2str(Y_th*100) '_w' num2str(w) '_' strrep(num2str(Cmat_model_m(g,:)),'  ','-') wadd_str debug_flag '.png'],'-dpng','-r600'); % (-r1000 for disputation/talks)
                        
                    end
                end
            end
        end % i_model
    end
end

if ~exist([res_folder filesep 's7_eval_accuracy'], 'dir')
    mkdir([res_folder filesep 's7_eval_accuracy']);
end

% sorted conf mat for table in paper
conf_mat_sorted = [flipud(squeeze(conf_mat(1,1,1,:,:))'),flipud(squeeze(conf_mat(1,2,1,:,:))'),flipud(squeeze(conf_mat(1,3,1,:,:))'); ...
    flipud(squeeze(conf_mat(1,1,2,:,:))'),flipud(squeeze(conf_mat(1,2,2,:,:))'),flipud(squeeze(conf_mat(1,3,2,:,:))'); ...
    flipud(squeeze(conf_mat(1,1,3,:,:))'),flipud(squeeze(conf_mat(1,2,3,:,:))'),flipud(squeeze(conf_mat(1,3,3,:,:))'); ...
    
    flipud(squeeze(conf_mat(2,1,1,:,:))'),flipud(squeeze(conf_mat(2,2,1,:,:))'),flipud(squeeze(conf_mat(2,3,1,:,:))'); ...
    flipud(squeeze(conf_mat(2,1,2,:,:))'),flipud(squeeze(conf_mat(2,2,2,:,:))'),flipud(squeeze(conf_mat(2,3,2,:,:))'); ...
    flipud(squeeze(conf_mat(2,1,3,:,:))'),flipud(squeeze(conf_mat(2,2,3,:,:))'),flipud(squeeze(conf_mat(2,3,3,:,:))'); ...
    
    flipud(squeeze(conf_mat(3,1,1,:,:))'),flipud(squeeze(conf_mat(3,2,1,:,:))'),flipud(squeeze(conf_mat(3,3,1,:,:))'); ...
    flipud(squeeze(conf_mat(3,1,2,:,:))'),flipud(squeeze(conf_mat(3,2,2,:,:))'),flipud(squeeze(conf_mat(3,3,2,:,:))'); ...
    flipud(squeeze(conf_mat(3,1,3,:,:))'),flipud(squeeze(conf_mat(3,2,3,:,:))'),flipud(squeeze(conf_mat(3,3,3,:,:))')];

save([res_folder filesep 's7_eval_accuracy' filesep 'accuracy_conf-mat_results-II-2' wadd_str debug_flag '.mat'],'accuracy_m','conf_mat','conf_mat_sorted'); % accuracy: conf-mat vs. true; accuracy_m: conf-mat vs. expert

%% 5) Certainty plot: plot median of certainty for each model and each category --> Figure 10

for w = [1023,1024,1025]
    for dc = 1:3
        % calculate median and interquartiles across patients classified
        % into each category
        for cat_idx = 1:3
            for i_model = 1:4
                p25_50_75(cat_idx,i_model,:) = prctile(cert_comps_tree(i_model,w,cat_comps_tree(i_model,w,:,dc)==cat_idx,cat_idx,dc),[25 50 75]);
                % check: figure; hist(squeeze(cert_comps_tree(i_model,w,cat_comps_tree(i_model,w,:,dc)==cat_idx,cat_idx,dc)))
            end
        end
        p25_50_75_all(dc,w-1022,:,:,:) = p25_50_75;
        
        figh29b(dc,w) = figure('visible',pp.visible);
        b = bar([1:1:3],p25_50_75(:,:,2));% dimensions: [cat x models]
        
        % update color idx with true labels
        bar_colors = m_colors;
        for i_model = 1:4
            set(b(i_model),'Facecolor',pp.colors{bar_colors(i_model)},'EdgeColor','none');
        end
        
        % add errorbar
        hold on
        er = errorbar(reshape([b.XEndPoints],3,4),p25_50_75(:,:,2),p25_50_75(:,:,2)-p25_50_75(:,:,1),p25_50_75(:,:,3)-p25_50_75(:,:,2),'LineStyle','none','Color',[0 0 0]);
        hold off
        
        ylabel('Certainty');
        set(gca,'XTick',1:3,'XTickLabel',dc_legend{dc})
        axis([0.5 3.5 0 1]);
        
        legend(model_names_paper,'Location','NorthEast');
        
        set(figh29b(dc,w), 'PaperPositionMode', 'manual');
        set(figh29b(dc,w), 'PaperUnits', 'centimeters');
        set(figh29b(dc,w), 'PaperPosition', [0 0 13 9]);
        
        if sflag
            filename = [fig_folder filesep pfig filesep 'Median-class-cert_' diagcase_flags{dc} '_all-models' '_Y' num2str(Y_th*100) '_w' num2str(w) wadd_str debug_flag];
            print(figh29b(dc,w),[filename '.eps'],'-painters','-depsc','-r600');
            print(figh29b(dc,w),[filename '.png'],'-dpng','-r600');
        end
        
        
    end
end

% certainty-sorted --> for table in paper
certainty_sorted = [];
for dc = 1:3
    for w_idx = 1:3
        for i_model = 1:4
            certainty_sorted = [certainty_sorted; ...
                squeeze(p25_50_75_all(dc,w_idx,1,i_model,[2 1 3]))',squeeze(p25_50_75_all(dc,w_idx,2,i_model,[2 1 3]))',squeeze(p25_50_75_all(dc,w_idx,3,i_model,[2 1 3]))'];
        end
    end
end

certainty_sorted = round(certainty_sorted,2);

if ~exist([res_folder filesep 's7_eval_certainty'], 'dir')
    mkdir([res_folder filesep 's7_eval_certainty']);
end
save([res_folder filesep 's7_eval_certainty' filesep 'certainty_results-II-2' wadd_str debug_flag '.mat'],'p25_50_75_all','certainty_sorted');
