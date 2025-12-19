x1=-3:0.05:12.1;x2=4.1:0.05:5.8;
[x,Y]=meshgrid(x1,x2);
z=SGA_FITNESS_function(x,Y);
mesh(x1,x2,z)