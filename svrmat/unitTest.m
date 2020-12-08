classdef unitTest < matlab.unittest.TestCase
    methods(Test)
        function testTrainGaussianKernelWithoutAutoHyper(testCase)
            [dates, y, fxpr, Bestmse] = train_svr('wig20_d.csv', 100, 'unitTesting',false,...
                'gaussian',1,0.1,8, 8, false);
            testCase.verifyNotEmpty(dates);
            testCase.verifyNotEmpty(y);
            testCase.verifyNotEmpty(fxpr);
            testCase.verifyNotEmpty(Bestmse);
        end
        function testTrainGaussianKernelWithAutoHyper(testCase)
            [dates, y, fxpr, Bestmse] = train_svr('wig20_d.csv', 100, 'unitTesting',true,...
                'gaussian',1,0.1,8, 8, false);
            testCase.verifyNotEmpty(dates);
            testCase.verifyNotEmpty(y);
            testCase.verifyNotEmpty(fxpr);
            testCase.verifyNotEmpty(Bestmse);
        end
        function testPredictionGaussianKernel(testCase)
            [datespr, ypr, rst,errors,mse,Mape] = predict_svr('wig20_d.csv','./models/unitTesting',5, false);
            testCase.verifyNotEmpty(datespr);
            testCase.verifyNotEmpty(ypr);
            testCase.verifyNotEmpty(rst);
            testCase.verifyNotEmpty(errors);
            testCase.verifyNotEmpty(mse);
            testCase.verifyNotEmpty(Mape);
        end
        function testTrainLinearKernelWithoutAutoHyper(testCase)
            [dates, y, fxpr, Bestmse] = train_svr('wig20_d.csv', 100, 'unitTesting',false,...
                'linear',1,0.1,8, 8, false);
            testCase.verifyNotEmpty(dates);
            testCase.verifyNotEmpty(y);
            testCase.verifyNotEmpty(fxpr);
            testCase.verifyNotEmpty(Bestmse);
        end
        function testTrainLinearnKernelWithAutoHyper(testCase)
            [dates, y, fxpr, Bestmse] = train_svr('wig20_d.csv', 100, 'unitTesting',true,...
                'linear',1,0.1,8, 8, false);
            testCase.verifyNotEmpty(dates);
            testCase.verifyNotEmpty(y);
            testCase.verifyNotEmpty(fxpr);
            testCase.verifyNotEmpty(Bestmse);
        end
        function testPredictionLinearKernel(testCase)
            [datespr, ypr, rst,errors,mse,Mape] = predict_svr('wig20_d.csv','./models/unitTesting',5, false);
            testCase.verifyNotEmpty(datespr);
            testCase.verifyNotEmpty(ypr);
            testCase.verifyNotEmpty(rst);
            testCase.verifyNotEmpty(errors);
            testCase.verifyNotEmpty(mse);
            testCase.verifyNotEmpty(Mape);
        end
        function testRMSE(testCase)
            At = [10,20,50];
            Ft = [9,22,33];
            rmse = RMSE(At, Ft);
            testCase.verifyEqual(9.90, round(rmse*100)/100);
        end
        function testMAPE(testCase)
            At = [10,20,50];
            Ft = [9,22,33];
            mapeResult = mape(At, Ft,3);
            testCase.verifyEqual(6.67, round(mapeResult*100)/100);
        end
    end
end