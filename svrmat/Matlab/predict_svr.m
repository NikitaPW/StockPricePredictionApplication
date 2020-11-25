function [datespr, ypr, rst,errors,mse,Mape] = predict_svr(dtname,model,daysToPredict)
data = readtable(dtname,'Format','%{yyyy-MM-dd}D%d%d%d%d%d');

N=height(data);
predictPoints = daysToPredict;
shift = N - 5;

xpr = double(data{shift + 1:shift + predictPoints,2});
ypr = double(data{shift + 1:shift + predictPoints,5});
datespr = data{shift + 1:shift + predictPoints,1};

tst = zeros(1,daysToPredict);
rst = zeros(1,daysToPredict);
tst(1) = xpr(1); %assume that we know 1st Open Price 
i = 1; 
while (i < daysToPredict + 1)
    rst(i) =  predict(model, tst(i));
    i = i + 1;
    if (i ~= daysToPredict + 1)
        tst(i) = rst(i-1); %previous day close = new day open
    end
end

% Mean Square error (Gaussian Kernel)
mse = norm(ypr-rst)^2/daysToPredict;
i = 1;
errors = zeros(1, daysToPredict);
Mape = mape(ypr, rst, daysToPredict) * 100;
while i <= daysToPredict
    errors(i) = ((ypr(i)-rst(i))/(rst(i))) * 100;
    i = i + 1;
end

end