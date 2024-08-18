classdef ProgressbarViewNone < progressbar.IProgressbarView
    %PROGRESSBARGUI the dummy version of the progressbar view. Used for
    %   unit test.
    %
    % Author:  Haowen Yao <haowen.yao AT tum.de>
        
    methods
        function obj = ProgressbarViewNone(model)
        % PROGRESSBARGUI The constructor of the ProgressbarGUI
        %   PROGRESSBARGUI(model, namedArgs) create a progressbar GUI view
        %
        %   model - the progressbar.ModelProgressbar class for data
        %           notification.
        %   namedArgs - exposed named arguments for matlab.ui.Figure class
            arguments
                model(1,1) progressbar.ModelProgressbar
            end

            obj@progressbar.IProgressbarView(model)

            % Refresh the view for the first time 
            obj.onDataChanged() 
        end

        function delete(obj)  %#ok<*INUSD>
        % DELETE Decosntructor of the object
        %   DELETE(obj) is called to delete the internal objects.
        end
    end

    methods (Access = protected)
        function updateData(obj, model)
        end
    end
end

