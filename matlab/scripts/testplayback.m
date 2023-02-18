clc; clear; close all;

desiredOutput = "Aggregate Device (Core Audio)";
devices = audiodevinfo;

for i = 1:numel(devices.output.Name)
    if strcmp(devices.output(i).Name, desiredOutput)
        deviceId = devices.output(i).ID;
        break
    end
end

sr = 48000;
blockSize = 4096;
numChannels = 12;
gainDb = -30;

whichChannels = [9, 10];

testDurationSeconds = 5;
time = 0:1/sr:testDurationSeconds;
time = time.';

numSamples = length(time);
xPink = db2mag(gainDb) * pinknoise(numSamples, 1);

deviceWriter = audioDeviceWriter(sr, "Device", 'Head rotation', "BufferSize", blockSize, "ChannelMappingSource","Property");
deviceWriter.ChannelMapping = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

x = db2mag(-30) * pinknoise(5 * sr, 1);

idxIn = 1;
idxOut = idxIn + blockSize - 1;

buffer = zeros(blockSize, numChannels);

while idxOut <= length(x)
    
    buffer = buffer * 0;

    for channel = whichChannels
        buffer(:, channel) = x(idxIn:idxOut, :);
    end

    deviceWriter(buffer);

    idxIn = idxIn + blockSize;
    idxOut = idxOut + blockSize;

end

% Load one row at a time. (row has playback files, routing, and ground
% truth answer.
% Execute trial (looping ?).
% Wait for result, get time. Record answer.