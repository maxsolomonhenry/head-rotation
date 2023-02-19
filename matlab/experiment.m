clc; clear; close all;

addpath(genpath('.'));

NUMDEBUG = 2;

datadir = "data/";

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

partipantId = inputdlg("Participant ID:");

dateTime = datestr(now, 'yymmdd_HHMM');

% Create the file name
fileName = ['PID_', participantId, '_', dateTime, '.txt'];

fpath = 

f = waitbar(0, sprintf("Experiment %d...", i));
for i = 1:length(whichExperiments)

    df = makeStimulusTable(whichExperiments(i), numTrialRepeats);

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
        trialId = trial.trialId;

        x = db2mag(gainDb) * generator.make(outputs, isRhythmic);
        
        player.play(x);

        response1 = inputdlg("Which direction (l/r/f/b) (fl/fr/bl/br)?: ");
        response2 = inputdlb("Was that headphones or speakers (h/s)?: ");

    end

    waitbar(1, f, "Experiment complete. Press any key to continue...");
    pause();

end

waitbar(1, f, "Done! Press any key to close...");
pause();
close(f);

