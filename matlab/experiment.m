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
numChannels = 17;

testDurationSeconds = 60 * 5;
time = 0:1/sr:testDurationSeconds;
time = time.';

f0 = [440, 660, 880, 1320];
x = cos(2 * pi * f0 .* time);

deviceWriter = audioDeviceWriter(sr, "Device", "Aggregate Device", "BufferSize", blockSize);

idxIn = 1;
idxOut = idxIn + blockSize - 1;

buffer = zeros(blockSize, numChannels);

while idxIn <= length(x)
    
    buffer = buffer * 0;
    buffer(:, 1:4) = x(idxIn:idxOut, :);

    deviceWriter(buffer);

    idxIn = idxIn + blockSize;
    idxOut = idxOut + blockSize;

end

% Load one row at a time. (row has playback files, routing, and ground
% truth answer.
% Execute trial (looping ?).
% Wait for result, get time. Record answer.