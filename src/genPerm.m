% function to generate permutations for a given D
% gives cell array in the increasing order of dw's
function permClassArr = genPerm(dim)

    % n = D/2
    n = dim/2;

    % maximum decimal that can be achieved using n bits 
    maxNum = 2^n-1;
    
    % generate array from 0 to maxNum 
    decNums = 0:maxNum;
    decNumsMask = ones(size(decNums)); % mask to keep track 
                                       % of which decimals have 
                                       % already been addressed
    
    % initialize cell array to hold permutation classes with 
    % different number of (dw)'s
    permClassArr = cell(1,n+1);
         
    % for loop to iterate over the decimals 
    for ct = 1:(maxNum+1)
    
        % check if the mask for the decimal 
        if decNumsMask(ct)
    
            % get the decimal number 
            decNum = decNums(ct);
            
            % find the cyclic shifts of the decimal
            [partialNum,decArr,~] = genCycPerm(decNum,n,true);
    
            % add the cyclic class to the cell containing 
            % permutation classes with the appropriate 
            % number of (dw)'s
            % (replace partialNum with end-partialNum to 
            % reverse dw and w^2 order, currently runs 
            % from w^max to w^0. Though it does not matter
            % due to symmetry) 
            permClassArr{partialNum+1}{end+1} = decArr; 
    
            % sort the cells depending on their lengths
            cellLens = cellfun(@length,permClassArr{partialNum+1});
            [~,indArr] = sort(cellLens,'descend');
            permClassArr{partialNum+1} = ...
                permClassArr{partialNum+1}(indArr);
            
            % turn off mask for the elements in decArr, +1 is 
            % added since the array starts from 0
            decNumsMask(decArr+1) = 0;
        end
    end
end