classdef ProgressbarViewGUI < progressbar.IProgressbarView
    %PROGRESSBARGUI the matlab GUI version of the progressbar view
    %
    % Author:  Haowen Yao <haowen.yao AT tum.de>
    
    properties (SetAccess = private)
        % the progressbar uiFigure handle
        fig (1,1)
        
        % the progressbar handle
        d (1,1)

        % the Estimator handle
        est
    end

    methods
        function obj = ProgressbarViewGUI(model, namedArgs)
        % PROGRESSBARGUI The constructor of the ProgressbarGUI
        %   PROGRESSBARGUI(model, namedArgs) create a progressbar GUI view
        %
        %   model - the progressbar.ModelProgressbar class for data
        %           notification.
        %   namedArgs - exposed named arguments for matlab.ui.Figure class
            arguments
                model(1,1) progressbar.ModelProgressbar
                namedArgs.?matlab.ui.Figure
            end

            obj@progressbar.IProgressbarView(model)

            obj.fig = uifigure(namedArgs);

            obj.d = uiprogressdlg(obj.fig, 'Title','Please Wait', 'Message','Loading');

            obj.est = ETAEstimator.Estimator();

            % Refresh the view for the first time 
            obj.onDataChanged() 
        end

        function delete(obj)
        % DELETE Decosntructor of the object
        %   DELETE(obj) is called to delete the internal objects.
            delete(obj.fig)
        end
    end

    methods (Access = protected)
        function updateData(obj, model)
            % UPDATEDATA Update the view accroding the the data in model. 
            %   UPDATEDATA(obj, model) update the view accroding the the data in model
            %   Inherited from IProgressbarView
            maxLevel = model.maxLevel();
            message = "";

            if maxLevel == 0
                obj.d.Title = 'Please Wait';
                obj.d.Message = 'Progress data empty';
                obj.d.Indeterminate = 'on';
            else
                obj.d.Title = "" + 'Totally depth ' + maxLevel + ' of nested loop';

                for iLevel = 1:maxLevel
                    [value, maximum, description] = model.get(iLevel);
                    if iLevel == 1
                        if maximum == 0
                            obj.d.Indeterminate = 'on';
                        else
                            progress = double(value)/double(maximum);
                            obj.d.Value = progress;
                            obj.d.Indeterminate = 'off';
                            [H, M, S] = obj.est.estimate(progress);
                        end
                    end
                    if maximum == 0
                        message = message + description + newline;
                    else
                        message = message + description + ' [' + value +'/'+maximum +']'+newline;
                    end
                end

                if maximum ~= 0
                    message = message + 'ETA: ' +sprintf("%02d",H)+ ':' +sprintf("%02d",M)+ ':' +sprintf("%02d",S)+ ' ';
                end
                obj.d.Message = message;
            end
        end
    end
end

