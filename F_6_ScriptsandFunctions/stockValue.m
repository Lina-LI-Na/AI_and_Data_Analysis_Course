function v = stockValue(StockData, stockID)
   [rowNum, ~] = size(StockData);
   DateNum = (1:rowNum)';
  price = StockData(:,stockID);
  p = polyfit(DateNum,price,1);
  v = p(1);
end