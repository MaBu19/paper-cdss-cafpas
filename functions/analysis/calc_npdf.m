% calculate normalized probability density function 
%
% v2, MB 09.07.20: removed case 'manual' and dependency on input_names
% v1, MB 28.05.19
% 
% INPUT: 
% x         vector at which x positions the npdf function shall be
%           calculated
% p1        first parameter of distribution           
% p2        second parameter of distribution 
% stepsize  delta x - important for normalization 
% dist_type (varargin{1}) desired distribution function 
% 
% OUTPUT: 
% pdf_vec   npdf vector - can be plotted over x 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pdf_vec = calc_npdf(x,p1,p2,weight,stepsize,varargin)

if ~isempty(varargin)
    dist_type = varargin{1}; 
else 
    dist_type = 'gmm-1';
end
    

switch dist_type
    case {'gmm-1','gmm-2'}
        pdf_vec = gmm(weight,p1,p2,x);     % (stepsize again defined within gmm())    
        
    case 'beta' % beta distribution, for example for CAFPAs
        [p1,p2] = beta_a_b(p1,p2); % Input to betapdf needs to be a and b, p1 and p2 correspond to mu and sigma 
        pdf_vec = stepsize*betapdf(x,p1,p2);
                
        % change first or last sample of pdf_vec (linearly) if inf
        % (normalization)
        if isinf(pdf_vec(1))
            pdf_vec(1) = pdf_vec(2)+(pdf_vec(2)-pdf_vec(3));
        end
        if isinf(pdf_vec(end))
            pdf_vec(end) = pdf_vec(end-1)+(pdf_vec(end-1)-pdf_vec(end-2));
        end
    case 'cat' % categorical data
        pdf_vec = [p1,p2];
end

end