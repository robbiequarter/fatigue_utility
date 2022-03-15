function [pw] = softmaxP(sv, beta)
% Softmax function used to make decision to work or to rest
%   Inputs:
%       sv: subjective value (from SV(t) function)
%       beta: stochasticity of choices, shouldn't go below 0 (subject-specific)
%   Outputs:
%       pw: Probability individual selects the work option over the rest
%       option
    pw = (exp(sv*beta))/(exp(1*beta) + exp(sv*beta));
end

