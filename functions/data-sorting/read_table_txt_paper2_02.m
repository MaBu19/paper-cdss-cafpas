% read data for probability distributions as saved in
% paper2_02_distributions
% 
% v1, MB 01.08.19
% v2, MB 24.02.20 - adaptations for cafpa-framework
% 
% INPUT: 
% files             struct of files - needed for filenames (3, containing the different files to
%                   cover all measurements)
% num_cats          number of categories in the respective comparison
% 
% OUTPUT: 
% meas_idx_unique   indices of measurements read out from files (all by default) - implement if needed
% meas_names_files  names of measurements 
% mu                cell [1xnum_measurements], each [num_p x num_cats]
% sig               cell [1xnum_measurements], each [num_p x num_cats]
% dist_type         distribution fitted for respective measurement 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [meas_names_files,mu,sig,dist_type] = read_table_txt_paper2_02(folder,files,num_cats)
 
num_files = length(files); 

for f = 1:num_files
    fileID = fopen([folder filesep files(f).name],'r');
    Cf{f} = textscan(fileID,['%d %s %s %s %d', repmat('%f',[1,8])],'CommentStyle','#','CollectOutput',1 );
end

meas_idx = []; 
meas_names_files_test = []; 
dist_type_all = []; 
mu_tmp = []; 
sig_tmp = []; 
dc = 0; 
for f = 1:num_files
    meas_idx = [meas_idx; Cf{f}{1}+dc];
    dc = dc + length(unique(Cf{f}{1})); 
    
    meas_names_files_test = [meas_names_files_test; Cf{f}{2}(:,1)]; 
    dist_type_all = [dist_type_all; Cf{f}{2}(:,2)]; 
    
    mu_tmp = [mu_tmp; Cf{f}{4}(:,1)]; 
    sig_tmp = [sig_tmp; Cf{f}{4}(:,3)];
end

[meas_names_files,m_idx_unique] = unique(meas_names_files_test,'stable');
% [meas_names_files,m_idx] = meas_names_files_test; % updated 12.11.20 for paper4_classification (4x 'cafpas')

dist_type = dist_type_all(m_idx_unique); 
 
if num_files == 3 % because in old files distributions were named differently - not needed anymore in the future 
    dist_type{13} = 'beta'; 
    dist_type{14} = 'cat'; 
end

m_idx_diff = unique(meas_idx,'stable'); 
if length(meas_names_files) == 1 && length(m_idx_diff) > 1 % new 12.11.2020: needed for paper4_classification where 4 times 'cafpas' are classified
    num_datasets = length(m_idx_diff); 
    dist_type = repmat(dist_type,1,4); 
else
    num_datasets = length(meas_names_files);
end

for m = 1:num_datasets
    num_params(m) = sum(meas_idx==m)/num_cats;
    mu{m} = reshape(mu_tmp(meas_idx==m),num_cats,num_params(m))';  
    sig{m} = reshape(sig_tmp(meas_idx==m),num_cats,num_params(m))';  
end
 
 
end
