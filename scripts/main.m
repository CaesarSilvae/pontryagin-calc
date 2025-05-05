% \p\g -> 0, \g^2 -> 1
clear vars; clc;

% maximum dimension (must be an even number)
dimMin = 4;
dimMax = 12; 
nMax = dimMax/2;

% if both dimMin and dimMax are not even
% throw error
if mod(dimMin,2) == 1 || mod(dimMax,2) == 1
    error('Dimensions must be even integers!')
end

% if dimMax is less than dimMin, throw error
if dimMax < dimMin
    error('dimMax should not be less than dimMin!')
end

% write to log file 
toLog(-3);

% create folders to store matrices
matricesPath = fullfile(pwd,'matrices');
if ~exist(matricesPath,'dir')
    mkdir(matricesPath);
end

% array of dimensions
dimArr = dimMin:2:dimMax;

% create subfolders of different dimensions
for dim = dimArr
    % subfolder path
    dimPath = fullfile(matricesPath, ...
        ['D-' num2str(dim)]);

    % create if non-existent
    if ~exist(dimPath,'dir')
        mkdir(dimPath);
    end

    % create subsubfolders of different (dw) #
    % created folder has the name 
    % '# of dw-# of w^2'
    n = dim/2;
    for dwNum = 1:n
        % subsubfolder path
        dwPath = fullfile(dimPath, ...
            [num2str(dwNum) '-' num2str(n-dwNum)]);
        
        % create if non-existent
        if ~exist(dwPath,'dir')
            mkdir(dwPath);
        end
    end
end

% initiate table to store permutation 
rowNames = cell([1,nMax]);
for row = 1:nMax
    rowNames{row} = [num2str(2*row) '-D'];
end

varNames = cell([1,nMax+1]);
for col = 1:nMax+1
    varNames{col} = ['(d' char(969) ')' genPwrStr(col-1,true)];
end

tab = table('Size',[nMax,nMax+1], ...
            'VariableTypes',repmat("string",1,nMax+1), ...
            'VariableNames',varNames, ...
            'RowNames',rowNames);

% totDerivXcel = winopen('totDeriv.xlsx');
totDerivExcel = 'totDerivExcel.xlsx';
rowCtExcel = dimMin-1;

% initialize clock array which will contain
% time elapsed for each dimension
clkArr = zeros(size(dimArr));

% main loop to iterate over dimensions up to dimMax
for dim = dimArr

    % display dim started message
    % disp(totDerivStr);
    disp(['Calculation of D-' num2str(dim) ...
        ' started!'])
    toLog(0,['Calculation of D-' num2str(dim) ...
        ' started!'])

    % start clock to find run time for D=dim 
    clk = tic;

    % n
    n = dim/2; 

    % find permutation classses for D=dim 
    permArr = genPerm(dim);

    % assign to the corresponding cell in the table
    colNum = n+1;

    % iterate through columns 
    for col = 1:colNum
        % tab{n,col} = strjoin(string(cellfun(@length,permArr{col}))," ");
        % uncomment to replace repeating values with supersciprts
        tab{n,col} = rpt2pwr(cellfun(@length,permArr{col}));
    end

    % replace the rest with empty cells
    tab{n,col+1:end} = repmat("",1,nMax-n);

    % initialize string to store total derivative term 
    totDerivStr = "";

    % raise the flag which keeps track of the first 
    % term of D=dim
    firstStrFlag = true;

    % reset excel column counter to 2
    colCtExcel = 2;
    writematrix("D-" + string(dim),totDerivExcel, ...
        'Range',['A' num2str(rowCtExcel)]);

    % compute total derivative term
    for permCt = 1:length(permArr)
        % select the cell 
        permCell = permArr{permCt};
        
        % select the cyclic permutations with the 
        % minimum value from each cell and create 
        % a cell array from them
        minCellArr = ...
            num2cell(cellfun(@(x) x(1),permCell));
        evenDoublewArr = ...
            cellfun(@(x) dec2bin(x,n),minCellArr, ...
            'UniformOutput',false);

        % compute the number of equivalent cyclic 
        % shifts in the cells 
        evenCoeffArr = cellfun(@length,permCell);

        % find total derivative terms 
        [totDerivArr,totDerivCoeffArr] = ...
            derivGen(evenDoublewArr,evenCoeffArr);

        % check firstStrFlag and generate string accordingly
        if ~isempty(totDerivCoeffArr)
            [tempStr,coeffStrArr] = ...
                genStr(totDerivCoeffArr,totDerivArr,~firstStrFlag);
            totDerivStr = totDerivStr + tempStr;
        
            % lower firstStrFlag
            firstStrFlag = false;

            % write to excel
            colFirst = num2ExcelCol(colCtExcel);
            colLast = num2ExcelCol(colCtExcel + ...
                length(totDerivArr) - 1);

            % get numerator and denominator content from
            % coefficient array
            [numArr,denArr] = rat(totDerivCoeffArr);

            % write to excel
            strRange = [colFirst num2str(rowCtExcel) ':' ...
                colLast num2str(rowCtExcel)];
            coefRange = [colFirst num2str(rowCtExcel+1) ':' ...
                colLast num2str(rowCtExcel+1)];
            writematrix(totDerivArr,totDerivExcel,...
                'Range',strRange);
            writematrix(coeffStrArr, ...
                totDerivExcel, 'Range',coefRange);

            % increment columns counter
            colCtExcel = colCtExcel + length(totDerivArr);
        end
    end

    % display dim complete message
    % disp(totDerivStr);
    elapsedTime = toc(clk);
    disp(['Calculation of D-' num2str(dim) ...
        ' is complete in ' num2str(elapsedTime) '!'])
    toLog(0,['Calculation of D-' num2str(dim) ...
        ' is complete in ' num2str(elapsedTime) '!'])

    % add elapsed time to corresponding array
    clkArr(dim/2) = elapsedTime;

    % increment excel row counter 
    rowCtExcel = rowCtExcel + 2;
