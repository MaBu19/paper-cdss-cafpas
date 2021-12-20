% calculate beta distributiion parameters a and b from expectation value mu and variance sig2  
% 
% v1, MB 18.06.19 
% according to Hedderich 2018: Angewandte Statistik, p. 259ff.
% 
% INPUT: 
% mu        expectation value
% sig       standard deviation (sqrt(sig2))
%
% OUTPUT:
% a, b      parameters of beta distribution
% 
% for inverse transformation use beta_mu_sig.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a,b] = beta_a_b(mu,sig) 

a = mu*((mu*(1-mu))/power(sig,2)-1); 
b = (1-mu)*((mu*(1-mu))/power(sig,2)-1);

end 