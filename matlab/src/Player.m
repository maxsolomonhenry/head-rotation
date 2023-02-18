classdef Player

    properties
        blockSize
        deviceWriter
    end

    methods
        function obj = Player(whichDevice, blockSize, sr)

            obj.blockSize = blockSize;

            obj.deviceWriter = audioDeviceWriter(sr, "Device", whichDevice, "BufferSize", blockSize, "ChannelMappingSource","Property");
            obj.deviceWriter.ChannelMapping = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

        end

        function play(obj, x)

            NUMCHANNELS = 12;

            numBlocks = ceil(size(x, 1) / obj.blockSize);
            numSamples = numBlocks * obj.blockSize;

            xPadded = zeros(numSamples, NUMCHANNELS);
            xPadded(1:size(x, 1), :) = x;

            pIn = 1;
            pOut = pIn + obj.blockSize - 1;

            while pOut <= size(xPadded, 1)

                obj.deviceWriter(xPadded(pIn:pOut, :));

                pIn = pIn + obj.blockSize;
                pOut = pOut + obj.blockSize;

            end

        end
    end

end