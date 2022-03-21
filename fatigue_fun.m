function [rf, uf] = fatigue_fun(rfprev, ufprev, e, rwd, alpha, delta, theta)
% Fatigue update function  
%   Inputs:
%   Outputs:

    rf = rfprev + (alpha*e) - (delta*rwd); % i.e. RF state 
    uf = ufprev + (theta*e) - (delta*rwd); % i.e. UF state 

end

