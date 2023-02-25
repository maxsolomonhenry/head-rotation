clc; clear; close all;

addpath(genpath("."));
applyPlotSettings();

dataDir = "data/";
dirInfo = dir(fullfile(dataDir, "*.csv"));

df = table();

numFiles = length(dirInfo);

for f = 1:numFiles
    fname = dirInfo(f).name;
    fpath = fullfile(dataDir, fname);

    df = vertcat(df, readtable(fpath));
end

% 1 -- 4, engine. 5 -- 8, speakers. 9 -- 12, flat.

df.outputs = makenumerical(df.outputs);
df.condition = getcondition(df.outputs).';
df.playbackDirection = getplaybackdirection(df.outputs).';

getProjectFig(); hold on;
histogram(df(string(df.condition) == "speakers", :).('perceivedRealism'), [0.5, 1.5, 2.5, 3.5, 4.5, 5.5]);
histogram(df(string(df.condition) == "engine", :).('perceivedRealism'), [0.5, 1.5, 2.5, 3.5, 4.5, 5.5]);
histogram(df(string(df.condition) == "flat", :).('perceivedRealism'), [0.5, 1.5, 2.5, 3.5, 4.5, 5.5]);
legend(["Speakers", "Engine", "Flat"]);
xlim([0, 6]);
xticks([1, 2, 3, 4, 5]);
xticklabels(["Bad", "Poor", "Fair", "Good", "Excellent"]);
grid("on");
ylabel("Count");

function y = getplaybackdirection(x)

    for i = 1:length(x)
        % Make equivalent direction in 1, 2, 3, 4.
        tmp = mod(x{i} - 1, 4) + 1;
        y{i} = number2direction(tmp);
        
    end

end

function outputstring = number2direction(inputarray)
    % Define the number-to-character mapping
    mapping = containers.Map([1, 2, 3, 4], {'l', 'r', 'f', 'b'});

    % Convert the input array to a string of matching characters
    outputstring = '';
    for i = 1:numel(inputarray)
        outputstring = [outputstring, mapping(inputarray(i))];
    end

    % Reverse the order of the characters if there are two
    if numel(inputarray) == 2
        outputstring = fliplr(outputstring);
    end
end

function x = makenumerical(x)

    for i = 1:length(x)
        x{i} = str2num(x{i});
    end

end

function y = getcondition(x)

    for i = 1:length(x)
        if any(x{i} <= 4)
            condition = "engine";
        elseif any(x{i} <= 8)
            condition = "speakers";
        else
            condition = "flat";
        end

        y{i} = condition;
    end

end