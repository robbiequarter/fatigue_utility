function [rf] = RF(rfprev, dec, e, Trest, alpha, delta)
% Recoverable fatigue level
%   Inputs:
%       rfprev: prior recoverable fatigue
%       dec: decision (binary) to work or rest
%       e: effort of task if decision is to work (dec = 1)
%       Trest: resting time if decision is to rest (dec = 0)
%       alpha: work parameter that scales effort
%       delta: rest parameter that scales recovery from rest
%   Outputs:
%       rf: recoverable fatigue. Increases or decreases depending on
%       decision to work or rest
    if dec ~= 1 % decision is to rest
        rf = rfprev - (delta*Trest); % i.e. RF state decreases
        
    elseif dec == 1 % decision is to work
        rf = rfprev + (alpha*e); % i.e. RF state increases
        
    end

end

