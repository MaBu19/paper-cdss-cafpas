% function sorts audiogram matrices such that only the better or worse ear
% is included, respectively 
% 
% v1, MB 11.12.18 
% 
% INPUT: 
% AG_le 
% AG_ri 
% 
% OUTPUT: 
% AG_worse
% AG_better
% ear_idx   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AG_worse, AG_better, ear_idx] = sort_data_left_right(AG_le,AG_ri)

freqs = [0.125 0.25 0.5 0.75 1 1.5 2 3 4 6 8]; % could be loaded/input variable if other specific frequencies for audiogram are available in another data set 
ear_idx = zeros(size(AG_le,1),1); 
for k = 1:size(AG_le,1) 
    pta_le(k) = calc_PTA(AG_le(k,:),freqs); 
    pta_ri(k) = calc_PTA(AG_ri(k,:),freqs); 

    if pta_le(k)>=pta_ri(k)
        ear_idx(k) = 1; % higher PTA left ear (or left and right equal - doesn't matter which data is used in this case)  
    elseif pta_le(k)<pta_ri(k)
        ear_idx(k) = 2; % higher PTA right ear 
    end
    
    if ear_idx(k) == 0 
        if ~isnan(pta_le(k)) && isnan(pta_ri(k))
            ear_idx(k) = 1; % use left AG if only left is available 
        elseif isnan(pta_le(k)) && ~isnan(pta_ri(k)) %205
            ear_idx(k) = 2; % % use right AG if only right is available 
            
        elseif isnan(pta_le(k)) && isnan(pta_ri(k)) %12,24,122
%             disp(['no ags for left and right - ' num2str(k)]); % maintain ear_idx(k) = 0 / corresponds to cases where AG_le/ri_idx = 0 
        end
    end
end

% disp([' Use ' num2str(length(find(ear_idx==1))) ' left and ' num2str(length(find(ear_idx==2))) ' right audiograms' ]); 

%% combine matrix of worst audiogram according to ear_idx 

AG_worse = zeros(size(AG_le)); 
AG_worse(ear_idx==1,:) = AG_le(ear_idx==1,:); 
AG_worse(ear_idx==2,:) = AG_ri(ear_idx==2,:); 

% ... and the opposite: audiogram for better ear of each patient (not used
% so far)
AG_better = zeros(size(AG_le)); 
AG_better(ear_idx==2,:) = AG_le(ear_idx==2,:); 
AG_better(ear_idx==1,:) = AG_ri(ear_idx==1,:); 

end
