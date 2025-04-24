% function to find lengths of consecutive 0 and 1 segments
% and check the parity of the permutation
function [str0length,str1length,evenFlag] = permSplit(binStr)

    % split repeating '0's and '1's
    str0length = strsplit(binStr,'1');
    str1length = strsplit(binStr,'0');

    % remove empty cells caused by the starting and ending bits
    str0length = str0length(~cellfun('isempty',str0length));
    str1length = str1length(~cellfun('isempty',str1length));

    % compute lenghts of the substrings 
    str0length = cellfun(@length,str0length);
    str1length = cellfun(@length,str1length);

    % check the parity of the permutation
    if sum(mod(str1length,2))==0
        evenFlag = true;
    else
        evenFlag = false;
    end
end