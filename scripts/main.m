% \p\g -> 0, \g^2 -> 1
clear all; clear vars; clc;

% variable to store global parameters
params = struct();
params.paths = struct();
params.flags = struct();
params.misc = struct();
params.warnings = {};

%% INPUTS
% maximum dimension (must be an even number)
dimMin = 2;
dimMax = 34;

% global flags 
enableLog = 1;         % flag to enable log keeping
enableMatrixWrite = 0; % flag to enable errorenous matrix in
                       % log file (enableLog must be raised first)

% miscellanous 
txtForm = 2;       % the number of tab characters to be added
                   % in front of each row int log file. Choose 
                   %   - 1 for notepad   (1 tab = 8 spaces)
                   %   - 2 for notepad++ (1 tab = 4 spaces)
tolerance = 1e-10; % tolerance below which matrix elements are
                   % set as 0

%% CODE
%%% folder paths 
params.paths.matricesPath = fullfile(pwd,'..','matrices');
params.paths.excelPath = fullfile(pwd,'..','excel files');
params.paths.logPath = fullfile(pwd,'..','log.txt');
params.paths.backupPath = fullfile(pwd,'..','backup');

% assign inputs 
params.flags.enableLog = enableLog;
params.flags.enableMatrixWrite = enableMatrixWrite;
params.misc.txtForm = txtForm;
params.misc.tolerance = tolerance;

% n = D/2
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
toLog(params,-3);

% create backup folder if it does not exist 
if ~exist(params.paths.backupPath,'dir')
    mkdir(params.paths.backupPath);
end

% get current date and time for backup folder name
currentDateTime = ...
    char(datetime('now', 'Format', 'ddMMyyyy_HHmmss'));

% create backup folder 
backupFolder = ...
    fullfile(params.paths.backupPath,currentDateTime);
mkdir(backupFolder);

% create folders to store matrices, also moves
% the existing matrices folder (if there is) to backup 
backupMatricesPath = ...
    fullfile(backupFolder,'matrices');
matricesPath = params.paths.matricesPath;
if ~exist(matricesPath,'dir')
    % create matrices folder if it does not exist
    mkdir(matricesPath);
else
    % move matrices folder into the backup folder 
    movefile(matricesPath,backupMatricesPath);
    % recreate the original folder 
    mkdir(matricesPath);
end

% create folders to store excel files, also moves
% the existing excel folder (if there is) to backup 
backupExcelPath = ...
    fullfile(backupFolder,'excel files');
excelPath = params.paths.excelPath;
if ~exist(excelPath,'dir')
    % create matrices folder if it does not exist
    mkdir(excelPath);
else
    % move matrices folder into the backup folder 
    movefile(excelPath,backupExcelPath);
    % recreate the original folder 
    mkdir(excelPath);
end

% array of dimensions
dimArr = dimMin:2:dimMax;

% create subfolders of different dimensions
for dim = dimArr
    % subfolder path
    dimPath = fullfile(params.paths.matricesPath, ...
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
totDerivExcelPath = fullfile(params.paths.excelPath,...
    'totDerivExcel.xlsx');
rowCtExcel = dimMin-1;

% initialize clock array which will contain
% time elapsed for each dimension
clkArr = zeros(size(dimArr));

% main loop to iterate over dimensions from dimMin 
% up to dimMax
for dim = dimArr
    % reseet warnings for the next dimension
    params.warnings = {};

    % display dim started message
    % disp(totDerivStr);
    disp(['Calculation of D-' num2str(dim) ...
        ' started!'])
    toLog(params,0,['Calculation of D-' num2str(dim) ...
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
    writematrix("D-" + string(dim),totDerivExcelPath, ...
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
        [params,totDerivArr,totDerivCoeffArr] = ...
            derivGen(params,evenDoublewArr,evenCoeffArr);

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
            writematrix(totDerivArr,totDerivExcelPath,...
                'Range',strRange);
            writematrix(coeffStrArr, ...
                totDerivExcelPath, 'Range',coefRange);

            % increment columns counter
            colCtExcel = colCtExcel + length(totDerivArr);
        end
    end

    % display dim complete message
    % disp(totDerivStr);
    elapsedTime = toc(clk);
    disp(['Calculation of D-' num2str(dim) ...
        ' is complete in ' num2str(elapsedTime) '!'])
    toLog(params,0,['Calculation of D-' num2str(dim) ...
        ' is complete in ' num2str(elapsedTime) '!'])

    % add elapsed time to corresponding array
    clkArr(dim/2) = elapsedTime;

    % increment excel row counter 
    rowCtExcel = rowCtExcel + 2;

    % display warnings if any
    if ~isempty(params.warnings)
        msg = strjoin(params.warnings,'\n');
        warndlg(sprintf(msg),['D-' num2str(dim) ' errors:']);
    end
end

% disp(tab) % uncomment for displaying table in the 
            % command window
writetable(tab,fullfile(params.paths.excelPath,'coeffExcel.xlsx'),...
    'WriteRowNames',true);

% write to log file 
toLog(params,-2);

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

% function to convert column number to 
% excel column letter
function colLetter = num2ExcelCol(n)
    colLetter = '';
    while n > 0
        r = mod(n - 1, 26);
        colLetter = [char(r + 'A') colLetter];
        n = floor((n - 1) / 26);
    end
end