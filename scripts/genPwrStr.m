% function to generate superscript text from input decimal power 
% set addOne = true to enable ^1 power 
function str = genPwrStr(decPwr,addOne)

    % Unicode superscripts for numbers 1-9
    superscripts = {'⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'};
    
    % check whether the power is 1 or not 
    if (decPwr == 1 && ~addOne)
        str = []; % assign output as empty array
    else
        digitsArr = num2str(decPwr)-'0'; % split decimal into digits
        str = char(superscripts(digitsArr+1)); % write superscripts as
                                               % a cell array 
        str = strjoin(cellstr(str),'');
    end
end
