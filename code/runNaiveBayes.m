% runNaiveBayes.m
% run the naive Bayes text classifier and perform cross validation

clear all; close all; clc

% vary amount of data
% resv=[0.04 0.08 0.16 0.32 0.64 1];
resv=1;
% resv=0.001.*2.^(0:1:9);

% measure of performance, k-fold cross validation, k=10
k=10;

pAmtData=zeros(length(resv),k); % performance based on data

% binary classes
% dataRaw{1}=importdata('t3_1mzh0p_filtered.csv'); % data from class 0
dataRaw{1}=importdata('sports.csv');
dataRaw{1}=sparse(dataRaw{1}.data);
% dataRaw{2}=importdata('t3_1pn4cl_filtered.csv'); % data from class 1
dataRaw{2}=importdata('books.csv');
dataRaw{2}=sparse(dataRaw{2}.data);

% multi-class (6)
% % dataRaw{3}=importdata('t3_1mzc0l_filtered.csv'); % data from class 2
% dataRaw{3}=importdata('aww.csv');
% dataRaw{3}=sparse(dataRaw{3}.data);
% % dataRaw{4}=importdata('t3_1mzc7o_filtered.csv'); % data from class 3
% dataRaw{4}=importdata('science.csv');
% dataRaw{4}=sparse(dataRaw{4}.data);
% % dataRaw{5}=importdata('t3_1mzg22_filtered.csv'); % data from class 4
% dataRaw{5}=importdata('funny.csv');
% dataRaw{5}=sparse(dataRaw{5}.data);
% % dataRaw{6}=importdata('t3_1mzpxe_filtered.csv'); % data from class 5
% dataRaw{6}=importdata('movies.csv');
% dataRaw{6}=sparse(dataRaw{6}.data);
% % dataRaw{7}=importdata('news.csv');
% % dataRaw{7}=sparse(dataRaw{7}.data);
% % dataRaw{8}=importdata('pics.csv');
% % dataRaw{8}=sparse(dataRaw{8}.data);
% % dataRaw{9}=importdata('videos.csv');
% % dataRaw{9}=sparse(dataRaw{9}.data);

% vary number of classes
% numberClass=[2 3 4 5 6];
numberClass=[2];

pNumClass=zeros(length(numberClass),k);

for iCl=1:length(numberClass)
    
    numClass=zeros(1,numberClass(iCl));
    for iAmt=1:length(resv)

        % get number of Reddit comments for each class
        for iC=1:numberClass(iCl)
            numClass(iC)=size(dataRaw{iC},1);
        end

        numClass=numClass.*resv(iAmt); % vary the amount of data

        % k-fold cross validation, k=10
        numClass=floor(numClass./k).*k;

        % number of words in the dictionary
        numWord=size(dataRaw{1},2);

        % create n by m data matrix, where n is the number of Reddit comments and m
        % the number of words in the dictionary (features)
        data=zeros(sum(numClass),numWord);
        label=zeros(sum(numClass),1);
        data(1:numClass(1),:)=dataRaw{1}(1:numClass(1),:);
        label(1:numClass(1))=0;
        for iC=2:numberClass(iCl)        
            data(sum(numClass(1:iC-1))+1:sum(numClass(1:iC)),:)=dataRaw{iC}(1:numClass(iC),:);
            label(sum(numClass(1:iC-1))+1:sum(numClass(1:iC)))=iC-1;
        end

        % split data into training and testing sets
        perms=zeros(sum(numClass),1);
        perms(1:numClass(1))=randperm(numClass(1));
        for iC=2:numberClass(iCl)
            perms(sum(numClass(1:iC-1))+1:sum(numClass(1:iC)))=randperm(numClass(iC))+sum(numClass(1:iC-1)); % create random permutations
        end

        % k-fold cross-validation
        for ik=0:k-1

            % train with the k-1 groups
            idxTrain=zeros(sum(numClass)*(k-1)/k,1);
            idxTest=zeros(sum(numClass)/k,1); % test with the k group 
            if ik~=0 && ik~=k-1
                idxTrain(1:numClass(1)*(k-1)/k)=perms([1:numClass(1)/k*ik numClass(1)/k*(ik+1)+1:numClass(1)]);
            elseif ik==0
                idxTrain(1:numClass(1)*(k-1)/k)=perms(numClass(1)/k+1:numClass(1));
            else
                idxTrain(1:numClass(1)*(k-1)/k)=perms(1:numClass(1)/k*ik);
            end
            % test with the k group 
            idxTest(1:numClass(1)/k)=perms(numClass(1)/k*ik+1:numClass(1)/k*(ik+1));
            for iC=2:numberClass(iCl)
                if ik~=0 && ik~=k-1
                    idxTrain(sum(numClass(1:iC-1))*(k-1)/k+1:sum(numClass(1:iC))*(k-1)/k)=perms([sum(numClass(1:iC-1))+1:sum(numClass(1:iC-1))+numClass(iC)/k*ik sum(numClass(1:iC-1))+1+numClass(iC)/k*(ik+1):sum(numClass(1:iC))]);
                elseif ik==0
                    idxTrain(sum(numClass(1:iC-1))*(k-1)/k+1:sum(numClass(1:iC))*(k-1)/k)=perms(sum(numClass(1:iC-1))+1+numClass(iC)/k:sum(numClass(1:iC)));
                else
                    idxTrain(sum(numClass(1:iC-1))*(k-1)/k+1:sum(numClass(1:iC))*(k-1)/k)=perms(sum(numClass(1:iC-1))+1:sum(numClass(1:iC-1))+numClass(iC)/k*ik);
                end
                idxTest(sum(numClass(1:iC-1))/k+1:sum(numClass(1:iC))/k)=perms(sum(numClass(1:iC-1))+1+numClass(iC)/k*ik:sum(numClass(1:iC-1))+numClass(iC)/k*(ik+1));
            end        

            Xtrain=data(idxTrain,:);
            ytrain=label(idxTrain);
            Xtest=data(idxTest,:);
            ytest=label(idxTest);

            [y,yscore,pError]=naive_Bayes(Xtrain,ytrain,Xtest,ytest);

            display(sprintf('Accuracy %.2f', 100*(1-pError)));

            pAmtData(iAmt,ik+1)=1-pError;
        end

    end

    pAmtData=pAmtData*100;
    
%     pNumClass(iCl,:)=pAmtData'; % for 1 resv
end