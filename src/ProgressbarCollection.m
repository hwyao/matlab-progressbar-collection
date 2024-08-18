classdef ProgressbarCollection < handle
    %PROGRESSBARCOLLECTION The class that collects the usage of different
    %backends of the progessbar.
    %
    % ProgressbarCollection(Name, Value) provides additional options specified by
    % Name-Value pair arguments to customize the progressbar. Available parameter
    % names: Backend, StrictMode.
    % 
    % methods list:
    %   setProgressMaximum - Set the maximum of a specific level.
    %   stepProgress - Update the progressbar status of a specific level.
    %   finishProgress - Finish a level of the progressbar.
    %   terminate - Terminate the progressbar.
    %   parallelStepHandle - Get a handle to update the progressbar in parallel.
    %
    % Example:
    %   progressbar = ProgressbarCollection('Backend','GUI','StrictMode',true);
    %   progressbar.setProgressMaximum(1, 100, 'Level 1 description');
    %   for i = 1:100
    %       progressbar.stepProgress(1);
    %   end
    %   progressbar.finishProgress(1);
    %   progressbar.delete();
    % 
    % Author:  Haowen Yao <haowen.yao AT tum.de>
    
    properties (SetAccess = private)
        % the View object of the progressbar
        progressbarView

        % the Model object of the progressbar
        progressbarModel

        % the flag to enable strict mode
        isStrictMode
    end
    
    methods
        function obj = ProgressbarCollection(options)
            %PROGRESSBARCOLLECTION the constructor for the ProgressbarCollection
            %   progressbar = PROGRESSBARCOLLECTION(Name, Value) provides additional
            %   options specified by Name-Value pair arguments. Available parameter
            %   names:
            %  
            %   'Backend' - Backend of the progressbar. Could be 'CLI', 'GUI'
            % 
            %   'StrictMode' - boolean value. Allow strict checking for methods calling. 
            %       When true, some extra warning would pop up when e.g. 
            %       FINISHPROGRESS is called but the progressbar 
            %       is not update to maximum with STEPPROGRESS.
            %       See also FINISHPROGRESS, STEPPROGRESS
            arguments
                options.Backend(1,:) char {mustBeMember(options.Backend,{'GUI','CLI', 'None'})} = 'GUI'
                options.StrictMode(1,1) logical = true
            end

            obj.progressbarModel = progressbar.ModelProgressbar();

            if isequal(options.Backend,'CLI')
                obj.progressbarView %= progressbar.ProgressbarText();
            elseif isequal(options.Backend,'GUI')
                obj.progressbarView = progressbar.ProgressbarViewGUI(obj.progressbarModel);
            elseif isequal(options.Backend,'None')
                obj.progressbarView = progressbar.ProgressbarViewNone(obj.progressbarModel);
            else
                error("ProgressbarCollection:internal","Should not be this branch. Internal implementation error.");
            end

            obj.isStrictMode = options.StrictMode;
        end

        function delete(obj)
            % DELETE deconstructor of the object
            %   DELETE(obj) is called to delete the internal objects. 
            % 
            % See also:
            %   TERMINATE
            obj.terminate();
        end
    end

    methods
        function setProgressMaximum(obj, level, maximum, description)
            % SETPROGRESSMAXIMUM Set the maximum of a specific level.
            %   SETPROGRESSMAXIMUM(obj, level, maximum, description)
            %
            %   level - which level of progressbar to be updated. Different levels
            %           could be used to represent different depth of the nested loop.
            %
            %   maximum - what maximum value does level of progressbar has. When
            %           maximum = 0, the maximum is indeterminate.
            % 
            %   description - what text do we display for this level.
            %
            % See also:
            %   STEPPROGRESS
            arguments
                obj ProgressbarCollection
                level(1,1) double {mustBeNonnegative, mustBeFinite}
                maximum(1,1) double {mustBeNonnegative, mustBeFinite}
                description(1,:) char
            end
            
            maxLevel = obj.progressbarModel.maxLevel();
            if maxLevel+1 ~= level
                if obj.isStrictMode
                    error('MATLAB:badsubscript',"The new level ["+ level +"], is not successor of current maximum level ["+maxLevel+"]!")
                end
                for iLevel = maxLevel+1 : level-1
                    obj.progressbarModel.set(iLevel, 0, '');
                end
            end
            obj.progressbarModel.set(level, maximum, description);
        end

        function stepProgress(obj, level, increment, description)
            % STEPPROGRESS. Update the progressbar status. 
            %   STEPPROGRESS(obj, level, increment, description)
            %
            %   level - which level of progressbar to be updated.
            %
            %   increment - what value does this level of progressbar increase. default 1. 
            %
            %   description(optional) - update desciption of this level. This
            %             could be very helpful when maximum = 0. Default
            %             '' to keep previous description.
            %
            % See also:
            %   FINISHPROGRESS
            arguments
                obj ProgressbarCollection
                level(1,1) double {mustBeNonnegative, mustBeFinite}
                increment(1,1) double {mustBeNonnegative, mustBeFinite} = 1
                description(1,:) char = ''
            end
            
            [value, maximum, ~] = obj.progressbarModel.get(level);
            value = value + increment;
            if value > maximum
                if obj.isStrictMode
                    warning('Progressbar:stateMachineError',"value ["+value+"] exceeding maximum ["+maximum+"]");
                end
                value = maximum;
            end
            obj.progressbarModel.update(level, value, description)
        end

        function finishProgress(obj, level)
            % FINISHPROGRESS. finish a level of the progressbar.
            %   FINISHPROGRESS(obj, level) is normally called after the progressbar
            %   reaches the maximum value. This function will remove the level from
            %   the progressbar.
            % 
            %   level - which level of progressbar to be finished.
            arguments
                obj ProgressbarCollection
                level(1,1) double {mustBeNonnegative, mustBeFinite}
            end
            [value, maximum, ~] = obj.progressbarModel.get(level);
            if obj.isStrictMode && value < maximum
                warning('Progressbar:stateMachineError',"value ["+value+"] not reaching maximum ["+maximum+"]");
            end

            obj.progressbarModel.remove(level);
        end

        function terminate(obj)
            % TERMINATE terminate the progress bar. 
            %   TERMINATE(obj) is called to delete the internal objects. This
            %   function is not suggested to be called manually (unless you have very
            %   specific requirements). The destructor of the object DELETE will
            %   automatically call this function.
            % 
            % See also:
            %   DELETE
            arguments
                obj ProgressbarCollection
            end

            maxLevel = obj.progressbarModel.maxLevel();
            if obj.isStrictMode && maxLevel ~= 0
                warning('Progressbar:stateMachineError',"Process still have ["+maxLevel+"] levels unfinished");
            end
            delete(obj.progressbarView)
        end

        function parStep = parallelStepHandle(obj)
            % PARALLELSTEPHANDLE Get a handle to update the progressbar in parallel.
            %   parStep = PARALLELSTEPHANDLE(obj) is called to get a handle to update
            %   the progressbar with parfor loop. 
            %
            % Simply replace stepProgress(...) as send(parStep, ...) as to update the progressbar.
            % 
            % See also:
            %   STEPPROGRESS

            parStep = parallel.pool.DataQueue;    
            afterEach(parStep,@obj.stepProgress);
        end
    end
end

