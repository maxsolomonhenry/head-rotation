clc; clear; close all;

addpath(genpath('.'));

NUMDEBUG = 20;

whichDevice = 'Head rotation';
sr = 48000;
blockSize = 4096;
numChannels = 12;
gainDb = -30;

burstDurSecs = 0.02;
stepDurSecs = 0.1;
numRhythmRepeats = 5;

numTrialRepeats = 4;

player = Player(whichDevice, blockSize, sr);
generator = StimulusGenerator(numChannels, burstDurSecs, stepDurSecs, numRhythmRepeats, sr);

whichExperiments = ["source", "combined"];
allNumTrialRepeats = [4, 4];

df = makeStimulusTable( ...
    whichExperiments(i), ...
    allNumTrialRepeats(i));

waitbar(0, f, "Progress...");
for j = 1:height(df)

    if j > NUMDEBUG
        break;
    end

    progress = j / height(df);
    waitbar(progress, f, "Progress...");

    trial = df(j, :);
    outputs = trial.outputs;
    isRhythmic = trial.isRhythmic;

    x = db2mag(gainDb) * generator.make(outputs, isRhythmic);
    
    player.play(x);

    response = inputdlg("Which direction (l/r/f/b): ");

end

waitbar(1, f, "Experiment complete. Press any key to continue...");
pause();


waitbar(1, f, "Done! Press any key to close...");
pause();
close(f);

