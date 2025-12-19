clear;
clc;

x = linspace(0,1,5);
y = 1./(1+x);
p = polyfit(x,y,4);
x1 = linspace(0,2);
y1 = 1./(1+x1);
f1 = polyval(p,x1);
figure
plot(x,y,'o')
hold on
plot(x1,y1)
plot(x1,f1,'r--')
legend('y','y1','f1')