function [e] = Er(T, a, b)
% Effort of given reach
%   Inputs: 
%       T: reach duration
%       a: effort offset of reaching
%       b: effort numerator (can include effects of distance)
%   Outputs:
%       e: met cost of a reach

    e = (a.*T + b./(T)); %reaching cost, basically normal effort cost (no distance, mass, etc.)
 
end

