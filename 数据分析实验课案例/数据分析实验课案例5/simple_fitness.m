function k = simple_fitness(x,y) 
k = log(1 + 100*(x.^2 - y)^2 + (1 - x).^2)
end