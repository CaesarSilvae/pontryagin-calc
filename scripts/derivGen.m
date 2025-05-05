% # of equations increase drastically with increasing 
% dimension. Add a mechanism to compute iteratively

%   - assumes that the elements of evenDoublewArr starts 
%     with '0' and ends with '1'
%   - '1's in evenDoublewArr denotes w^2
function [params,totDerivArr,totDerivCoeffArr] = ...
    derivGen(params,evenDoublewArr,evenCoeffArr)

    % list containing warnings
    warnings = params.warnings;

    % error flag 
    errorFlag = false;

    % number of binary sequences, i.e. number of 
    % unique even terms
    evenNum = length(evenDoublewArr);

    % compute the # of 0's, i.e. # of (dw)'s
    partialNum = sum(evenDoublewArr{1}=='0');

    % compute dimension for error output
    dim = 2*length(evenDoublewArr{1});

    % if there is no (dw) term, yield empty output
    if partialNum == 0
        totDerivArr = [];
        totDerivCoeffArr = [];
        return;
    end

    % other constants
    eqnNum = partialNum*evenNum; % max # of eqn.s
    wNum = dim - 2*partialNum; % number of w's (1's)
    oddNum = eqnNum*wNum; % max # of odd terms

    % initialize cell arrays with maximum possible 
    % size 
    totDerivArr = repmat("",1,eqnNum); % holds tot. deriv. terms
    evenArr = ...
        regexprep(evenDoublewArr,'1','11'); % holds even terms
    oddArr = cell(1,oddNum); % holds odd terms
    partCoeffArr = ...
        zeros(1,eqnNum); % holds coefficients of tot. deriv.s
    evenCoeffMat = ...
        zeros(eqnNum,evenNum); % holds coefficients
                               % of even terms
    oddCoeffMat = ... 
        zeros(eqnNum,oddNum); % holds coefficients
                              % of odd terms

    % for loop to iterate through input binary  
    % numbers
    eqnCt = 0; % counter for equation no
    oddCt = 0; % index counter for oddArr
    for indCt = 1:evenNum

        % multiplier coefficient that is in 
        % front of the original even term
        multCoeff = evenCoeffArr(indCt);

        % binCt'th binary sequence
        binStr = evenDoublewArr{indCt};

        % find the lengths of consecutive 0 segments
        [str0length,~,~] = permSplit(binStr);

        % number of (dw)^... w^... groups
        groupNum = length(str0length);
    
        % for loop to apply int. by parts to each 0
        for groupNo = 1:groupNum
            % number of (dw)'s within the group
            groupPartNum = str0length(groupNo);

            % iterate through consecutive 0's within the 
            % group
            for partialNo = 1:groupPartNum

                % apply integration by parts
                [partTerm,permsArr,coeffArr,evenTrueArr] = ...
                    intByParts(binStr,groupNo,partialNo);
    
                % check if partTerm is already in partArr
                % if so skip the iteration, otherwise
                % add the total derivative term in 
                % partArr
                tempPartInd = ...
                    find(totDerivArr==partTerm, 1); % find the index of duplicate
                
                % % % FOR TESTING
                % % testArr = [partTerm ', ' num2str(groupNo) ', ' num2str(partialNo)];
                % % if ~isempty(tempPartInd)
                % %     testArr = [testArr ', Not unique'];
                % % end
                % % disp(testArr)

                % if partTerm is in partArr, skip
                if ~isempty(tempPartInd)
                    continue;
                end

                % otherwise add partTerm in partArr,
                % increment eqnCt and add coefficient
                % of partTerm in partCoeffArr
                eqnCt = eqnCt + 1;
                totDerivArr(eqnCt) = partTerm;
                partCoeffArr(eqnCt) = multCoeff;
    
                % split even terms and iterate through
                % them to check whether they are already
                % in evenArr
                tempEvenArr = permsArr(evenTrueArr);
                tempEvenCoeffArr = coeffArr(evenTrueArr);
                for tempCt = 1:length(tempEvenArr)
                    % select the even term 
                    tempEven = tempEvenArr{tempCt};

                    % find index of tempEven in evenArr
                    tempEvenInd = ...
                        cellfun(@(x) isequal(x,tempEven),...
                        evenArr);

                    % add coefficient in column # tempEvenInd
                    % and row # eqnCt of evenCoeffMat
                    evenCoeffMat(eqnCt,tempEvenInd) = ...
                        tempEvenCoeffArr(tempCt)*multCoeff;
                end

                % split odd terms and iterate through
                % them to check whether they are already
                % in oddArr
                tempOddArr = permsArr(~evenTrueArr);
                tempOddCoeffArr = coeffArr(~evenTrueArr);
                for tempCt = 1:length(tempOddArr)
                    % select the odd 
                    tempOdd = tempOddArr{tempCt};

                    % find index of tempOdd in oddArr
                    tempOddInd = ...
                        find(cellfun(@(x) isequal(x,tempOdd),...
                        oddArr(1:oddCt)));

                    % if tempOdd is not in oddArr add it
                    if isempty(tempOddInd)
                        %  increment oddCt 
                        oddCt = oddCt + 1;

                        % add in oddArr 
                        oddArr{oddCt} = tempOdd;

                        % reassign tempOddInd
                        tempOddInd = oddCt;
                    
                    end
                   
                    % add coefficient in column # tempOddInd
                    % and row # eqnCt of oddCoeffMat
                    oddCoeffMat(eqnCt,tempOddInd) = ...
                        tempOddCoeffArr(tempCt)*multCoeff;
                end
            end
        end
    end

    % multiply oddCoeffMat with minus one to carry odd 
    % terms from LHS to RHS to cope with the thesis conv.
    oddCoeffMat = -oddCoeffMat;

    % remove excessive equation rows  
    if eqnCt < eqnNum
        totDerivArr(eqnCt+1:end) = [];
        partCoeffArr(eqnCt+1:end) = [];
        evenCoeffMat(eqnCt+1:end,:) = [];
        oddCoeffMat(eqnCt+1:end,:) = [];
    end

    % remove excessive odd term columns 
    if oddCt < oddNum
        oddArr(oddCt+1:end) = [];
        oddCoeffMat(:,oddCt+1:end) = [];
    end

    % compute the coefficient matrix that solves  
    % the matrix equation
    [params,K] = solveEqn(params,evenCoeffMat,...
        oddCoeffMat,dim,partialNum);

    % if K is empty throw error otherwise, compute 
    % K'*Meven 
    if isempty(K)
        errorFlag = true;

    else
        Keven = K'*evenCoeffMat;
    
        % if the # of rows of Keven is greater than 1,
        % find the row which yields the Pontryagin term
        rowNum = size(Keven,1);
        rowFound = false; % flag to keep track of whether 
                          % or not the approriate row is
                          % found 
        [normedCoeffArr,coeffArrNum,~] = ...
            normalizeArr(evenCoeffArr); % find the normalized
                                        % input even coefficient
                                        % array 
    
        % for loop to iterate through the rows of 
        % Keven 
        for rowCt = 1:rowNum
            % select the row 
            KevenRow = Keven(rowCt,:);
    
            % normalize the row
            [normedMevenRow,MevenRowNum,MevenRowDen] = ...
                normalizeArr(KevenRow);
    
            % check for equality of normalized arrays
            if isequal(normedMevenRow,normedCoeffArr)
                % raise the flag
                rowFound = true;
    
                % break the loop
                break;
            end
        end
    
        % if an appropriate row has not been found,
        % throw error 
        if ~rowFound
            % write to log file 
            toLog(params,-1,'K''*Meven did not yield Pontryagin!');
            toLog(params,1,{'Modd',oddCoeffMat,'K',K, ...
                'K''*Meven',Keven}); 
            toLog(params,1,['D-' num2str(dim) ... 
                ', # of (dw)''s: ' num2str(partialNum)]);
    
            % add to warning list 
            wrn = ['K''*Meven did not yield Pontryagin! (' ...
                num2str(partialNum) ',' num2str(dim/2-partialNum) ')'];
            params.warnings{end+1} = wrn;

            % give empty total derivative coefficient array
            totDerivCoeffArr = [];

            % raise error flag 
            errorFlag = true;
        else
            % find the ratio of norms: evenCoeffArr/KevenRow
            % then Keven = evenCoeffArr/normRatio
            normRatio = coeffArrNum/MevenRowNum*MevenRowDen;
        
            % find the overall total derivative coefficient 
            % array 
            totDerivCoeffArr = ...
                normRatio*transpose(K(:,rowCt)).*partCoeffArr;
        
            % find the indices with 0 coefficient 
            zeroInd = find(totDerivCoeffArr == 0);
            
            % remove those elements from coefficient array
            % and total derivative term array
            totDerivCoeffArr(zeroInd) = [];
            totDerivArr(zeroInd) = [];
        end
    end

    % save odd and even matrices even if erroneous
    saveMat(params,dim,partialNum, ...
        {'Meven',evenCoeffMat,'Modd',oddCoeffMat},errorFlag);

    % save symbolic arrays
    totDerivSymArr = cellfun(@(x) dec2sym(x,false),totDerivArr);
    evenSymArr = cellfun(@(x) dec2sym(x,false),evenArr);
    oddSymArr = cellfun(@(x) dec2sym(x,false),oddArr);
    saveMat(params,dim,partialNum, ...
        {'Ud',totDerivSymArr,'Ueven',evenSymArr,'Uodd',oddSymArr}, ...
        errorFlag);

    % give empty output if error flag is raised
    if errorFlag
        totDerivArr = [];
        totDerivCoeffArr = [];
    end
