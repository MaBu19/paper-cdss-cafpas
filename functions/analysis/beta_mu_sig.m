% calculate expectation value mu and variance sig2 from beta distributiion parameters a and b 
% 
% v1, MB 18.06.19 
% according to Hedderich 2018: Angewandte Statistik, p. 259ff.
% 
% INPUT:
% a, b      parameters of beta distribution
% 
% OUTPUT: 
% mu        expectation value
% sig       standard deviation (sqrt(sig2))
% 
% for inverse transformation use beta_a_b.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mu,sig] = beta_mu_sig(a,b) 

mu = a/(a+b); 
sig = sqrt((a*b)/(power(a+b,2)*(a+b+1))); 

end 