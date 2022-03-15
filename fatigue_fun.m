function J = fatigue_fun(x)
% mymTtfun function 
%   Calculates utility/fatigue with a given movement time (T)
%   Used in conjunction with mTt models loop 
%   Being used in fminsearch()

global param

%alpha, c0, c1, c0to, c1to, ao, a, b
Er=@(T,a,b) (a*T + b./(T)); %reaching cost, basically normal effort cost (no distance, mass, etc.)
Pr=@(T,c0,c1) (1./(1 + exp(-c0 - c1*T))); %Probability of reward as a function of reach time (T)

T=x(1); % MT

% Orignial Utility
% Make negative since we are really after maximum, but will be minimizing this function
J=-(param.myalphascale * param.myalpha * Pr(T,param.myprobscale*param.myc0,param.myc1)...
    - Eo(To, param.myao) - Er(T, param.myeffscale * param.mya, param.myeffscale * param.myb))/(T);

end

