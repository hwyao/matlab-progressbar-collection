classdef Estimator < handle
    %ESTIMATOR the ETA estimator
    % See https://stackoverflow.com/a/28005790
    %
    % Author:  Haowen Yao <haowen.yao AT tum.de>

    properties
        % number of iterations together to count as a iteration to prevent
        % single iteration being too fast.
        nAverage

        % the actual counter for iteration average
        iAverage

        % progress saved for previous estimation average.
        lastProgress

        % speed saved for previous estimation. Save 5 past values.
        lastSpeed

        % the previously saved ETA 
        lastETA
        H
        M
        S

        % the number of factor for updating ETA
        %   newETA = updateFactor * currentETA + (1 - updateFactor) * lastETA
        updateFactor
        
        % the tic handle for iteration
        ticHandle
    end
    
    methods
        function obj = Estimator(nAverage, updateFactor)
            % ESTIMATOR initializer of estimator
            %   Inputs:
            %     nAverage : the number of obj.estimation() call to trigger
            %       a real timer update to smooth the result and sparse the
            %       computation resources.
            %
            %           estimate() estimate() ... estimate(obj)
            %               |-------nAverage times ------|
            %                                            ^ trigger a update for
            %                                            lastETA and other states
            %
            %     updateFactor : the number of factor for updating ETA
            %       newETA = updateFactor * currentETA + (1 - updateFactor) * lastETA
            %
            %   Outputs:
            %     obj : the Estimator() handle
            arguments
                nAverage(1,1) double {mustBePositive} = 5
                updateFactor(1,1) double {mustBeGreaterThan(updateFactor,0),mustBeLessThan(updateFactor,1)} = 0.5
            end
            obj.nAverage = nAverage;
            obj.iAverage = 0;

            obj.lastProgress = 0;
            obj.lastSpeed = zeros(1,5);

            obj.lastETA = 0;
            obj.H = 0;
            obj.M = 0;
            obj.S = 0;

            obj.updateFactor = updateFactor;
            obj.ticHandle = tic;
        end
        
        function [H, M, S] = estimate(obj, progress)
            % ESTIMATE estimate the ETA in the iteration loop
            % Input:
            %    progress : the progress value between 0 and 1 
            % Output:
            %    H : hours left
            %    M : minutes left
            %    S : seconds left
            obj.iAverage = obj.iAverage + 1;
            if obj.iAverage >= obj.nAverage
                obj.iAverage = 0;

                % save the last time
                period = toc(obj.ticHandle);
                velocity = (progress - obj.lastProgress) / period;
                obj.lastSpeed = [obj.lastSpeed(2:5), velocity];
                avgSpeed = sum(obj.lastSpeed) / 5;
                
                currentETA = (1 - progress) / avgSpeed;
                if (currentETA==inf)
                    currentETA = 99*60*60;
                end
                obj.lastETA = obj.updateFactor * currentETA + (1 - obj.updateFactor) * obj.lastETA;

                obj.ticHandle = tic();
                obj.lastProgress = progress;

                % calculate the ETA
                time = obj.lastETA;
    
                obj.S = mod(time, 60);
                time = time - obj.S;
                time = time / 60;
                obj.S = ceil(obj.S);
    
                obj.M = mod(time, 60);
                time = time - obj.M;
                time = time / 60;
                
                obj.H = time;
            end

            H = obj.H;
            M = obj.M;
            S = obj.S;
        end
    end
end

