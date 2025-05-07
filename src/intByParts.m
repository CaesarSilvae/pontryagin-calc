% function to apply integration by parts to the 
% (dw) of the groupNo group and partNo within
% that group
% 
% - outputs total derivative term as 'partTerm',
%   other permutations as cell array in 'permsArr',
%   coefficients of the permutations in 'coeffArr',
%   parity of the permutations; '0' if even and 
%   '1' if odd 
% - assumes that binSingle starts with a '0' and 
%   ends with a '1'. '0': dw, '1': w^2
% - assumes that total derivative term does not 
%   vanish by cyclic shift symmetry
function [partTerm,permsArr,coeffArr,evenTrueArr] = ...
    intByParts(binSingle,groupNo,partNo)

    % duplicate 1's in the string to change w^2's
    % to ww's
    binDouble = regexprep(binSingle,'1','11');

    % compute the number of digits 
    digNum = length(binDouble);

    % compute lengths of consecutive 0 and 1 
    % segments
    [str0length,str1length,~] = permSplit(binDouble);

    % if there are no 0's in the sequence, meaning 
    % that the term is composed of only w's,
    % return all the outputs empty
    if isempty(str0length)
        partTerm = [];
        permsArr = [];
        coeffArr = [];
        evenTrueArr = [];
        return;
    end

    % if there are no 1's in the sequence, meaning 
    % that the term is composed of only (dw)'s
    if isempty(str1length)
        % convert the last term from 0 to 1, since 
        % the minimum of cyclic shifts of the total
        % derivative term is to be chosen
        partTerm = binDouble;
        partTerm(end) = '1';
        partTerm = dec2sym(partTerm,false);

        % set other outputs 
        permsArr = {binSingle};
        coeffArr = 1;
        evenTrueArr = true;
        return;
    end

    % check whether groupNo and partNo are appropriate
    if groupNo > length(str1length)
        error('Group no is not valid!')
    elseif partNo > str0length(groupNo)
        error('Part no is not valid!')
    end

    % find the length of each (dw)^... w^... group
    % add 0 in front to compensate for groupNo=1
    groupLengths = str0length + str1length;

    % index of dw on which int. by parts is to be applied
    derivInd = sum(groupLengths(1:groupNo-1)) + partNo;

    % find the total number of w's and initialize cell
    % array to store terms with derivative applied to 
    % various w's, array to store parities and array
    % to store coefficients of the terms
    wNum = sum(str1length);
    permsArr = cell(1,wNum+1); % +1 for the original
    evenTrueArr = false(1,wNum+1); 
    coeffArr = zeros(1,wNum+1);

    % the first element is the original binary 
    % string
    permsArr{1} = binDouble;
    evenTrueArr(1) = true; % original term is even
    coeffArr(1) = 1;

    % flip the derivInd bit to convert dw to w
    binDouble(derivInd) = '1'; 
    [~,partTermCycArr,~] = ...
        genCycPerm(bin2dec(binDouble),digNum,false,true);
    % partTerm = dec2bin(partTermCycArr(1),digNum);
    partTerm = dec2sym(dec2bin(partTermCycArr(1),digNum),false);

    % for loop to distribute derivative 
    cellCt = 2; % index to keep track of cell
    for groupCt = 1:length(str1length)
        for wCt = 1:str1length(groupCt)

            % index of w on which d will be applied 
            % add digits from previous groups and 
            % (dw)'s from the current group
            wInd = sum(groupLengths(1:groupCt-1)) + ...
                str0length(groupCt) + wCt;

            % convert that w to a dw
            tempTerm = binDouble;
            tempTerm(wInd) = '0';

            % get the cyclic shift that has minimum 
            % decimal value and store it in the cell
            % array and find the sign due to shift
            [~,decArr,shiftedOnesNum] = ...
                genCycPerm(bin2dec(tempTerm),digNum,false,false);

            % if decArr is empty, meaning that the 
            % term vanishes due to symmetry, then 
            % pass to the next iteration
            if isempty(decArr)
                % leave coeffArr{cellCt} 0

                % assign random sequence, since 
                % sort does not work with empty 
                % cells
                permsArr{cellCt} = '2'; 

                % increment counter
                cellCt = cellCt + 1;
                continue;
            else
                % otherwise convert decimal to binary
                binStr = dec2bin(decArr(1),digNum);
                % CONVERT DIRECTLY TO dw^... w^... etc.

                % assign tempTerm to the corresponding 
                % cell in the cell array
                permsArr{cellCt} = binStr;
                [~,~,parity] = permSplit(binStr);
    
                % assign parity to the corresponding 
                % cell
                evenTrueArr(cellCt) = parity;
    
                % assign the coefficient as -1 or +1
                if groupCt < groupNo
                    coeff = (-1)^wCt;
                else
                    coeff = -(-1)^wCt;
                end
    
                % include the contribution from 
                % cyclic shifting, another - is 
                % added since the terms go from
                % the RHS to the LHS
                coeffArr(cellCt) = ...
                    -coeff*(1 - 2*mod(shiftedOnesNum,2));
            end

            % increment cell index 
            cellCt = cellCt + 1;
        end
    end

    % find the unique elements and remove the duplicates
    %%% SORT WITH EMPTY CELLS!
    [permsArr,sortIndArr] = sort(permsArr);
    [~,uniqueIndArr] = unique(permsArr,'stable');

    % sort coeffArr and evenTrueArr as well
    coeffArr = coeffArr(sortIndArr);
    evenTrueArr = evenTrueArr(sortIndArr);

    % array holding the number of repetitions
    % and array holding indices of repeated 
    % elements 
    rptNumArr = diff([uniqueIndArr' (wNum+2)]);
    [~,rptIndArr] = find(rptNumArr>1);

    % for loop to remove duplicates for each element
    for rptCt = 1:length(rptIndArr)
        % index of the first of the repeated elements
        uniqueInd = uniqueIndArr(rptIndArr(rptCt));

        % number of repetitions
        rptNum = rptNumArr(rptIndArr(rptCt));

        % add up coefficients of the repeated elements
        % and remove their coefficients from cells
        coeffArr(uniqueInd) = ...
            sum(coeffArr(uniqueInd:uniqueInd+rptNum-1));
        coeffArr(uniqueInd+1:uniqueInd+rptNum-1) = 0;
    end

    % remove elements with 0 coefficient, if any, from  
    % the cell arrays
    emptyIndArr = coeffArr == 0;
   
    % remove from arrays 
    permsArr(emptyIndArr) = [];
    coeffArr(emptyIndArr) = [];
    evenTrueArr(emptyIndArr) = [];

end