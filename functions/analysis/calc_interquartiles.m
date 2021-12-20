% function calc_interquartiles(data_vec)
% 
% v1, MB 04.06.18 
%
% fixme: funktioniert nicht auf Laptop, gibt dort verschieden viele Werte
% f�r P50, p25 und p75 aus ... 


function [p25, p50, p75] = calc_interquartiles(data_vec)
% data_vec = data_vec'; % laptop - no omitnan property in matlab R2011a,
% auch nicht in octave 
% matlab function prctile does the same - available in octave? 
data_vec = data_vec(~isnan(data_vec)); 

p50 = median(data_vec); %,'omitnan'); 

data_sorted = sort(data_vec); 
p25 = median(data_sorted(1:ceil(length(data_vec)/2))); %'omitnan'); 
p75 = median(data_sorted(ceil((length(data_vec)+1)/2):end)); %,'omitnan'); 

% p25 = median(data_vec(data_vec<=p50),'omitnan'); % ungenau, wenn median mehrfach vorkommt 
% p75 = median(data_vec(data_vec>=p50),'omitnan'); 
end 