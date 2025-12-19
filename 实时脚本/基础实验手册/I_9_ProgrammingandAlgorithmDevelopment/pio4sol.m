% PIO4SOL   computes approximation to pi/4.
% [s,p] = pio4sol(n)  computes n terms of series approximation to
% pi/4.  s is the series and p is the sum.

function [s,p]=pio4sol(n)
% This function takes positive integer n as input and generates n terms of
% the series and the sum.  (See "Computing Pi/4" exercise in the text.)

for k=0:n
    s(k+1) = (-1)^k/(2*k+1);
end

p = sum(s);