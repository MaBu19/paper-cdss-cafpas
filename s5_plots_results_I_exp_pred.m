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
% s5_plots_results_I_exp_pred.m
% This script evaluates classification in comparison sets and plots results.
%
% Mareike Buhl
% mareike.buhl@uol.de
%
% v1.1, 14.12.2021
% v1.0, 12.11.2021
%
% Matlab R2020b
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
clc;

addpath(genpath('./functions/'));
addpath(genpath('./results/'));

fig_folder = './plots/';
data_folder = './data/';
res_folder = './results/';

if ~exist([res_folder filesep 's5_eval-rel-freq'], 'dir')
    mkdir([res_folder filesep 's5_eval-rel-freq']);
end

% change between first (0) and second (1) run:
add_w_flag = 0; % if additional weights should be used or not
% add_w_flag = 0; --> figures 4 and 5
% add_w_flag = 1; --> figure 6
wadd_str = ['_wadd-' num2str(add_w_flag)];

debug_flag = '';

pfig = ['s5_results_I' wadd_str];

if ~exist([fig_folder '/' pfig], 'dir')
    mkdir([fig_folder '/' pfig]);
end

sflag = 1; % save plots

% check if running Matlab or Octave:
isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0; % 0 in Matlab, 1 in Octave

% parameters
Y_th = 0.9; % Y90 criterion

%% load classification results
load([res_folder filesep 's4_classification' filesep 'classification_results_labeled_' num2str(Y_th*100) wadd_str debug_flag '.mat']);

model_names = {'lasso','elasticNet','randomForest'};
model_names_add = [{'expert'}, model_names];
model_names_paper = {'Expert','Lasso Regression','Elastic Net','Random Forest'};
m_colors = [13 11 10 9]; % fit to Paper Saak et al. (2020)
comparison = {'nh-hi','high-high+cond','high-high+recr','none-device','HA-CI','none-CI'};

%% add paper-independent plot properties
pp.visible = 'off';
pp.colors = {rgb('Blue'),rgb('DarkMagenta'),rgb('Indigo'),rgb('FireBrick'),rgb('Chocolate'),rgb('DarkOrange'),rgb('Gold'),rgb('LimeGreen'),rgb('DarkGreen'),rgb('MidnightBlue'),rgb('DeepSkyBlue'),rgb('RoyalBlue'),rgb('YellowGreen'),rgb('DeepPink'),'none',rgb('Gray'),rgb('Red'),rgb('Black')}; % ggf. wiederholen/mit weiteren Farben ergänzen
pp.symbols = {'o','s','v','<','*','>','+','d','^','p','h','x','o','s'};

%% 1) Calculate Youden index and determine CAFPA combinations fulfilling the Y90 criterion
for comps = 1:5
    for i_model = 1:4
        % calculate Youden index
        Y{comps}(:,i_model) = sens_p_comps{comps}{i_model}+spec_p_comps{comps}{i_model}-1;
        
        % determine Y98 (Y_th) combinations
        idx_red{comps}{i_model} = [];
        idx_red{comps}{i_model} = calc_youden_rel(spec_p_comps{comps}{i_model},sens_p_comps{comps}{i_model},Y_th);
        % T_th_absolute could defined by expert performance (i_model = 1) and be used for all models
    end
end

%% 2) Relative weights of CAFPAs --> high performance
for comps = 1:5
    for i_model = 1:4
        % store weights for all comparison sets in cell
        wp2_comp{comps}{i_model} = wp_comps{comps}{i_model}(idx_red{comps}{i_model},:);
        
        % calculate relative frequency of weights (histograms to be plotted in fig6)
        weights{i_model}(comps,:) = mean(sum(wp2_comp{comps}{i_model}~=0,1),1)/size(wp2_comp{comps}{i_model},1); % ~=0 extracts index - binary information if parameter included or not
        num_w(comps,i_model) = size(wp2_comp{comps}{i_model},1);
    end
