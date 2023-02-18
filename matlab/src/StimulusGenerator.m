classdef StimulusGenerator

    properties
        numChannels
        numRepeats
        sr

        numStepSamples
        numBurstSamples
        numSamples
    end

    methods
        function obj = StimulusGenerator(numChannels, burstDurSecs, stepDurSecs, numRepeats, sr)

            NUM_STEPS_PER_REPEAT = 8;

            obj.numChannels = numChannels;
            obj.numRepeats = numRepeats;
            obj.sr = sr;

            obj.numBurstSamples = burstDurSecs * sr;
            obj.numStepSamples = stepDurSecs * sr;

            obj.numSamples = obj.numStepSamples * numRepeats * NUM_STEPS_PER_REPEAT;

        end

        function x = makeRhythmic(obj, idxTarget, idxMasker)

            [xTarget, xMasker] = obj.makeTargetAndMasker();

            x = zeros(obj.numSamples, obj.numChannels);

            x(:, idxTarget) = xTarget;
            x(:, idxMasker) = xMasker;

        end

        function x = makeStatic(obj, whichChannels)

            x = zeros(obj.numSamples, obj.numChannels);

            for channel = whichChannels

                x(:, channel) = pinknoise(obj.numSamples);
                
            end

        end

        function [xTarget, xMasker] = makeTargetAndMasker(obj)

            TARGETPATTERN = [1, 1, 0, 0, 1, 0, 1, 0];


            xTarget = [];
            xMasker = [];
            for isOn = TARGETPATTERN
                xTarget = [xTarget; obj.makeStep(isOn)];
                xMasker = [xMasker; obj.makeStep(~isOn)];
            end

            xTarget = repmat(xTarget, [obj.numRepeats, 1]);
            xMasker = repmat(xMasker, [obj.numRepeats, 1]);

        end

        function xStep = makeStep(obj, isOn)

            xStep = zeros(obj.numStepSamples, 1);

            if isOn
                
                xStep(1:obj.numBurstSamples) = pinknoise(obj.numBurstSamples);

            end

        end

    end

end