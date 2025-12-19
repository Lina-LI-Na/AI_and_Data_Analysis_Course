%% PIO4SOL_COMP
% This script compares the performance of pio4, pio4_pa, and pio4_vec.

% Warning
disp("(This computation could take some time...)")

% Size of the series.  Adjust it if your computer is too slow/fast.
n=1e7;

% Time the execution.
tic; pio4sol(n); toc1=toc;
tic; pio4sol_pa(n); toc2=toc;
tic; pio4sol_vec(n); toc3=toc;

% Display the results.
disp("Time spent on each function:")

fprintf("pio4sol(%d):     %9.6f\n", n, toc1);
fprintf("pio4sol_pa(%d):  %9.6f\n", n, toc2);
fprintf("pio4sol_vec(%d): %9.6f\n", n, toc3);

% Comparison.
fprintf("\n")
fprintf("pio4sol is %.1f%% slower than pio4sol_pa.\n",...
    100*(toc1-toc2)/toc2);
fprintf("pio4sol_pa is %.1f%% slower than pio4sol_vec.\n\n",...
    100*(toc2-toc3)/toc3);
