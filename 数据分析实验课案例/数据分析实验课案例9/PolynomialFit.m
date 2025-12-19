clear;
clc;

x = 1:100; 
y = -0.3*x + 2*randn(1,100); 
[p,S] = polyfit(x,y,1); 
[y_fit,delta] = polyval(p,x,S);
plot(x,y,'bo')
hold on
plot(x,y_fit,'r-')
plot(x,y_fit+2*delta,'m--',x,y_fit-2*delta,'m--')
title('Linear Fit of Data with 95% Prediction Interval')
legend('Data','Linear Fit','95% Prediction Interval')