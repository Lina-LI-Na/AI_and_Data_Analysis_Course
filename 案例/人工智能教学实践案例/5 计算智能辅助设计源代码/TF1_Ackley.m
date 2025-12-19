function [ydata] = TF1_Ackley(xdata,a, b, c )

% /*M-FILE Function TF1_Ackley MMM SwarmsLAB */ %
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
%  for all i = 1, ¡­, d.
%
%
%Output:
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
%==========================================================================
%========================*/

d = length(xdata);

if (nargin < 4)
    c = 2*pi;
end
if (nargin < 3)
    b = 0.2;
end
if (nargin < 2)
    a = 20;
end

sum1 = 0;
sum2 = 0;

for ind = 1:1:d
    xi = xdata(ind);
    sum1 = sum1 + xi^2;
    sum2 = sum2 + cos(c*xi);
end

term1 = -a * exp(-b*sqrt(sum1/d));

term2 = -exp(sum2/d);

ydata = term1 + term2 + a + exp(1);

end

