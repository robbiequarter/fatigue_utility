function [rf, uf, fat] = fatigue_fun(rfprev, ufprev, e, rwd, alpha, delta, theta)
% Fatigue update function  
%   Inputs:
%   Outputs:

    global param
    
    if alpha*e >= delta*rwd
        rf = rfprev + (alpha*e);
    else
        rf = rfprev  - (delta*rwd);
    end
%     rf = rfprev + ((alpha*e) - (delta*rwd));

    uf = ufprev + ((theta*e));
    
    fat = 1/(1 + param.beta*(rf+uf));

end

