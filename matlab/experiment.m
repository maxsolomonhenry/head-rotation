clc; clear; close all; fclose all;

addpath(genpath('.'));

NUMDEBUG = inf;

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

participantId = inputdlg("Participant ID:");

dateTime = datestr(now, 'yymmdd_HHMM');

% Create the file name
fname = join([participantId{:}, '_', dateTime, '.csv']);

fpath = fullfile(datadir, fname);
fid = fopen(fpath, 'w');
fprintf(fid, "participantId,trialId,outputs,isRhythmic,perceivedDirection,perceivedRealism, perceivedSource\n");

f = waitbar(0, sprintf("Experiment %d...", i));

whichChoices = {["l", "r", "f", "b"], ["fl", "fr", "bl", "br"]};

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

        perceivedDirection = forcedChoiceAnswer("Which direction did that come from?",  whichChoices{i});
        perceivedRealism = forcedChoiceAnswer("Rate the acoustic realism: 1-Bad, 2-Poor, 3-Fair, 4-Good, 5-Excellent)", ["1", "2", "3", "4", "5"]);
        perceivedSource = forcedChoiceAnswer("What was the source, speakers or headphones?", ["s", "h"]);

        fprintf(fid, "%s,%d,[%s],%d,%s,%s, %s\n", participantId{:}, trialId, join(num2str(outputs), ","), isRhythmic, perceivedDirection, perceivedRealism, perceivedSource);

    end

    waitbar(1, f, "Experiment complete. Press any key to continue...");
    pause();

end

fclose(fid);
fprintf("Results saved to: %s\n", fpath);

waitbar(1, f, "Done! Press any key to close...");
pause();
close(f);

