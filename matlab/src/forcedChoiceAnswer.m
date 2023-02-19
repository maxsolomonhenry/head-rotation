function theAnswer = forcedChoiceAnswer(prompt, choices)

    promptString = join([prompt, sprintf("[%s]", choices)]);

    isValid = false;
    
    while ~isValid
        answer = inputdlg(promptString);
        isValid = ismember(answer{:}, choices);
    end

    theAnswer = answer{:};

end