x1=0:0.01:2;
x2=0:0.01:2;
[x,Y]=meshgrid(x1,x2);
z=simple_fitness(x,Y);
mesh(x1,x2,abs(z))