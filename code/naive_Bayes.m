function [y,testPos,p_error]=naive_Bayes(Xtrain,ytrain,Xtest,ytest)

% Estimate the parameters of P(x|y) and P(y) from training data
% where Xtrain is the n by m matrix of training data
% ytrain is the n by 1 vector of label for the training data
% Xtest is the testing data
% ytest is the labels for the testing data
% y is the prediction labels
% yscore is the label scores for the for ROC analysis
% p_error is the percent error from the classification

classes=unique(ytrain); % get the class labels

nClass=length(classes); % get the number of classes

[nTrain, nFeature]=size(Xtrain); % get the number of training data and features
[nTest, nFeature]=size(Xtest); % get the number of testing data

thetaClass=zeros(nClass,1); % Define Pr(y=class)
thetajClass=zeros(nClass,nFeature); % Pr(x_j=1|y=class)
testPos=zeros(nTest,nClass); % Posterior of test data

for iClass=1:nClass
    
    thetaClass(iClass)=mean(ytrain==classes(iClass)); % derived formula
    % number of examples where y=class / number of examples
    
    thetajClass(iClass,:)=(sum(Xtrain(ytrain==classes(iClass),:)>0)+1)./ ...
        sum(sum(Xtrain(ytrain==classes(iClass),:)>0)+1); % Similarly
    % number of examples where x_j=1 and y=class / number of examples where
    % y=class
    % +1 for Laplace smoothing when a word is not observed in the training
    % data
    
    % log likelihood
    logL=(Xtest>0)*(log(thetajClass(iClass,:)))';
    
    % naive Bayes decision boundary
    testPos(:,iClass)=logL+(log(thetaClass(iClass))*ones(nTest,1));
    testPos(:,iClass)=testPos(:,iClass)-max(testPos(:,iClass));
    
end

% multi-class classification, select the class with the highest probability
[maxP,testP]=max(testPos,[],2);

y=classes(testP); % predicted class labels
p_error=mean(y~=ytest); % percent error of classification

% Get actual label scores for the ROC analysis
% yscore=exp(testPos)./repmat(sum(exp(testPos),2),1,nClass);
% yscore(isnan(yscore))=0.5;
% Laplace smoothing if there are no example from that class, it reduces a
% prior probability of 0.5