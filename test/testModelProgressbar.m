classdef testModelProgressbar < matlab.unittest.TestCase
    %TESTMODELPROGRESSBAR test the progressbar.ModelProgressbar class
    %
    % Author:  Haowen Yao <haowen.yao AT tum.de>
    properties
        progressbarModel
    end
    
    methods(TestMethodSetup)
        function modelSetup(testCase)
            testCase.progressbarModel = progressbar.ModelProgressbar();
        end
    end
    
    methods(Test)
        function singleLevelTest(testCase)
            level1Max = 5;
            testCase.progressbarModel.set(1, level1Max, 'Level 1');
            [value, maximum, description] = testCase.progressbarModel.get(1);
            testCase.verifyEqual(value, uint32(0))
            testCase.verifyEqual(maximum, uint32(level1Max))
            testCase.verifyEqual(description,'Level 1')
            testCase.verifyEqual(testCase.progressbarModel.maxLevel(), 1)
            
            level1State = 3;
            testCase.progressbarModel.update(1, level1State, '');
            [value, maximum, description] = testCase.progressbarModel.get(1);
            testCase.verifyEqual(value, uint32(level1State))
            testCase.verifyEqual(maximum, uint32(level1Max))
            testCase.verifyEqual(description,'Level 1')
            testCase.verifyEqual(testCase.progressbarModel.maxLevel(), 1)

            level1State = 5;
            testCase.progressbarModel.update(1, level1State, "Level 1-2");
            [value, maximum, description] = testCase.progressbarModel.get(1);
            testCase.verifyEqual(value, uint32(level1State))
            testCase.verifyEqual(maximum, uint32(level1Max))
            testCase.verifyEqual(description,'Level 1-2')
            testCase.verifyEqual(testCase.progressbarModel.maxLevel(), 1)

            testCase.progressbarModel.remove(1);
            testCase.verifyEqual(testCase.progressbarModel.maxLevel(), 0)
        end

        function multipleLevelTest(testCase)
            level1Max = 5;
            level2Max = 3;
            testCase.progressbarModel.set(1, level1Max, 'Level 1');
            testCase.verifyEqual(testCase.progressbarModel.maxLevel(), 1)
            testCase.progressbarModel.set(2, level2Max, "Level 2");
            testCase.verifyEqual(testCase.progressbarModel.maxLevel(), 2)
            
            [value, maximum, description] = testCase.progressbarModel.get(1);
            testCase.verifyEqual(value, uint32(0))
            testCase.verifyEqual(maximum, uint32(level1Max))
            testCase.verifyEqual(description,'Level 1')
            [value, maximum, description] = testCase.progressbarModel.get(2);
            testCase.verifyEqual(value, uint32(0))
            testCase.verifyEqual(maximum, uint32(level2Max))
            testCase.verifyEqual(description,'Level 2')

            level1State = 3;
            level2State = 2;
            testCase.progressbarModel.update(1, level1State, '');
            testCase.progressbarModel.update(2, level2State, '');
            testCase.verifyEqual(testCase.progressbarModel.maxLevel(), 2)

            [value, maximum, description] = testCase.progressbarModel.get(1);
            testCase.verifyEqual(value, uint32(level1State))
            testCase.verifyEqual(maximum, uint32(level1Max))
            testCase.verifyEqual(description,'Level 1')
            [value, maximum, description] = testCase.progressbarModel.get(2);
            testCase.verifyEqual(value, uint32(level2State))
            testCase.verifyEqual(maximum, uint32(level2Max))
            testCase.verifyEqual(description,'Level 2')
            testCase.verifyEqual(testCase.progressbarModel.maxLevel(), 2)

            testCase.progressbarModel.remove(2);
            testCase.verifyEqual(testCase.progressbarModel.maxLevel(), 1)
            [value, maximum, description] = testCase.progressbarModel.get(1);
            testCase.verifyEqual(value, uint32(level1State))
            testCase.verifyEqual(maximum, uint32(level1Max))
            testCase.verifyEqual(description,'Level 1')
        end

        function errorTest(testCase)
            level1Max = 5;
            testCase.verifyError(@() testCase.progressbarModel.get(1),'MATLAB:badsubscript')
            testCase.progressbarModel.set(1, level1Max, 'Level 1');
            testCase.verifyError(@() testCase.progressbarModel.get(2),'MATLAB:badsubscript')
            testCase.verifyError(@() testCase.progressbarModel.update(2, 5, 'Level 2'),'MATLAB:badsubscript')
            testCase.progressbarModel.remove(1);
            testCase.verifyError(@() testCase.progressbarModel.get(1),'MATLAB:badsubscript')
        end
    end
    
end