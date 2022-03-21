function [J] = utility(T)
% Utility of a movement
%   Detailed explanation goes here

    global param
    
    e = Er(T, param.myeffscale*param.mya, param.myb); % effort
    sv = rwd(param.r, T, param.myc0, param.myc1); % reward
    fat = param.rfprev + param.ufprev;
    if fat == 0
       fat = 1; 
    end

    J = -(sv.*(1/(param.k.*fat)) ...
        - e.*(fat.*param.k))...
        /(T);
end

