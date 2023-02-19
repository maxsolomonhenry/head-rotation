function df = makeStimulusTable(whichExperiment, numTrialRepeats)

    switch whichExperiment
        case 'source'
            df = makeSourceTable();
        case 'combined'
            df = makeCombinedTable();
        case 'streams'
            df = makeStreamsTable();
        otherwise
            error("Unrecognized experiment.");
    end

    df = repmat(df, numTrialRepeats, 1);

    trialId = (1:height(df)).';
    df.trialId = trialId;

    % Randomize the conditions.
    df = df(randperm(size(df, 1)), :);

end

function df = makeSourceTable()

    outputs = (1:12)';
    isRhythmic = false(12, 1);

    df = table(outputs, isRhythmic);

end

function df = makeCombinedTable()

    seed = [[1, 3]; [1, 4]; [2, 3]; [2, 4]];

    % Make for all three conditions.
    outputs = [seed; seed + 4; seed + 8];

    isRhythmic = false(length(outputs), 1);

    df = table(outputs, isRhythmic);

end

function df = makeStreamsTable()

    % All combinations of two unique speakers.
    seed = [];
    for i = 1:4
        for j = 1:4
            if i == j
                continue
            end

            seed = [seed; [i, j]];
        end
    end

    % For all three conditions.
    outputs = [seed; seed + 4; seed + 8];

    % Make equal length of same-same trials.
    numSameTrialsPerSide = size(outputs, 1) / 12;
    newseed = (1:12)';
    newseed = repmat(newseed, [numSameTrialsPerSide, 2]);

    outputs = [outputs; newseed];

    isRhythmic = true(length(outputs), 1);

    df = table(outputs, isRhythmic);


end