end

save([res_folder filesep 's5_eval-rel-freq' filesep 'weights_rel-freq_Y' num2str(Y_th*100) wadd_str debug_flag '.mat'],'weights','num_w');

if add_w_flag == 0
    %% 3) Youden scatter plots expert vs. models + indices of best common weight combinations --> use as Figure 4
    add_str = '';
    
    if isOctave == 1
        pp.isOctave = 1;
    else
        pp.isOctave = 0;
    end
    
    pp.xlabel = {'Youden index (expert)'};
    pp.ylabel = {'Youden index (predicted)'};
    idx_empty = zeros(5,3);
    
    for comps = 1:5 
        data_c_exp = Y{comps}(:,1);
        ymax = Y_th*max(data_c_exp);
        idx_choice_exp = find(data_c_exp>=ymax);
        
        for i_model = 2:4
            pp.point = [m_colors(i_model) 17; m_colors(i_model) 17; 1 1];
            
            data_c_m = Y{comps}(:,i_model);
            ymax_m = Y_th*max(data_c_m);
            idx_choice_m = find(data_c_m>=ymax_m); 
            idx_com_tmp = intersect(idx_choice_exp,idx_choice_m);
            
            if isempty(idx_com_tmp)
                % use best model combination if no common combination is available
                [Ybest,Ybest_idx]=max(Y{comps}(idx_choice_m,i_model));
                idx_com_tmp = idx_choice_m(Ybest_idx);
                idx_empty(comps,i_model-1) = 1;
            end
            
            figh14(comps) = figure('visible',pp.visible);
            figh14(comps) = plot_scatter(figh14(comps),{data_c_exp;data_c_exp(idx_com_tmp)},{data_c_m;data_c_m(idx_com_tmp)},pp);
            
            idx_com{comps}{i_model} = idx_com_tmp;
            
            if sflag 
                print(figh14(comps),[fig_folder filesep pfig filesep 'scatter_youden_' comparison{comps} '-' model_names_add{i_model} '_Y' num2str(Y_th*100) add_str wadd_str debug_flag '.eps'],'-painters','-depsc','-r600');
                print(figh14(comps),[fig_folder filesep pfig filesep 'scatter_youden_' comparison{comps} '-' model_names_add{i_model} '_Y' num2str(Y_th*100) add_str wadd_str debug_flag '.png'],'-dpng','-r600'); % (-r1000 for disputation/talks)
            end
        end % i_model
    end % comps
end