end

disp(tab)
% writetable(tab, 'TableData.xlsx','WriteRowNames',true);
% winopen('TableData.xlsx'); % Opens in Excel

% write to log file 
toLog(-2);

function [strOut,coeffOut] = ...
    genStr(coeffArr,elementArr,addFirstSign)
        % return empty string if coeffArr or elementArr is
        % empty
        if isempty(coeffArr) | isempty(elementArr)
            strOut = "";
            coeffOut = "";
            return;
        end

        % get numerator and denumerator values from 
        % coefficients 
        [numArr,denArr] = rat(coeffArr);
        numArr = abs(numArr); % get the absolute value

        % find indices where coefficients are unusual
        negIndArr = coeffArr<0; % find negative 
        denIndArr = find(denArr==1); % find ./1 coeff
        numIndArr = ...
            numArr==1 & denArr==1; % find 1/1 coeff

        % # of coefficients 
        coeffNum = length(coeffArr);

        % initialize arrays
        signArr = repmat("+",1,coeffNum);
        numArr = string(numArr);
        denArr = string(denArr);
        fracArr = repmat("/",1,coeffNum);
        spcArr = repmat(" ",1,coeffNum);

        % apply corrections
        signArr(negIndArr) = "-";
        numArr(numIndArr) = "";
        denArr(denIndArr) = "";
        fracArr(denIndArr) = "";

        % if addFirstSign is not raised, remove 
        % sign and space of the first element
        % if sign is positive
        if ~addFirstSign
            if signArr(1) == "+"
                signArr(1) = "";
                spcArr(1) = "";
            end

            % join strings
            strOut = strjoin(signArr + spcArr + ... 
                numArr + fracArr + denArr + elementArr," ");
        else
                
            % add a space in front
            strOut = " " + strjoin(signArr + spcArr + ... 
                numArr + fracArr + denArr + elementArr," ");
        end

        % output coefficient string array
        negSignArr = signArr;
        negSignArr(~negIndArr) = ""; % remove + signs
        numArr(numIndArr) = "1"; % reinstert 1's
        coeffOut = negSignArr + numArr + fracArr + denArr;
end

% function to convert 
function colLetter = num2ExcelCol(n)
    colLetter = '';
    while n > 0
        r = mod(n - 1, 26);
        colLetter = [char(r + 'A') colLetter];
        n = floor((n - 1) / 26);
    end
end
