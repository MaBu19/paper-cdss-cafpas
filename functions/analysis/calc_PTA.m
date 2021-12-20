% function calc_PTA() calculates the PTA (mean of hearing thresholds at
% 0.5, 1, 2, and 4 kHz) 
% 
% v1, MB 20.08.18
%
% INPUT: 
% AG        audiogram vector
% freqs     frequency vector (same size as AG)
% 
% OUTPUT: 
% pta       PTA value
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pta = calc_PTA(AG,freqs)
pta = nan;  

ag_idx = []; 
for k = [0.5,1,2,4]
ag_idx = [ag_idx;find(freqs == k)];
end

tmp = AG(ag_idx); % octave 
tmp = tmp(~isnan(tmp)); 
if ~isempty(tmp)
    pta = mean(tmp);
end  

%pta = nanmean(AG(ag_idx)); % only in Matlab 

end
