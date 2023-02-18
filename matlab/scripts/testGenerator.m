clc; clear;

sr = 48000;

generator = StimulusGenerator(12, 0.04, 0.1, 5, sr);

gainDb = -30;

x = db2mag(gainDb) * generator.make(3, 2);

plot(x);