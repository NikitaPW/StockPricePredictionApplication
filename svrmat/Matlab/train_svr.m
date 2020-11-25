function [dates, y, fxpr, Bestmse] = train_svr(dtname, maxItr, file_name,isAutoHyper,...
    kernelFunctionName,MaxEvalNum,epsilon,loopMaxKernelScale, loopMaxBoxConstraint)
% train_svr("C:\Users\lombster\Desktop\matlab\myversion\WIG20_TRAIN.csv", 10)
            
data = readtable(dtname,'Format','%{yyyy-MM-dd}D%d%d%d%d%d');
N=height(data);
if isAutoHyper
    trainingPoints = N - 5;
else
    if N <= 35 
       trainingPoints = N - 6;
       testingPoints = 4;
    elseif N <= 95
       trainingPoints = N - 15;
       testingPoints = 10;
    else
       trainingPoints = N - 15;
       testingPoints = 10;
    end
    xpr = double(data{trainingPoints + 1:trainingPoints + testingPoints,2});
    ypr = double(data{trainingPoints + 1:trainingPoints + testingPoints,5});
    datespr = data{trainingPoints + 1:trainingPoints + testingPoints,1};

end

x = double(data{1:trainingPoints,2});
y = double(data{1:trainingPoints,5});
dates = data{1:trainingPoints,1};

% Algorithm
if (isAutoHyper == true) %Using matlab cross validation
    BestMdl = fitrsvm(x,y,'KernelFunction',kernelFunctionName,'OptimizeHyperparameters','all',...
        'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
        'expected-improvement-plus', 'MaxObjectiveEvaluations', MaxEvalNum),...
        'IterationLimit',maxItr);
    fxpr = predict(BestMdl, x);
    Bestmse = norm(y-fxpr)^2/N;
else % iterate through and check best parameters
    %    Matlab          sklearn.svm.SVR 
    %KernelScale   -        gamma
    %BoxConstraint -          C
    BestKernelScale = 1e-9; %for debug
    KernelScale = 1e-9;
    BoxConstraint = 1;
    BestBoxConstraint = 1;%for debug
    loopCountKernelScale = 1;
    loopCountBoxConstraint = 1;
    Mdl = fitrsvm(x,y,'KernelFunction',kernelFunctionName,...
        'IterationLimit',maxItr,'Epsilon', epsilon,'Standardize',true);
    BestMdl = Mdl;
    fxpr = predict(Mdl, xpr);
    Bestmse = norm(ypr-fxpr)^2/testingPoints; %mean sq error
    while loopCountBoxConstraint <= loopMaxBoxConstraint
        while loopCountKernelScale <= loopMaxKernelScale
            Mdl = fitrsvm(x,y,'KernelFunction',kernelFunctionName,...
                'IterationLimit',maxItr,'BoxConstraint', BoxConstraint,...
                'KernelScale', KernelScale, 'Epsilon', epsilon,'Standardize',true);
            fxpr = predict(Mdl, xpr);
            mse = norm(ypr-fxpr)^2/testingPoints;
            mapeError = mape(ypr,fxpr,testingPoints);
            if (Bestmse > mse)
                BestMapeError = mapeError;
                BestMdl = Mdl;
                BestKernelScale = KernelScale; 
                BestBoxConstraint = BoxConstraint;
                Bestmse = mse;
            end
            loopCountKernelScale = loopCountKernelScale + 1;
            KernelScale = KernelScale * 10;
        end %while loopCountKernelScale
        KernelScale = 1e-9;
        loopCountKernelScale = 0;
        loopCountBoxConstraint = loopCountBoxConstraint + 1;
        BoxConstraint = BoxConstraint * 10;
    end %while loopCountBoxConstraint
    
end
if (isAutoHyper == true)
    fxpr = predict(BestMdl, x);
else
    fxpr = [predict(BestMdl, x);predict(BestMdl, xpr)];
    y = [y;ypr];
    dates = [dates;datespr];
end

Mdl = BestMdl;

%disp('finished')
save ("models/" + file_name,"Mdl");
end