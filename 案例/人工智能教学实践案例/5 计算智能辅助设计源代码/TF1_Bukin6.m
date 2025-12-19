

function [ydata] = TF1_Bukin6(xdata)

% /*M-FILE Function TF1_Bukin6 MMM SwarmsLAB */ %
% /*==================================================================================================
%  Swarm Optimisation and Algorithm Laboratory Toolbox for MATLAB
%
%  Copyright 2016 The SxLAB Family - Yi Chen - leo.chen.yi@live.co.uk
% ====================================================================================================
% File description:
% The Sphere function has d local minima except for the global one. It is continuous, convex and unimodal. The plot shows its two-dimensional form. 
%
% INPUT:
%
% xdata = [x1, x2, ..., xd]
%
%
%Input:
% The function is usually evaluated on the hypercube xi in [-5.12, 5.12], 
%  for all i = 1, бн, d. 
% 
% 
%Output:     status   0 - ok
%                    !0 - fail
%
% Example 1 :
%      step    = 0.1;
%      xdata   = -10: step: 10;
%      [ydata] = TF1_Bukin6(xdata)
% 
% Example 2 :
%      xdata   = [1 2 3];
%      [ydata] = TF1_Bukin6(xdata)
% 
%Appendix comments:
%
%Usage:
%
%===================================================================================================
%  See Also:
%
%===================================================================================================
%===================================================================================================
%Revision -
%Date          Name     Description of Change  email
%06-Oct-2014   Chen Yi  Initial version        leo.chen.yi@live.co.uk
%HISTORY$
%==================================================================================================*/
%==================================================================================================*/

% TF1_Bukin6 Begin

x1 = xdata(1);
x2 = xdata(2);

term1 = 100 * sqrt(abs(x2 - 0.01*x1^2));
term2 = 0.01 * abs(x1+10);

ydata = term1 + term2;

end


% TF1_Bukin6 End