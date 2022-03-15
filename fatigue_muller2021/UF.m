function [uf] = UF(ufprev, e, theta)
% Unrecoverable fatigue level
%   Inputs:
%       ufprev: prior unrecoverable fatigue level
%       e: effort
%       theta: scaling factor on effort
%   Outputs:
%       uf: unrecoverable fatigue level

    uf = ufprev + (theta*e);

end