if add_w_flag == 0
    %% 4) plot relative frequency of CAFPAs for common weights (exp-model, across models) --> Figure 5
    for comps = 1:5
        for i_model = 2:4
            % store weights for all comparison sets in cell
            wp2_comp_com{comps}{i_model} = wp_comps{comps}{i_model}(idx_com{comps}{i_model},:);
            
            % calculate relative frequency of weights (histograms to be plotted in fig6)
            weights_com{i_model-1}(comps,:) = mean(sum(wp2_comp_com{comps}{i_model}~=0,1),1)/size(wp2_comp_com{comps}{i_model},1); % ~=0 extracts index - binary information if parameter included or not
            num_w_com(comps,i_model-1) = size(wp2_comp_com{comps}{i_model},1);
        end
    end
    
    for ci = 1:length(weights_com) 
        % update pp.point (color)
        pp.point(1:2,1) = m_colors(ci+1);
        pp.idx_empty = idx_empty(:,ci);
        
        figh14b = figure('visible',pp.visible);
        [figh14b,h,ppa] = plot_weights(figh14b,weights_com{ci},pp); % for single plot: (1,:)
        
        roem = {'I','II','III','IV','V'};
        for comps = 1:size(weights_com{ci},1)
            t = title(h(comps),['Comparison set ' roem{comps} ' (N = ' num2str(length(idx_com{comps}{ci+1})) ')'],'fontsize',ppa.fsize-2);
            set(t,'position',get(t,'position')-[0 0.05 0]);
            if comps == 3 % 3
                ylabel(h(comps),'Relative frequency of CAFPAs','fontsize',ppa.fsize-1); %-2
            end
        end
        
        if isOctave
            warning('Check figure properties (optimized in Matlab)');
        end
        
        if sflag
            print(figh14b,[fig_folder filesep pfig filesep 'common_weights_cafpas_frequencies_' model_names{ci} '_Y' num2str(Y_th*100) add_str wadd_str debug_flag '.eps'],'-painters','-depsc','-r600');
            print(figh14b,[fig_folder filesep pfig filesep 'common_weights_cafpas_frequencies_' model_names{ci} '_Y' num2str(Y_th*100) add_str wadd_str debug_flag '.png'],'-dpng','-r600');
        end
    end
    
    % save rel-freq weights (Y>= Y_th)
    save([res_folder filesep 's5_eval-rel-freq' filesep 'exp-model-weights_rel-freq_Y' num2str(Y_th*100)  wadd_str debug_flag '.mat'],'weights_com','num_w_com'); 
    
    
    % common weights across models
    idx_empty_all = zeros(5,1);
    for comps = 1:5
        idx_com_23{comps} = intersect(idx_com{comps}{2},idx_com{comps}{3}); % Lasso, EN
        idx_com_34{comps} = intersect(idx_com{comps}{3},idx_com{comps}{4}); % EN, RF
        idx_com_42{comps} = intersect(idx_com{comps}{4},idx_com{comps}{2}); % RF, Lasso
        
        idx_com_all{comps} = intersect(idx_com_23{comps},idx_com_34{comps}); % two out of three are sufficient for comparison
        
        % choose best model combination if no overlap of all models
        if isempty(idx_com_all{comps})
            
            [Ybest,Ybest_idx]=max(Y{comps}(idx_com_23{comps},2)); % --> best combination between lasso and elastic net
            idx_com_all{comps} = idx_com_23{comps}(Ybest_idx);
            idx_empty_all(comps,1) = 1;
            if isempty(idx_com_all{comps}) % if no common across models, use best from lasso and expert common weights
                [Ybest,Ybest_idx]=max(Y{comps}(idx_com{comps}{i_model}));
                idx_com_all{comps} = idx_com{comps}{i_model}(Ybest_idx);
            end
        end
    end
   
    for comps = 1:5
        for i_model = 1:4 % only "dummy loop" to have the same size of weights_com_all to be used in classification (but all the same)
            % store weights for all comparison sets in cell
            wp2_comp_com_all{comps} = wp_comps{comps}{1}(idx_com_all{comps},:);
            
            % calculate relative frequency of weights (histograms to be plotted in fig6)
            weights_com_all{i_model}(comps,:) = mean(sum(wp2_comp_com_all{comps}~=0,1),1)/size(wp2_comp_com_all{comps},1); % ~=0 extracts index - binary information if parameter included or not
            num_w_com_all(comps,i_model) = size(wp2_comp_com_all{comps},1);
        end
    end
    
    for ci = 1 
        % update pp.point (color)
        pp.point(1:2,1) = 2;
        pp.idx_empty = idx_empty_all(:,ci);
        
        figh14c = figure('visible',pp.visible);
        [figh14c,h,ppa] = plot_weights(figh14c,weights_com_all{ci},pp);
        
        roem = {'I','II','III','IV','V'};
        for comps = 1:size(weights_com_all{ci},1)
            t = title(h(comps),['Comparison set ' roem{comps} ' (N = ' num2str(length(idx_com_all{comps})) ')'],'fontsize',ppa.fsize-2);
            set(t,'position',get(t,'position')-[0 0.05 0]);
            if comps == 3
                ylabel(h(comps),'Relative frequency of CAFPAs','fontsize',ppa.fsize-1);
            end
        end
        
        if isOctave
            warning('Check figure properties (optimized in Matlab)');
        end
        
        if sflag
            print(figh14c,[fig_folder filesep pfig filesep 'common_weights_cafpas_frequencies_all-models_Y' num2str(Y_th*100) add_str wadd_str debug_flag '.eps'],'-painters','-depsc','-r600');
            print(figh14c,[fig_folder filesep pfig filesep 'common_weights_cafpas_frequencies_all-models_Y' num2str(Y_th*100) add_str wadd_str debug_flag '.png'],'-dpng','-r600');
        end
        
        
    end
    % save rel-freq weights (Y>= Y_th, common for expert and all models)
    % --> use in classification (additional rows 1024 and 1025)
    save([res_folder filesep 's5_eval-rel-freq' filesep 'common_weights_rel-freq_Y' num2str(Y_th*100) wadd_str debug_flag '.mat'],'weights_com_all','num_w_com_all','idx_com','idx_com_all')
