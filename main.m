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
dimMax = 20;

% global flags 
enableLog = 0;         % flag to enable log keeping
enableMatrixWrite = 1; % flag to enable errorenous matrix in
                       % log file (enableLog must be raised first)

% miscellanous 
txtForm = 1;       % the number of tab characters to be added
                   % in front of each row int log file. Choose 
                   %   - 1 for notepad   (1 tab = 8 spaces)
                   %   - 2 for notepad++ (1 tab = 4 spaces)
tolerance = 1e-10; % tolerance below which matrix elements are
                   % set as 0

%% CODE
% get the path to the repo folder
% (assumes that the main.m file is in this repo
doc = matlab.desktop.editor.getActive;
[repoPath,~,~] = fileparts(doc.Filename);

% add the path to the source folder 
addpath(fullfile(repoPath,"src"));

%%% folder paths 
params.paths.repoPath = repoPath; % path to the main repo
params.paths.matricesPath = fullfile(repoPath,'matrices');
params.paths.excelPath = fullfile(repoPath,'excel_files');
params.paths.logPath = fullfile(repoPath,'log.txt');
params.paths.backupPath = fullfile(repoPath,'backup');

% assign inputs 
params.flags.enableLog = enableLog;
params.flags.enableMatrixWrite = enableMatrixWrite;
params.misc.txtForm = txtForm;
params.misc.tolerance = tolerance;

% n = D/2
nMax = dimMax/2;

% if dimMin <= 2, throw error 
if dimMin <= 2
  error('Minimum dimension should be greater than 2!')
end 

% if both dimMin and dimMax are not even
% throw error
if mod(dimMin,2) == 1 || mod(dimMax,2) == 1
    error('Dimensions must be even integers!')
end

% if dimMax is less than dimMin, throw error
if dimMax < dimMin
    error('dimMax should not be less than dimMin!')
end

% get current date and time for storing the starting
% time 
currentDateTime = datetime('now');

% check for log file, generate if it does not exist
logPath = params.paths.logPath;
if ~exist(logPath,"file") && params.flags.enableLog
    fid = fopen(logPath, 'w'); 
    fclose(fid);
end

% write to log file 
toLog(params,-3);

% create backup folder if it does not exist 
if ~exist(params.paths.backupPath,'dir')
    mkdir(params.paths.backupPath);
end

% flags to check the existence of data 
% if there is data, move it to backup
matrixFlag = 0;
excelFlag = 0;

% create folders to store matrices, also moves
% the existing matrices folder (if there is) to backup 
matricesPath = params.paths.matricesPath;
if ~exist(matricesPath,'dir')
    % create matrices folder if it does not exist
    mkdir(matricesPath);
else 
    % check whether the matrices folder is empty 
    contents = dir(matricesPath);
    contents = contents(~ismember({contents.name}, ...
        {'.', '..'}));
    % raise flag if folder is not empty
    if ~isempty(contents)
        matrixFlag = 1;
    end
end

% create folders to store excel files, also moves
% the existing excel folder (if there is) to backup 
excelPath = params.paths.excelPath;
if ~exist(excelPath,'dir')
    % create matrices folder if it does not exist
    mkdir(excelPath);
elseif ~isempty(excelPath)
    % check whether the excel folder is empty 
    contents = dir(excelPath);
    contents = contents(~ismember({contents.name}, ...
        {'.', '..'}));
    % raise flag if folder is not empty
    if ~isempty(contents)
        excelFlag = 1;
    end
end

% if there is data, create a new backup folder 
if matrixFlag || excelFlag
    % load date-time info of the previous execution
    prevDateTime = load(...
        fullfile(params.paths.repoPath,'startTime.mat'));
    prevDateTime = prevDateTime.currentDateTime;
    prevDateTime.Format = 'ddMMyyyy_HHmmss';
    prevDateTime = char(prevDateTime);

    % create backup folder for the previous data
    backupFolder = ...
        fullfile(params.paths.backupPath,prevDateTime);
    mkdir(backupFolder);

    % move previous matrices folder in the backup folder
    if matrixFlag
        % create matrices folder under the backup folder
        backupMatricesPath = ...
            fullfile(backupFolder,'matrices');
        % move matrices folder into the backup folder 
        movefile(matricesPath,backupMatricesPath);
        % recreate the original folder 
        mkdir(matricesPath);
    end

    % move previous excel folder in the backup folder
    if excelFlag
        % create excel folder under the backup folder
        backupExcelPath = ...
            fullfile(backupFolder,'excel_files');
        % move matrices folder into the backup folder 
        movefile(excelPath,backupExcelPath);
        % recreate the original folder 
        mkdir(excelPath);
    end
end

% delete previous date-time info 
if exist(fullfile(params.paths.repoPath,"startTime.mat"),"file")
    delete(fullfile(params.paths.repoPath,"startTime.mat"));
end

% create date-time info for the current session
save(fullfile(params.paths.repoPath,'startTime.mat'), ...
    "currentDateTime");

% array of dimensions
dimArr = dimMin:2:dimMax;

% clear unused variables
clearvars -except params nMax dimArr dimMin dimMax

% create subfolders of different dimensions
for dim = dimArr
    % subfolder path
    dimPath = fullfile(params.paths.matricesPath, ...
        ['D' num2str(dim)]);

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
    rowNames{row} = ['D' num2str(2*row)];
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
    disp(['Calculation of D' num2str(dim)...
        ' started!'])
    toLog(params,0,['Calculation of D' num2str(dim) ...
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
    writematrix(string(dim) + "D",totDerivExcelPath, ...
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
    disp(['Calculation of D' num2str(dim) ...
        ' is complete in ' num2str(elapsedTime) '!'])
    toLog(params,0,['Calculation of D' num2str(dim) ...
        ' is complete in ' num2str(elapsedTime) '!'])

    % add elapsed time to corresponding array
    clkArr(dim/2) = elapsedTime;

    % increment excel row counter 
    rowCtExcel = rowCtExcel + 2;

    % display warnings if any
    if ~isempty(params.warnings)
        msg = strjoin(params.warnings,'\n');
        warndlg(sprintf(msg),['D' num2str(dim) ' errors:']);
    end
end

% disp(tab) % uncomment for displaying table in the 
            % command window
writetable(tab,fullfile(params.paths.excelPath,'coeffExcel.xlsx'),...
    'WriteRowNames',true);

% close all files 
fclose('all');

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
