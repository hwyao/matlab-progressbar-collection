classdef testProgressbarCollection < matlab.unittest.TestCase
    %TESTPROGRESSBARCOLLECTION test the ProgressbarCollection class
    %
    % Author:  Haowen Yao <haowen.yao AT tum.de>
    properties
        progressbarCollection
    end
    
    properties (TestParameter)
        backend = {"CLI", "GUI"}
    end

    methods (TestMethodSetup)
        function testSetup(testCase)
            testCase.setupProgressbarCollection()
        end
    end

    methods (TestMethodTeardown)
        function testTeardown(testCase)
            if ~isempty(testCase.progressbarCollection)
                delete(testCase.progressbarCollection)
            end
        end
    end

    methods
        function setupProgressbarCollection(testCase, varargin)
            testCase.progressbarCollection = ProgressbarCollection(varargin{:});
        end
    end
    
    methods(Test)
        function testProgressbarConstructionCLI(testCase, backend)
            testCase.setupProgressbarCollection("Backend",backend)
        end

        function testProgressbarConstructionError(testCase)
            testCase.verifyError(@() ProgressbarCollection("Backend","XXX"),'MATLAB:validators:mustBeMember')
            testCase.verifyError(@() ProgressbarCollection("StrictMode","XXX"),'MATLAB:validation:UnableToConvert')
        end

        function testSingleLevel(testCase)
            testCase.progressbarCollection.setProgressMaximum(1, 5, 'Level1')
            
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1, 1))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1, 2, ''))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1, 1, 'Level1-2'))

            testCase.verifyWarningFree(@() testCase.progressbarCollection.finishProgress(1))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.terminate())
        end

        function testMultipleLevel(testCase)
            testCase.progressbarCollection.setProgressMaximum(1, 5, 'Level1')
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1, 1, ''))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1, 2, 'Level1-2'))

            testCase.progressbarCollection.setProgressMaximum(2, 5, 'Level2')
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(2))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(2, 3, 'Level2-2'))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(2, 1))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.finishProgress(2))

            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1, 2, 'Level1-3'))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.finishProgress(1))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.terminate())
        end

        function testSingleLevelWarningAndError(testCase)
            testCase.progressbarCollection.setProgressMaximum(1, 5, 'Level1')
            testCase.verifyError(@() testCase.progressbarCollection.setProgressMaximum(1, 5, 'Level1'),'MATLAB:badsubscript')
            testCase.verifyError(@() testCase.progressbarCollection.setProgressMaximum(3, 5, 'Level3'),'MATLAB:badsubscript')
            testCase.progressbarCollection.setProgressMaximum(2, 5, 'Level2')
            testCase.progressbarCollection.setProgressMaximum(3, 0, 'Level3')

            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(3, 0, 'Level3-another-desciption'))
            testCase.verifyError(@() testCase.progressbarCollection.finishProgress(4),'MATLAB:badsubscript')
            testCase.verifyWarningFree(@() testCase.progressbarCollection.finishProgress(3))

            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(2, 4))
            testCase.verifyWarning(@() testCase.progressbarCollection.finishProgress(2), 'Progressbar:stateMachineError')
            
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1, 5))
            testCase.verifyWarning(@() testCase.progressbarCollection.stepProgress(1, 1), 'Progressbar:stateMachineError')
            testCase.verifyWarningFree(@() testCase.progressbarCollection.finishProgress(1))
            
            testCase.verifyWarningFree(@() testCase.progressbarCollection.terminate())
        end

        function testSingleLevelError(testCase)
            testCase.progressbarCollection.setProgressMaximum(1, 5, 'Level1')
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1, 5))
            testCase.verifyWarning(@() testCase.progressbarCollection.delete(), 'Progressbar:stateMachineError')
        end

        function testSingleLevelIntermediate(testCase)
            testCase.progressbarCollection.setProgressMaximum(1, 0, 'Some mission')
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1, 0, 'Text 1'))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1, 0, 'Text 2'))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.stepProgress(1, 0, 'Text 3'))
            testCase.verifyWarningFree(@() testCase.progressbarCollection.finishProgress(1))
        end
    end
end