end

if add_w_flag == 1
    %% 5) Figure 6: Overview of performance using different (groups of weights)
       
    for comps = 1:5
        for i_model = 1:4
            Y_overview{comps}(1,i_model) = max(Y{comps}(:,i_model)); 
            % for Y90: calculate median and interquartiles across patients classified
            % into each category
            p25_50_75(comps,i_model,:) = prctile(Y{comps}(idx_red{comps}{i_model},i_model),[25 50 75]);
            Y_overview{comps}(2,i_model) = p25_50_75(comps,i_model,2); % checked that it is the same as with median function
            Y_overview{comps}(3,i_model) = Y{comps}(1023,i_model);
            if add_w_flag % weights were loaded and used in classification script
                Y_overview{comps}(4,i_model) = Y{comps}(1024,i_model); % model- and comparison-set specific weights from Y90 cases
                Y_overview{comps}(5,i_model) = Y{comps}(1025,i_model); % comparison-set specific weights from Y90 cases, generalized (common) across models (but could perform differently if used by different models)
                
            end
        end
    end
    
    
    for comps = 1:5
        figh4b(comps) = figure('visible',pp.visible);
        hold on;
        box on;
        b = bar(Y_overview{comps});
        for i_model = 1:4
            set(b(i_model),'Facecolor',pp.colors{m_colors(i_model)},'EdgeColor','none');
        end
        
        if 0
            % add errorbar (Y90 combinations) - works, but small and not well
            % visible
            hold on
            x_bars = reshape([b.XEndPoints],5,4);
            er = errorbar(x_bars(2,:),p25_50_75(comps,:,2),p25_50_75(comps,:,2)-p25_50_75(comps,:,1),p25_50_75(comps,:,3)-p25_50_75(comps,:,2),'LineStyle','none','Color',[0 0 0]);
            hold off
        end
        
        ylabel('Youden index');
        set(gca,'XTick',1:5,'XTickLabel',{'max',['Y' num2str(Y_th*100)], 'uniform','rel-model','rel-all'},'FontSize',7,'XTickLabelRotation',45) % Y90: median; 'rel-freq','rel-freq-models' --> 'rel-model','rel-all'
        axis([0.5 5.5 0 1]);
        %     title([comparison{comps}]);
        if comps == 3
            legend(model_names_paper,'Location','best','NumColumns',1,'FontSize',5);
        end
        
        
        set(figh4b(comps), 'PaperPositionMode', 'manual');
        set(figh4b(comps), 'PaperUnits', 'centimeters');
        set(figh4b(comps), 'PaperPosition', [0 0 5 4]); % 13 9
        
        if sflag
            filename = [fig_folder filesep pfig filesep 'Y_overview_all-binary_' comparison{comps} '_all-models' '_Y' num2str(Y_th*100) wadd_str debug_flag];
            print(figh4b(comps),[filename '.eps'],'-painters','-depsc','-r600');
            print(figh4b(comps),[filename '.png'],'-dpng','-r600');
        end
    end
end