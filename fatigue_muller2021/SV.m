function [sv] = SV(r, e, rf, uf, k)
% Fatigue-weighted subjective value of the task
%   Inputs:
%       r: reward
%       e: effort
%       rf: recoverable fatigue (from RF(t) function)
%       uf: unrecoverable fatigue (from UF(t) function)
%       k: static discounting paramter (subject-specific)
%   Outputs:
%       sv: subjective value of choosing to work
    
    sv = r - ((rf + uf)*k*e^2);

end

