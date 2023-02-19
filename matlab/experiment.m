clc; clear; close all;

addpath(genpath('.'));

NUMDEBUG = 4;

whichDevice = 'Head rotation';
sr = 48000;
blockSize = 4096;
numChannels = 12;
gainDb = -30;

burstDurSecs = 0.04;
stepDurSecs = 0.1;
numRhythmRepeats = 5;

numTrialRepeats = 4;

player = Player(whichDevice, blockSize, sr);
generator = StimulusGenerator(numChannels, burstDurSecs, stepDurSecs, numRhythmRepeats, sr);

whichExperiments = ["source", "combined", "streams"];
allNumTrialRepeats = [4, 4, 2];

f = waitbar(0, sprintf("Experiment %d...", i));
for i = 1:length(whichExperiments)

    df = makeStimulusTable( ...
        whichExperiments(i), ...
        allNumTrialRepeats(i));

    waitbar(0, f, sprintf("Experiment %d...", i));
    for j = 1:height(df)

        if j > NUMDEBUG
            break;
        end

        progress = j / height(df);
        waitbar(progress, f, sprintf(sprintf("Experiment %d...", i)));

        trial = df(j, :);
        outputs = trial.outputs;
        isRhythmic = trial.isRhythmic;

        x = db2mag(gainDb) * generator.make(outputs, isRhythmic);
        
        player.play(x);

        response = inputdlg("Which direction (l/r/f/b): ");

    end

end

