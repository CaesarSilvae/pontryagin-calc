% OVERWRITES ALREADY EXISTING SAVED MATRICES!
% 
% dim should be an even intege;
% matList is a cell containing info about
% matrices to be saved in the form 
% {'name1',[...],'name2',[...],...};
% all the matrices is to be saved in the 
% folder corresponding to dimension 'dim'
% and # of (dw)'s 'partialNum;
% if errorFlag is raised, '_ERRONEOUS' at 
% the end of the file name
function saveMat(dim,partialNum,matList,errorFlag)

    % path to folder 
    dimName = ['D-' num2str(dim)];
    dwName = [num2str(partialNum) '-' ...
        num2str(dim/2-partialNum)];
    fileExt = ['_' dwName];
    folderPath = fullfile(pwd,'matrices',dimName, ...
        dwName);

    % iterate through matrices
    for matCt = 1:(length(matList)/2)
        % get matrix 
        mat = matList{2*matCt};

        % skip if matrix is empty 
        if isempty(mat)
            continue;
        end

        % get matrix name and ending text
        matName = [matList{2*matCt-1} fileExt];

        % check error flag and generate file name
        if errorFlag
            fileName = [matName '-ERRONEOUS' '.mat'];
        else 
            fileName = [matName '.mat'];
        end

        % save matrix
        matPath = fullfile(folderPath,fileName);
        save(matPath,'mat');

    end
end
