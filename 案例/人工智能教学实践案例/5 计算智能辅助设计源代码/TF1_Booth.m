

function [ydata] = TF1_Booth(x1, x2)

term1 = (x1 + 2.*x2 - 7).^2;
term2 = (2.*x1 + x2 - 5).^2;

ydata = term1 + term2;

end

