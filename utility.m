function [J] = utility(T)
% Utility of a movement
%   Detailed explanation goes here

    global param
    
%     e = Er(T, param.myeffscale*param.mya, param.myb); % effort
%     sv = rwd(param.r, T, param.myc0, param.myc1); % reward
%     fat = param.rfprev + param.ufprev;
%     if fat == 0
%        fat = 1; 
%     end
% 
%     J = -(sv.*(1/(param.k.*fat)) ...
%         - e.*(fat.*param.k))...
%         /(T);

    Er=@(T,a,b) (a.*T + b./(T)); %reaching cost, basically normal effort cost (no distance, mass, etc.)
    Pr=@(T,c0,c1) (1./(1 + exp(-c0 - c1*T))); %Probability of reward as a function of reach time (tr)
    
%     % Orignial Utility
%     J = -(param.r * Pr(T, param.myc0, param.myc1)...
%         - Er(T, param.mya, param.myb))...
%         /(T);
    

    % Fatigued Utility
    J = -((param.r * param.myrwdscale * Pr(T, param.myc0, param.myc1))...
        - (Er(T, param.mya * param.myeffscale, param.myb * param.myeffscale)))...
        /(T);
end

