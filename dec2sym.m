% function to generate text with symbols from input decimal number 
%   - set wDouble = 1 for '1': w^2; wDouble = 0 for '1': w
function symStr = dec2sym(binStr,wDouble)

    if isempty(binStr)
        symStr = "";
    end

    % check whether the string starts with 1
    startFlag = (binStr(1) == '1');

    % compute lengths of consecutive 0 and 1 
    % segments
    [str0length,str1length,~] = permSplit(binStr);

    % define unicode characters 
    w = char(969);
    dw = ['(d' char(969) ')'];

    % create cell array to store symbol strings 
    symCell = cell(1,sum(length(str0length)+length(str1length)));

    % multiplicative factor, 2 if wDouble = true;
    % 1 if wDouble = false
    multFac = wDouble + 1;

    % for loop to store (dw)  symbols 
    for ct = 1:length(str0length)
        symCell{2*ct-~startFlag} = [dw genPwrStr(str0length(ct),false)];
    end

    % for loop to store w^2 symbols
    for ct = 1:length(str1length)
        symCell{2*ct-startFlag} = [w genPwrStr(multFac*...
            str1length(ct),false)];
    end

    % concatenate cell elements into a string 
    symStr = string(strjoin(symCell,''));

end