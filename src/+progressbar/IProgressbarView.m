classdef IProgressbarView < handle
    %IPROGRESSBARVIEW the interface for exact progressbar view implementation. This
    %   class is used to implement the view of the progressbar. This view can be any
    %   type of view, such as text view, graphical view, etc. The only requirement is
    %   that the view should:
    %   - know how to use the data in the model
    %   - update the view according to the listener event
    % 
    % Author:  Haowen Yao <haowen.yao AT tum.de>
    
    properties (SetAccess = protected)
        % Application data model.
        Model(1, 1) progressbar.ModelProgressbar
    
        % Listener object used to respond dynamically to model events.
        Listener(:, 1) event.listener {mustBeScalarOrEmpty}
    end

    methods
        function obj = IProgressbarView(model)
            %IProgressbarView View interface constructor.
            arguments
                model(1, 1) progressbar.ModelProgressbar
            end
        
            obj.Model = model; 
            obj.Listener = listener(obj.Model, ... 
                "DataChanged", @obj.onDataChanged); 
        end 
    end
    
    methods (Access = protected)
        function onDataChanged(obj, ~, ~) 
            %ONDATACHANGED Listener callback, responding to the model event "DataChanged"
            obj.updateData(obj.Model);
        end
    end
    
    methods (Abstract, Access = protected)  
        % UPDATEDATA update the view after the event.
        %   UPDATEDATA(obj, model) update the view accroding the the data in model.
        %   This method should be implemented by the subclass.
        updateData(obj, model)
    end
end