end

% function to find coefficient matrix which solves
% the matrix equation
function [params,K] = solveEqn(params,Meven,Modd,...
    dim,partialNum)
    % tolerance below which elements of K'Modd will
    % be set 0
    tol = params.misc.tolerance;

    % number of equations 
    eqnNum = size(Meven,1);

    % check the equality of rows of Meven and Modd
    % if they are not equal, throw error
    if size(Modd,1) ~= eqnNum
        toLog(params,-1,'# of rows of Meven and Modd are not the same!');
        toLog(params,1,{'Meven',Meven,'Modd',Modd});
        toLog(params,1,['D-' num2str(dim) ... 
            ', # of (dw)''s: ' num2str(partialNum)]);

        % add to warning list 
        wrn = ['# of rows of Meven and Modd are not the same! (' ...
            num2str(partialNum) ',' num2str(dim/2-partialNum) ')'];
        params.warnings{end+1} = wrn;

        % give empty output
        K = [];
        return;
    end

    % Find null space of Modd
    Mred = rref(Modd');
    freeCoeffNum = size(Modd,1) - rank(Mred);
    K = [-Mred(1:rank(Mred),rank(Mred)+1:eqnNum); ...
         eye(freeCoeffNum)];
    % K = null(Modd','r');

    % double check that K^T*Modd is indeed zeros
    KModd = K'*Modd;
    KModd(KModd<tol) = 0; % set numbers below tol 0
    if ~isequal(KModd,zeros(size(KModd)))
        % write to log
        toLog(params,-1,'Odd terms do not  vanish!');
        toLog(params,1,{'Modd',Modd,'K',K});
        toLog(params,1,['D-' num2str(dim) ... 
            ', # of (dw)''s: ' num2str(partialNum)]);

        % add to warning list 
        wrn = ['Odd terms do not  vanish! (' ...
            num2str(partialNum) ',' num2str(dim/2-partialNum) ')'];
        params.warnings{end+1} = wrn;

        % save K matrix
        saveMat(params,dim,partialNum,{'K',K},true);

        % give empty output
        K = [];

        return;
    end

    % save K matrix
    saveMat(params,dim,partialNum,{'K',K},false);
end

% function to find the greatest common factor (gcf) of 
% elements of the input array.
%   - outputs array divided by the total gcf, gcf of 
%     numberators and gcf of denominators
function [arrOut,numFac,denFac] = normalizeArr(arrIn)
    
    % find the numerator and denumerator arrays
    [numArr,denArr] = rat(arrIn);

    % find the greatest common factor of numerators
    numFac = numArr(1); % start with the first element
    for ct = 2:length(numArr)
        numFac = gcd(numFac,numArr(ct));
    end

    % find the least common multiple of denominators
    denFac = denArr(1); % start with the first element
    for ct = 2:length(denArr)
        denFac = lcm(denFac,denArr(ct));
    end
        
    % divide the input array by the overall coeff and 
    % convert to integer array, since the fractions 
    % are taken care of 
    arrOut =  round(arrIn*denFac/numFac);
end