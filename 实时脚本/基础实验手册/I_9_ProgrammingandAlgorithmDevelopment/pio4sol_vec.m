% PIO4SOL_VEC computes approximation to pi/4.
% [s,p] = pio4sol_vec(n)  computes n terms of series approximation to
% pi/4.  s is the series and p is the sum.

function [s,p]=pio4sol_vec(n)
% This function takes positive integer n as input and generates n terms of
% the series and the sum.  (See "Computing Pi/4" exercise in the text.)

n = n+1;  % Easiest approach to dealing with 0 index is just to add 1 to n
s = 1:2:(2*n-1);
s = 1./s;
% Flip the signs on alternating elements (faster than calculating (-1)^k)
s(2:2:n) = -s(2:2:n);

p = sum(s);