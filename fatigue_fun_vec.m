function [J] = fatigue_fun_vec(x)
% mymTtfun function 
%   Calculates utility/fatigue with a given movement time (T)
%   Used in conjunction with mTt models loop 
%   Being used in fminsearch()

global param
    for i = 1:length(x)
        %alpha, c0, c1, c0to, c1to, ao, a, b
        Er=@(T,a,b) (a.*T + b./(T)); %reaching cost, basically normal effort cost (no distance, mass, etc.)
        Pr=@(T,c0,c1) (1./(1 + exp(-c0 - c1.*T))); %Probability of reward as a function of reach time (T)
        F = @(Er,alpha,beta,gamma) (beta.*Er - gamma.*alpha);

        T=x(i); % MT
    
        % Orignial Utility
%         J(i) = -((param.myalphascale * param.myalpha)...
%              - Er(T, param.myeffscale * param.mya, param.myeffscale * param.myb))/(1+param.gamma*T);
%          
%         % Probability Utility
%         J(i) = -((param.myalphascale * param.myalpha * Pr(T,param.myprobscale*param.myc0, param.myc1))...
%              - Er(T, param.myeffscale * param.mya, param.myeffscale * param.myb))/(1+param.gamma*T);
%          
        % Make negative since we are really after maximum, but will be minimizing this function
%         J(i)=-(param.myalphascale * param.myalpha * Pr(T,param.myprobscale*param.myc0,param.myc1)...
%              - Er(T, param.myeffscale * param.mya, param.myeffscale * param.myb))/...
%              (T+F(Er(T, param.myeffscale * param.mya, param.myeffscale * param.myb),param.myalpha,param.beta,param.gamma));
         
        J(i)=(F(Er(T, param.myeffscale * param.mya, param.myeffscale * param.myb),...
                param.myalpha,param.beta,param.gamma))/T;

         %F(Er(T, param.myeffscale * param.mya, param.myeffscale * param.myb),param.myalpha,param.beta,param.gamma)
    end
end

