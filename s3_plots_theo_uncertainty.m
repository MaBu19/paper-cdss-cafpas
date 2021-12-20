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
% s3_plots_theo_uncertainty.m
% This script plots training distributions and uncertainty depending on 
% p_CAFPA values, as well as classification thresholds as overview about all 
% CAFPAs and comparison sets. 
%  
% Mareike Buhl
% mareike.buhl@uol.de
%
% v1.1, 14.12.2021
% v1.0, 27.08.2020
%
% Matlab R2020b
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
clc;

addpath(genpath('./functions/'));

res_folder = './results/';
fig_folder = './plots/';

pfig = 's3_methods'; 
if ~exist([fig_folder filesep pfig], 'dir')
    mkdir([fig_folder filesep pfig]);
end

if ~exist([res_folder filesep 's3_classification_thresholds'], 'dir')
    mkdir([res_folder filesep 's3_classification_thresholds']);
end

sflag = 1;
pp.visible = 'off';
dist_type = 'beta';

x_vec = 0.001:0.001:0.999; % original stepsize: 0.01 --> here increased for plot resolution (needs rescaling of probability density plot by factor 10)
comparison = {'nh-hi','high-high+cond','high-high+recr','none-device','HA-CI'};
comp_roem = {'I','II','III','IV','V'};
cafpa_names_lc = {'C_{A1}','C_{A2}','C_{A3}','C_{A4}','C_{U1}','C_{U2}','C_{B}','C_{N}','C_{C}','C_{E}'};

fsize = 11;

for comps = 1:length(comparison)
    % load training data
    [filter_crit,cats,single_flag,~,~] = definition_comparisons(comparison{comps});
    
    % training data may be distributed over several files
    files = dir([res_folder 's2_training/*' comparison{comps} '*cv1.txt']); 
    [input_names_training,mu{comps},sig{comps},~] = read_table_txt_paper2_02([res_folder 's2_training/'],files,length(cats));
    
    % evaluate pdfs and calculate certainty for all possible x values
    [p_eval,cert,pdf_vec] = eval_train_dist(x_vec,repmat(x_vec',1,10),mu{comps}{1},sig{comps}{1},dist_type);
    
    for num_p = 1:10
        % calculate Bayes overall error rate (James et al. 2013, (2.11), p. 38)
        ov_error(comps,num_p) = 1 - mean(max(cert(:,num_p,1),cert(:,num_p,2)));
        
        % plot
        figh1(num_p) = figure('visible',pp.visible);
        hold on;
        box on;
        yyaxis left
        plot(x_vec,10*squeeze(pdf_vec(num_p,1,:)),'-','color',rgb('DeepPink'),'linewidth',1.5);
        plot(x_vec,10*squeeze(pdf_vec(num_p,2,:)),'-','color',rgb('DodgerBlue'),'linewidth',1.5);
        ylabel('Probability density','FontSize',fsize)
        ylim([0 0.15])
        title(['Comparison set ' comp_roem{comps} ', ' cafpa_names_lc{num_p}],'FontSize',fsize)
        
        yyaxis right
        plot(x_vec,max(cert(:,num_p,1),cert(:,num_p,2)),'--','color',rgb('DarkOrange'),'linewidth',1.5)
        ylabel('Certainty','FontSize',fsize)
        ylim([0 1.02])
        xlabel('{\it p_{CAFPA}}','FontSize',fsize)
        
        if num_p == 1 && comps == 1
            legend({'Normal hearing','Hearing impaired','Certainty'},'FontSize',fsize-2)
        end
        
        ax = gca;
        ax.YAxis(1).Color = 'k';
        ax.YAxis(2).Color = 'k';
        
        set(figh1(num_p), 'PaperPositionMode', 'manual');
        set(figh1(num_p), 'PaperUnits', 'centimeters');
        set(figh1(num_p), 'PaperPosition', [0 0 9.5 7.35]);
        
        if sflag
            filename = [fig_folder filesep pfig filesep 'training_theo_certainty_' comparison{comps} '_' num2str(num_p)];
            print(figh1(num_p),[filename '.eps'],'-painters','-depsc','-r600');
            print(figh1(num_p),[filename '.png'],'-dpng','-r600');
        end
        
        % calculate intersection - via minimum of certainty
        [p_min(num_p),ca_min(num_p)] = min(max(cert(2:end-1,num_p,1),cert(2:end-1,num_p,2)));     
    end
    
    % CAFPA intersections:
    ca_th = x_vec(ca_min);
    ca_th_all(comps,:) = ca_th;
     
    save([res_folder filesep 's3_classification_thresholds' filesep 'ca_threshold_' comparison{comps} '.mat'],'ca_th'); 
    
end

save([res_folder filesep 's3_classification_thresholds' filesep 'Bayes_error_all.mat'],'ov_error');

%% plot classification thresholds

figh2 = figure('visible',pp.visible);
map = calc_colormap(rgb('FireBrick'),rgb('Gold'),rgb('DarkGreen')); map = map';
imagesc(ca_th_all)
colormap(gca,map);
cb = colorbar;
title('Classification thresholds','FontSize',fsize)
% set(gca,'YTick',1:1:5,'YTickLabel',comparison,'FontSize',fsize-2)
set(gca,'YTick',1:1:5,'YTickLabel',comp_roem,'FontSize',fsize); % spart mind. 1cm!
set(gca,'XTick',1:1:10,'XTickLabel',cafpa_names_lc,'FontSize',fsize)
cb.Label.String = '{\it p_{CAFPA}}';
set(cb,'FontSize',fsize)
caxis([0 1])

for comps = 1:5 
    for num_p = 1:10 
        if ov_error(comps,num_p)>0.35
            text(num_p,comps,'x','horizontalAlignment','center')
        end
    end
end

set(figh2, 'PaperPositionMode', 'manual');
set(figh2, 'PaperUnits', 'centimeters');
set(figh2, 'PaperPosition', [0 0 10.9 7.05]);


if sflag
    print(figh2,[fig_folder filesep pfig filesep 'cafpas_classification_thresholds.eps'],'-painters','-depsc','-r600');
    print(figh2,[fig_folder filesep pfig filesep 'cafpas_classification_thresholds.png'],'-dpng','-r600');
    
end


