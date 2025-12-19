clear;
clc;

data = readtable("fuelEconomy.txt");
nanIdx = ismissing(data.CombinedMPG);
data(nanIdx,:) = [];
MPGClass = discretize(data.CombinedMPG,[0 20 30 70],["Low" "Medium" "High"]);
MPGClass = categorical(MPGClass);
scatter(data.CityMPG(MPGClass == "Low"),data.HighwayMPG(MPGClass == "Low"),"r","filled")
hold on
scatter(data.CityMPG(MPGClass == "Medium"),data.HighwayMPG(MPGClass == "Medium"),"b","filled")
hold on
scatter(data.CityMPG(MPGClass == "High"),data.HighwayMPG(MPGClass == "High"),"k","filled")
hold off
grid on
xlabel("City MPG")
ylabel("Highway MPG")
legend("Low Combined MPG","Medium Combined MPG","High Combined MPG");