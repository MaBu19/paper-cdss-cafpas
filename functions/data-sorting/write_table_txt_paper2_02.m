% function writes all parameters determined in paper2_02_distributions into
% txt file 
% 
% v1, MB 18.06.19 
% v2, MB 15.09.20 - removed d dependency
% 
% INPUT: 
% 
% OUTPUT: 
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_table_txt_paper2_02(table_folder,input_names,num_params,filter_crit,single_flag,plot_header,dist_type,cv_flag,log_norm_flag,mu,sig,weight,log_cat,log_sum,num_data)

% definitions: 
tick_mode_expl = {'multiple ticks...','single ticks','exact choice of categories'}; % see description "single" and "joint", Buhl et al. (2020a)

filename = [filter_crit '_' strrep(strjoin(plot_header),' ','-') '_' strrep(strjoin(unique(dist_type)),' ','-') '_' strrep(strjoin(input_names),' ','-') '_tick' num2str(single_flag) '-lognorm' num2str(log_norm_flag) '-cv' num2str(cv_flag)]; %  '-' date 
fileID = fopen([table_folder filesep filename '.txt'],'w'); 

% header of txt file: 
fprintf(fileID,'%12s \n','# Results for training distributions calculated by paper2_02_distributions.m');
fprintf(fileID,'%12s \n','# --> table in appendix of paper2');
fprintf(fileID,'# \n'); 
fprintf(fileID,'%12s \n',['# Date: ' date]); 
fprintf(fileID,'# \n');
fprintf(fileID,'%12s \n',['# Comparison of categories: ' strrep(strjoin(plot_header),' ',',') ' (' filter_crit ')']); 
fprintf(fileID,'%12s \n',['# Tick mode: ' num2str(single_flag) ' (' tick_mode_expl{1+single_flag} ')' ]);  
fprintf(fileID,'%12s \n',['# Log-likelihood normalization: ' num2str(log_norm_flag)]);  
fprintf(fileID,'%12s \n',['# Cross validation: ' num2str(cv_flag)]);  

% data tables
fprintf(fileID,'# \n');
for m = 1:length(input_names)
    
    fprintf(fileID,'%12s \n',['# m = ' num2str(m) ': ' input_names{m} ' (N_m = ' num2str(max(sum(num_data{m},3))) ')']);
    switch input_names{m}
        case {'ag_ac','ag_bc'}
            params = {'0.125','0.25','0.5','0.75','1','1.5','2','3','4','6','8'};
        case 'cafpas'
            params = {'CA1','CA2','CA3','CA4','CU1','CU2','CB','CN','CC','CE'};
        case {'acalos_1_5','acalos_4'}
            params = {'Lcut','mlow','mhigh','L2.5','L25','L50'};
        case {'swi_sum','goesa','earnoise','hp_quiet','hp_noise','wst_raw','demtect', 'age'} % measures with only one parameter/measurement
            params = {input_names{m}};
    end
    
    for num_p = 1:num_params(m)
        fprintf(fileID,'# \n');
        fprintf(fileID,'%12s \n',['# Parameter ' num2str(num_p) ' ' params{num_p}]);
        
        
        
        fprintf(fileID,'# %12s %12s %12s %12s %12s %12s %12s %12s %12s %12s %12s %12s %12s\n','m','meas','dist','category','N','mu','mu2','sig','sig2','w','w2','logcat','logsum');
        
        for c = 1:length(plot_header)
            if size(mu{m},4) == 2
                mu2tmp = mu{m}(1,num_p,c,2);
                sig2tmp = sig{m}(1,num_p,c,2);
                w2tmp = weight{m}(1,num_p,c,2);
                fmt2 = '%12.3f';
            else
                mu2tmp = 'nan';
                sig2tmp = 'nan';
                w2tmp = 'nan';
                fmt2 = '%12s';
            end
            fprintf(fileID,['%12i %12s %12s %12s %12i %12.3f ' fmt2 ' %12.3f ' fmt2 ' %12.3f ' fmt2 ' %12.2f %12.2f \n'],m,input_names{m},dist_type{m},plot_header{c},num_data{m}(1,num_p,c),mu{m}(1,num_p,c,1),mu2tmp,sig{m}(1,num_p,c,1),sig2tmp,weight{m}(1,num_p,c,1),w2tmp,log_cat{m}(1,num_p,c),log_sum{m}(1,num_p)); % mu: m; k,num_p,c,dim
        end
        
        
    end
    fprintf(fileID,'\n');
end

fclose(fileID);

end


