x= -10:0.5:10;
f1=(x+2).^2 - 10;
f2 =(x-2).^2 + 20;
plot(x,f1);hold on;
plot(x,f2,'r'); grid on;
title('(x+2)^2-10 and(x-2)^2 + 20');