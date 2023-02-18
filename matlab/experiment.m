clc; clear; close all;

addpath(genpath('.'));

whichDevice = 'Head rotation';
sr = 48000;
blockSize = 4096;
numChannels = 12;
gainDb = -30;

burstDurSecs = 0.04;
stepDurSecs = 0.1;
numRepeats = 5;

player = Player(whichDevice, blockSize, sr);
generator = StimulusGenerator(numChannels, burstDurSecs, stepDurSecs, numRepeats, sr);


x = db2mag(gainDb) * generator.makeStatic([1, 6]);
player.play(x)

% Load one row at a time. (row has playback files, routing, and ground
% truth answer.
% Execute trial (looping ?).
% Wait for result, get time. Record answer.