function [sv] = rwd(r, T, c0, c1)
% Subjective value of reward of a movement
%   Inputs:
%   Outputs: 
    
    Pr = @(T,c0,c1) (1./(1 + exp(-c0 - c1*T))); %Probability of reward as a function of reach time (T)

    sv = (r * Pr(T, c0, c1));
end

