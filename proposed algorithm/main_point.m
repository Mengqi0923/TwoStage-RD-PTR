clc
clear all
close all

% x = 0:0.1:1;
x = [0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1];
cost = [1020.432224 1007.835902 996.6757636 987.6196552 974.2129857 963.0543681 953.2250521 944.070797 931.6682991 921.1558553 909.5410291];
profit = [2.245177752 2.205412584 2.175601125 2.152609828 2.144931926 2.11975032 2.041484157 2.043082192 2.032348227 2.003318121 1.966234751];
cost1 = (1037.3-cost)/100;

figure(1)
bar(cost1)
ylim([0 1.6])
xti = [1 2 3 4 5 6 7 8 9 10 11];
set(gca,'FontName','Times New Roman','FontSize',10,'xtick',xti,'xtickLabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
xlabel('The probability that passengers accept the recommendation')
ylabel('Reduced cost of orders ($)')

figure(2)
bar(profit)
ylim([0 3])
xti = [1 2 3 4 5 6 7 8 9 10 11];
set(gca,'FontName','Times New Roman','FontSize',10,'xtick',xti,'xtickLabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
xlabel('The probability that passengers accept the recommendation')
ylabel('Profit of robotaxis ($)')


cost2 = [1020.841692	1016.857019	1010.313082	1008.335162	1006.040062	999.7613533	994.9180288	992.6914015	985.2547664	981.5069151	977.412457];
profit2 = [2.278155945	2.285634737	2.239312601	2.259640074	2.260995798	2.243777583	2.230698351	2.223653241	2.20098161	2.20135757	2.175537956];
cost2 = (1037.3-cost2)/100;

figure(3)
bar(cost2)
ylim([0 1])
xti = [1 2 3 4 5 6 7 8 9 10 11];
set(gca,'FontName','Times New Roman','FontSize',10,'xtick',xti,'xtickLabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
xlabel('The probability that passengers accept the recommendation')
ylabel('Reduced cost of orders ($)')

figure(4)
bar(profit2)
ylim([1 3])
xti = [1 2 3 4 5 6 7 8 9 10 11];
set(gca,'FontName','Times New Roman','FontSize',10,'xtick',xti,'xtickLabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
xlabel('The probability that passengers accept the recommendation')
ylabel('Profit of robotaxis ($)')

cost3 = [1021.3476	1016.013707	1010.176038	1005.118279	997.1011301	991.9321211	985.8936065	983.8328035	975.3818328	971.1728885	965.2613682];
profit3 = [2.302552887	2.278682051	2.311924225	2.303271007	2.295772767	2.285992322	2.301876751	2.291622395	2.251512403	2.29508365	2.287233033];
cost3 = (1037.3-cost3)/100;

figure(5)
bar(cost3)
ylim([0 1])
xti = [1 2 3 4 5 6 7 8 9 10 11];
set(gca,'FontName','Times New Roman','FontSize',10,'xtick',xti,'xtickLabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
xlabel('The probability that passengers accept the recommendation')
ylabel('Reduced cost of orders ($)')

figure(6)
bar(profit3)
ylim([1 3])
xti = [1 2 3 4 5 6 7 8 9 10 11];
set(gca,'FontName','Times New Roman','FontSize',10,'xtick',xti,'xtickLabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
xlabel('The probability that passengers accept the recommendation')
ylabel('Profit of robotaxis ($)')


cost4 = [990.4306173	988.5563083	982.6998155	978.979188	968.6967162	966.394427	961.2702842	954.8187461	955.8950853	950.6988606	943.7520727];
profit4 = [2.265027593	2.260172356	2.239075162	2.237468134	2.177844079	2.186311617	2.159662556	2.134595741	2.128251829	2.100965279	2.070631371];
cost4 = (1037.3-cost4)/100;

figure(5)
bar(cost4)
ylim([0 1])
xti = [1 2 3 4 5 6 7 8 9 10 11];
set(gca,'FontName','Times New Roman','FontSize',10,'xtick',xti,'xtickLabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
xlabel('The probability that passengers accept the recommendation')
ylabel('Reduced cost of orders ($)')

figure(6)
bar(profit4)
ylim([1 3])
xti = [1 2 3 4 5 6 7 8 9 10 11];
set(gca,'FontName','Times New Roman','FontSize',10,'xtick',xti,'xtickLabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
xlabel('The probability that passengers accept the recommendation')
ylabel('Profit of robotaxis ($)')


cost5 = [996.6098644	988.3134891	984.6213721	977.5306156	974.8919296	965.9176179	959.5962197	957.0401858	951.692086	944.3538204	938.4677227];
profit5 = [2.200081925	2.188178359	2.215042531	2.184773238	2.189749532	2.151677042	2.182668484	2.187332078	2.152344211	2.143839366	2.148739525];
cost5 = (1037.3-cost5)/100;

figure(7)
bar(cost5)
ylim([0 1])
xti = [1 2 3 4 5 6 7 8 9 10 11];
set(gca,'FontName','Times New Roman','FontSize',10,'xtick',xti,'xtickLabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
xlabel('The probability that passengers accept the recommendation')
ylabel('Reduced cost of orders ($)')

figure(8)
bar(profit5)
ylim([1 3])
xti = [1 2 3 4 5 6 7 8 9 10 11];
set(gca,'FontName','Times New Roman','FontSize',10,'xtick',xti,'xtickLabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'});
xlabel('The probability that passengers accept the recommendation')
ylabel('Profit of robotaxis ($)')