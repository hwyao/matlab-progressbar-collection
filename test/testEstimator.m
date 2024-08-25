classdef testEstimator < matlab.unittest.TestCase
    %TESTESTIMATOR test the ETAEstimator
    %
    % Author:  Haowen Yao <haowen.yao AT tum.de> 
    methods(Test)
        function EstTest1(testCase)
            est = ETAEstimator.Estimator(5);

            [H, M, S] = est.estimate(0.1);
            testCase.verifyEqual(H, 0)
            testCase.verifyEqual(M, 0)
            testCase.verifyEqual(S, 0)

            pause(0.1);
            [H, M, S] = est.estimate(0.2);
            testCase.verifyEqual(H, 0)
            testCase.verifyEqual(M, 0)
            testCase.verifyEqual(S, 0)

            pause(0.1);
            [H, M, S] = est.estimate(0.3);
            testCase.verifyEqual(H, 0)
            testCase.verifyEqual(M, 0)
            testCase.verifyEqual(S, 0)

            pause(0.1);
            [H, M, S] = est.estimate(0.4);
            testCase.verifyEqual(H, 0)
            testCase.verifyEqual(M, 0)
            testCase.verifyEqual(S, 0)

            pause(0.1);
            [H, M, S] = est.estimate(0.5);
            testCase.verifyGreaterThan(3600*H + 60*M + S, 0)
            H_mid = H;
            M_mid = M;
            S_mid = S;

            pause(0.1);
            [H, M, S] = est.estimate(0.6);
            testCase.verifyEqual(H, H_mid)
            testCase.verifyEqual(M, M_mid)
            testCase.verifyEqual(S, S_mid)

            pause(0.1);
            [H, M, S] = est.estimate(0.7);
            testCase.verifyEqual(H, H_mid)
            testCase.verifyEqual(M, M_mid)
            testCase.verifyEqual(S, S_mid)

            pause(0.1);
            [H, M, S] = est.estimate(0.8);
            testCase.verifyEqual(H, H_mid)
            testCase.verifyEqual(M, M_mid)
            testCase.verifyEqual(S, S_mid)

            pause(0.1);
            [H, M, S] = est.estimate(0.9);
            testCase.verifyEqual(H, H_mid)
            testCase.verifyEqual(M, M_mid)
            testCase.verifyEqual(S, S_mid)

            pause(0.1);
            [H, M, S] = est.estimate(1.0);
            testCase.verifyGreaterThan(3600*H_mid + 60*M_mid + S_mid, 3600*H + 60*M + S)
        end

        function EstTest2(testCase)
            est = ETAEstimator.Estimator(3, 0.8);
            
            [H, M, S] = est.estimate(0.1);
            testCase.verifyEqual(H, 0)
            testCase.verifyEqual(M, 0)
            testCase.verifyEqual(S, 0)

            pause(0.1);
            [H, M, S] = est.estimate(0.2);
            testCase.verifyEqual(H, 0)
            testCase.verifyEqual(M, 0)
            testCase.verifyEqual(S, 0)

            pause(0.1);
            [H, M, S] = est.estimate(0.3);
            testCase.verifyGreaterThan(3600*H + 60*M + S, 0)
            H_mid = H;
            M_mid = M;
            S_mid = S;

            pause(0.1);
            [H, M, S] = est.estimate(0.4);
            testCase.verifyEqual(H, H_mid)
            testCase.verifyEqual(M, M_mid)
            testCase.verifyEqual(S, S_mid)

            pause(0.1);
            [H, M, S] = est.estimate(0.5);
            testCase.verifyEqual(H, H_mid)
            testCase.verifyEqual(M, M_mid)
            testCase.verifyEqual(S, S_mid)

            pause(0.1);
            [H, M, S] = est.estimate(0.6);
            testCase.verifyGreaterThan(3600*H_mid + 60*M_mid + S_mid, 3600*H + 60*M + S)
        end

        function EstTestError(testCase)
            testCase.verifyError(@() ETAEstimator.Estimator(0),"MATLAB:validators:mustBePositive")
            testCase.verifyError(@() ETAEstimator.Estimator(1,0),"MATLAB:validators:mustBeGreaterThan")
            testCase.verifyError(@() ETAEstimator.Estimator(1,1),"MATLAB:validators:mustBeLessThan")
        end
    end
end

