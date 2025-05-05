% logCode = -3 : start separator 
% logCode = -2 : end separator
% logCode = -1 : error
% logCode = 0 : normal text 
% logCode = otherwise : determine hierarchy
% log is either char or cell containing char 
% and numeric matrix in the order 
% {'a',[...],'b',[...],...}
function toLog(logCode,logVar)

    % the number of tab characters to be added
    % in front of each row. Choose 
    %   - 1 for notepad   (1 tab = 8 spaces)
    %   - 2 for notepad++ (1 tab = 4 spaces)
    form = 2;

    % if log is a matrix and logCode is not greater
    % than 0, throw error
    if nargin > 1
        txtFlag = isequal(class(logVar),'char');
        if logCode<1 && ~txtFlag
            error('logCode must be greater than 0 for matrix log!')
        end
    end

    % check for log file, generate if it does not exist
    filePath = fullfile(pwd,'log.txt');
    fileID = fopen(filePath,'a');

    if fileID == -1
        error('Failed to create the log file!')
    end

    % get time 
    timeStr = char(datetime("now"),'HH:mm:ss');
    dateStr = char(datetime("now"),'dd/MM/yyyy');

    % generate text to be written
    switch logCode
        case -3
            dispMsg = [dateStr ', ' timeStr ' ' repmat('=',1,79) '\n\n'];
        case -2
            dispMsg = ['\n' repmat('=',1,100) '\n\n'];
        case -1
            dispMsg = [' ERROR! ' timeStr ' : ' logVar '\n'];
            msgbox(['ERROR at ' timeStr ' : ' logVar]);
        case 0 
            dispMsg = [repmat('\t',1,form) timeStr ' : ' logVar '\n'];
        otherwise
            if txtFlag
                dispMsg = [repmat('\t',1,logCode+form) logVar '\n\n'];
            else
                % for loop to iterate through matrices
                for matCt = 1:(length(logVar)/2)
                    fprintf(fileID,'\n');
                    matName = logVar{2*matCt-1};
                    mat = logVar{2*matCt};
                    writeMat(fileID,mat,logCode+form,matName)
                end

                % add another new line 
                fprintf(fileID,'\n');

                % close file
                fclose(fileID);

                % return function
                return;
            end
    end

    % write to file 
    fprintf(fileID,dispMsg);

    % close file 
    fclose(fileID);

end

% Function to write matrix name followed by the
% matrix itself to a text file, adds indentation
% in front. The elements are rounded to two decimals.
function writeMat(fileID,mat,tabNum,matName)

    % compute sizes 
    rowNum = size(mat,1);
    if nargin > 3
        nameLen = length(matName) + 3; % extra 3 for ' = '
    else
        nameLen = 0;
    end
    
    % find the row to which the name will be
    % aligned 
    midRow = ceil(rowNum/2);

    % write rows one by one, split loops to
    % get rid of if condition
    for rowCt = 1:(midRow-1)
        % padding spaces 
        padding = [repmat('\t',1,tabNum) ...
            repmat(' ',1,nameLen)];

        % row to be written
        rowTxt = ...
            ['[' strtrim(sprintf('%+10.2f ', mat(rowCt,:))) ']'];

        % write to file 
        fprintf(fileID,[padding '%s\n'],rowTxt);

    end

    % write the middle row
    padding = repmat('\t',1,tabNum);
    rowTxt = [matName ' = ' ...
            '[' strtrim(sprintf('%+10.2f ', mat(rowCt,:))) '],'];
    fprintf(fileID,[padding '%s\n'],rowTxt);

    for rowCt = (midRow+1):rowNum
        % padding spaces 
        padding = [repmat('\t',1,tabNum) ...
            repmat(' ',1,nameLen)];

        % row to be written
        rowTxt = ...
            ['[' strtrim(sprintf('%+10.2f ', mat(rowCt,:))) ']'];

        % write to file 
        fprintf(fileID,[padding '%s\n'],rowTxt);
        
    end
end
