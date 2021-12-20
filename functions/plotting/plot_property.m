% v1, MB 31.05.19
% v2, MB 15.09.20: changed output type from cell to data type of respective variable 


function value = plot_property(input_name, property)

switch input_name
    case 'cafpas'
        row = 1; 
    case 'ag_ac'
        row = 2; 
    case 'ag_bc'
        row = 3; 
    case {'acalos_1_5','acalos_4'}
        row = 4; 
    case 'swi_sum'
        row = 5; 
    case 'goesa'
        row = 6; 
    case 'earnoise'
        row = 7; 
    case {'hp_quiet','hp_noise'}
        row = 8; 
    case 'wst_raw'
        row = 9; 
    case 'demtect'
        row = 10; 
    case 'age'
        row = 11; 
    case 'ABG'
        row = 12; 
    
        
end

% input_names_all = {'cafpas','ag_ac','ag_bc','acalos_1_5','acalos_4','swi_sum','goesa','earnoise','hp_quiet','hp_noise','wst_raw','demtect', 'age' }; % ('gender','ha_use')


switch property     
    case 'xlabel'
        col = 1;
    case 'ylabel'
        col = 2; 
    case 'ylim'
        col = 3;
    case 'xticks'
        col = 4; 
    case 'reflines'
        col = 5; % x-positions of vertical reference lines that shall be displayed 
    case 'reflabels'
        col = 6; 
    case 'data_choice' 
        col = 7; %1: only lines, 2: lines and bars, 3: only bars (earnoise), 4: only bars (npdf)
        
end 

properties = {...
    'p_{CAFPA}'           	,'Probability density',  [0 0.02 0.15], [],[],{},1; ... % CAFPAs 
    'Hearing loss [dB HL]'  ,'Probability density',  [0 0.02 0.1], [] ,[],{},1; ... % ag_ac
    'Hearing loss [dB HL]'  ,'Probability density',  [0 0.02 0.1], [],[],{},1 ; ... % ag_bc 
    'Level [dB HL]'         ,'Probability density',  [0 0.02 0.08], [],[],{},1 ; ... % acalos
    'SWI score'             ,'Probability density',  [0 0.01 0.03], [],[7.5,14.5],{'lower class','middle class','upper class'},1 ; ... % swi
    'SRT [dB SNR]'          ,'Probability density',  [0 0.01 0.04], [],[-6.2],{'NH'},1 ; ... % goesa
    ''                      ,'Probability density',  [0 0.2 0.8], [0 1],[],{},3 ; ... % ear noise (not present/present)
    ''                      ,'Probability density',  [0 0.1 0.2], [],[],{},1 ; ... % hearing problems (subjective scale)
    'z-score'               ,'Probability density',  [0 0.01 0.07], [],[0],{'below average','above average'},1 ; ... % WST- z-score! 
    'DemTect score'         ,'Probability density',  [0 0.001 0.005], [],[8.5,12.5],{{'suspicion';'of dementia'},{'sl. imp.'; 'cognitive'; 'abilities'},{'normal cogni-';'tive abilities'}},1 ; ... % demtect
    'Age [years]'           ,'Probability density',  [0 0.1 0.1], [],[],{},1 ; ... % age
    'Air-bone gap [dB]'     ,'Probability density',  [0 0.1 0.1], [],[],{},1 ; ... % air-bone gap
    }; 




if ~isempty(input_name)
    value = properties{row,col}; % dann aber für alle anderen Variablen auch testen 
else 
    value = input_name; % give back same data type (still empty)
end

end 

