% plot results
% binary classification (different amount of data)

errorbar(resv*100,mean(pAmtData,2),std(pAmtData,0,2)./sqrt(size(pAmtData,2)),'LineWidth',3,'Color','k')
errorbar(resv*100,mean(pAmtData,2),std(pAmtData,0,2)./sqrt(size(pAmtData,2)),'LineWidth',3,'Color','k')
ylabel('Performance (% correct)')
xlabel('Amount of data (% of total comments)')
set(gca,'XScale','log');
% set(gca,'XTick',1:size(pAmtData,1),'XTickLabel',{'4';'8';'16';'32';'64';'100'})
box off

%% roc curve

[X,Y,T,AUC] = perfcurve(y,yscore(:,1),0);
plot(X,Y,'b.-')
title('ROC Curve')
xlim([0 1])
ylim([0 1])
line([0,1],[0,1],'Color','k')
axis square
ylabel('P(True Positive)')
xlabel('P(False Positive)')
AUC
%% plot multiclass
% errorbar(numberClass,mean(pNumClass,2),std(pNumClass,0,2)./sqrt(size(pNumClass,2)),'LineWidth',3,'Color','k')
errorbar(numberClass,mean(pNumClass,2)-(100./numberClass)',std(pNumClass,0,2)./sqrt(size(pNumClass,2)),'LineWidth',3,'Color','k')
% hold on
% plot(numberClass,100./numberClass,'b--', 'LineWidth',3)
% legend('Classifier','Chance')
% legend boxoff
% ylabel('Performance (% correct)')
ylabel('Performance (% above chance)')
xlabel('Number of subreddits')
box off

%% confusion matrix 

conMat=confusionmat(ytest,y);
imagesc(conMat)
axis square
set(gca,'YTickLabel',{'sports';'books';'aww';'science';'funny';'movies'})
set(gca,'XTickLabel',{'sports';'books';'aww';'science';'funny';'movies'})
ylabel('Actual class')
xlabel('Predicted class')
set(gca,'FontSize',12,'fontWeight','bold')
colorbar
