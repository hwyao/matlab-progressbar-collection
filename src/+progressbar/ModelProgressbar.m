classdef ModelProgressbar < handle
    %MODELPROGRESSBAR the data model for the Progressbar. This class is used to
    %   store the data of the progressbar. When the data is changed, it will
    %   notify the listener, which will be received by the view object for updating the
    %   display.
    % 
    % Author:  Haowen Yao <haowen.yao AT tum.de>
    
    properties ( SetAccess = private ) 
        % sturcture of progressbar data.
        %   Maximum - maximum value of each data
        %   Value - state value of each data
        %   Description - description of each data
        Data(:,1) struct = struct('Maximum', uint32.empty, 'Value', uint32.empty, 'Description', cell.empty) % cell.empty will make a 0x0 struct here
    end
    
    events ( NotifyAccess = private ) 
        % Event broadcast when the data is changed.
        DataChanged
    end

    methods
        function set(obj, level, maximum, description)
            % SET set the data of a specific level.
            obj.Data(level) = struct('Maximum', uint32(maximum), 'Value', uint32(0), 'Description', char(description));
            notify(obj, "DataChanged")
        end

        function [value, maximum, description] = get(obj, level)
            % GET get the data of a specific level.
            value = obj.Data(level).Value;
            maximum = obj.Data(level).Maximum;
            description = obj.Data(level).Description;
        end

        function maxLevel = maxLevel(obj)
            % MAXLEVEL get the maximum level of the progressbar.
            maxLevel = numel(obj.Data);
        end

        function remove(obj, level)
            % REMOVE remove the data of a specific level.
            obj.Data = obj.Data([1:level-1, level+1:maxLevel(obj)]);
            notify(obj, "DataChanged")
        end
        
        function update(obj, level, value, description)
            % UPDATE update the data of a specific level.
            if level > obj.maxLevel()
                error("MATLAB:badsubscript","level input larger than the length of existing states")
            end
            obj.Data(level).Value = uint32(value);
            if ~isempty(description)
                obj.Data(level).Description = char(description);
            end
            notify(obj, "DataChanged")
        end
    end
end