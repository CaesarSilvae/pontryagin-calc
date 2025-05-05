% function to generate cylcic permutations of the input decimal
% outputs row array containing unique cyclic permutations in 
% decimal. 
%   - wDouble = true means '1' = w^2, wDouble = false
%     means '1' = w
%   - if derivFlag = true, it means that decNum is a total
%     derivative term, if cyclic shift leaves it invariant,
%     it does not vanish
function [partialNum,decArr,shiftedOnesNum] = ...
    genCycPerm(decNum,n,wDouble,derivFlag)

    % add class(decNum) == 'double' etc.

    % if n is less than the minimum number of digits needed
    % to convert decimal to binary, pop up error
    if n < ceil(log2(decNum))
        error('n is not sufficient to convert decNum!')
    end

    % convert input decimal to binary sequence
    binStr = dec2bin(decNum,n);

    % number of (dw)'s, i.e. 0's in the binary number 
    partialNum = sum(binStr == '0');

    % if only partialNum is wanted, compute it and 
    % return function output immediately
    if nargout == 1
        return;
    end

    % initialize the matrix which holds the cyclic shifts
    cycMat = dec2bin(decNum*ones(n,1),n);

    % shift rows one by one to the left
    for ct = 2:n
        % check whether the shifted version is the 
        % same permutation as the original
        shifted = circshift(binStr,-(ct-1));

        if isequal(shifted,binStr)
            % if wDouble = false and the term is not a  
            % total derivative term, check if the number
            % of shifted 1's is odd
            oneShifts = sum(binStr(1:ct-1)=='1');
            if ~wDouble && ~derivFlag && mod(oneShifts,2) 
                decArr = [];
                partialNum = [];
                shiftedOnesNum = [];
                return; % return function
            end
        end

        % assign sequence in the appropriate row
        cycMat(ct,:) = shifted;
    end

    % convert back to decimal array and remove repeating elements
    [decArr,indArr] = unique(bin2dec(cycMat));

    % transpose the decimal array to get column vector
    decArr = transpose(decArr);

    % if shiftedOnesNum is also requested, compute it
    if nargout > 2
        % check how many shifts to the left are needed to convert 
        % the original array to the one with minimum decimal value
        leftShiftNum = indArr(1)-1;
    
        % find the number of shifted 1's
        shiftedOnesNum = sum(binStr(1:leftShiftNum)=='1');

    end
end