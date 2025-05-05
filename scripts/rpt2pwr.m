% function to convert array of successive repeating numbers 
% into a string containing numbers raised to powers 
function outputStr = rpt2pwr(decArr)

    % Find consecutive repetitions
    diffA = [1, diff(decArr)]; % Find changes
    idx = find(diffA ~= 0); % Indices where values change
    values = decArr(idx); % Unique values in order
    counts = diff([idx, numel(decArr) + 1]); % Count consecutive occurrences
    
    % find the number of digits in values and powers
    valuesDigNum = floor(log10(values)) + 1;
    countsDigNum = floor(log10(counts)) + 1;
    countsDigNum(counts==1) = 0; % replace 1's with 0's 
                                 % since ^1's are suppressed
    digitNum = valuesDigNum + countsDigNum;

    % add the number spaces in between the decimals
    % to the total number of digits (length of the 
    % output array)
    outLen = sum(digitNum) + length(values) - 1;

    % initialize output string as char
    outputStr = blanks(outLen);

    % for loop to fill out outputStr
    ind = 1; % index for outputStr
    for valCt = 1:length(values)
        % find the length of the piece 
        strLen = digitNum(valCt);

        outputStr(ind:ind+strLen-1) = ...
            [num2str(values(valCt)) genPwrStr(counts(valCt),false)];

        % increment ind (extra 1 to compensate for 
        % the space between decimals)
        ind = ind + strLen + 1;
    end

    % convert output char array to string
    outputStr = string(outputStr);

end