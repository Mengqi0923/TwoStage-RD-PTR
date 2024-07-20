% 包含两个阶段：
% 第一阶段：优化时间与地点
% 第二阶段：优化路径
% 加入循环（不同比例）
clc
clear all
close all

tic
%% -----------------------第一阶段---------------------------
%% 模型数据
points = importdata("points_30min_100.txt");   % 所有集合中的坐标点，包括了原上下车点
% sets_index = importdata("merged_set_index.txt");
distances = importdata("distances_30min_100.txt");   % 距离矩阵
distances_km = distances/1000;

% 候选点集合，每个集合第一个元素为原点，其余元素为候选点
filename = 'merged_set_index_30min_100.txt';
fileID = fopen(filename, 'r');
sets = zeros(200,10);

line = fgetl(fileID);
row = 1;
while ischar(line)
    elements = str2double(strsplit(line));
    validElements = elements(~isnan(elements));
    sets(row,1:length(validElements)) = validElements;
    line = fgetl(fileID);
    row = row + 1;
end
fclose(fileID);

ls = sum(sets ~= 0, 2); % 记录每个集合中点的个数（包含了初始上下车点）


% 出租车初始位置与订单原上车点的距离(随机生成)
d_t2o = importdata("distance_taxi_order.txt");



% 原上车时间
pick_up_time = importdata("pickup_time_30min_100.txt")'; % 上车时间




%%  问题参数设置
num_taxi = length(pick_up_time);                  % 出租车数量
num_order = length(pick_up_time);                 % 订单数量
max_capacity = 4;               % 出租车最大容量
min_time = -10;                 % 最大提前时间偏移
max_time = 10;                  % 最大延后时间偏移
max_detour = 2;                 % 最大绕道率
max_walk = 300;                 % 最大总步行距离600米（原300米）
v_taxi = 500;                   % 出租车速度 30km/h



v_walk = 100;                   % 步行速度 6km/h

cF = 2.18;                      % 单位里程价格
cE = 0.4;                       % 单位里程成本
base_fare = 3;                  % 起步价
% min_distance = 0.32;          % 起步价的最大里程（km）
alpha = 0.1;                    % 绕道折扣系数0.1
bata = 0.2;                     % 步行折扣系数
lambd = 0.2;                    % 时间折扣系数

%%  算法参数设置
pop_size = 200;                 % 种群规模
maxG = 2000;                    % 最大迭代次数
w = 0.8;                        % 惯性权重  
c1 = 0.5;                       % 自我学习因子  
c2 = 0.5;                       % 群体学习因子
min_v = -2;                     % 最小速度
max_v = 2;                      % 最大速度

% 订单原位置之间的距离
distance_od = zeros(2*num_order,2*num_order);
for i = 1:2*num_order
    for j = i:2*num_order
        distance_od(i,j) = distances_km(sets(i,1),sets(j,1));
        distance_od(j,i) = distance_od(i,j);
    end
end

% 筛选行程相似的订单，matches(i,j)=1,说明行程相似
matches = IsCarpool(num_order,pick_up_time,points,sets);
% figure(1)
% mesh(matches)


%% 种群初始化

length_code1 = num_taxi * max_capacity * 2;
% 计算原价
[original_fare, original_distances] = InitialFare(distance_od,num_order,cF, base_fare);

Chrom1 = init1(pop_size, num_order, min_time, max_time,matches,pick_up_time);  % 上车时间种群
Chrom2 = init2(sets, ls, pop_size, num_order,matches,points);  % 上下车点种群
Chrom3 = init3(Chrom1, Chrom2, pop_size, num_taxi, num_order, max_capacity, pick_up_time, distances_km,v_taxi, sets, max_detour, original_distances,matches,d_t2o);

%% 计算初始目标函数

% 计算两个目标值
[total_fare, unit_profit] = ObjectiveFunction(Chrom1, Chrom2, Chrom3, alpha, bata, lambd, sets, ls, num_order, num_taxi, max_capacity, original_fare, original_distances, distances_km ,cE, max_walk, max_detour, base_fare);
initfare = total_fare;
initprofit = unit_profit;
avg_fare = (sum(original_fare)-total_fare)/num_order;
%% 执行k均值聚类
data = [initprofit, initfare];
k = 1;  % 聚类的数量
[idx, C] = kmeans(data, k);   % 确定聚类中心

figure(1)

scatter(initprofit, initfare)
set(gca,'XDir','reverse'); 
xlabel("unit profit")
ylabel("total fare")
title("初始种群目标函数值分布")

functionvalue = [total_fare, cF-unit_profit];
frontvalue = nondominated_sort(functionvalue);
v = (max_v - min_v) * rand(size(Chrom1)) + min_v;   % 初始速度
p1 = 0.3;
p2 = 0.8;
p3 = 0.4;
min_fare = inf(maxG,1);
max_profit = zeros(maxG,1);
Chrom = [Chrom1, Chrom2, Chrom3];



% figure(1)  
%% 群体更新  
iter = 1;
while iter <= maxG
    IsChange = zeros(pop_size,1);
    paretoSet = Chrom1(find(frontvalue==1),:);   % 序值为1的Pareto解集    
    [newChrom1, newv, IsChange] = UpdateTime_1(Chrom1, Chrom3, num_taxi, max_capacity, min_time, max_time, paretoSet, v, w, c1, min_v, max_v, p1, IsChange);   % 更新种群1   
    [newChrom2, IsChange] = UpdatePoint(Chrom2, sets, ls, p3, IsChange);                                                         % 更新种群3
    [newChrom3, IsChange] = UpdateRoute_3(Chrom1, Chrom3, newChrom1, newChrom2, pick_up_time, num_order, num_taxi, max_capacity, p2, distances, v_taxi, sets, IsChange);     % 更新种群2
    % 修正函数
    [newChrom1, newChrom2, newChrom3] = correction_1(newChrom1, newChrom2, newChrom3, distances_km, sets, ls, num_taxi, max_capacity, max_detour, original_distances, min_time, max_time, pick_up_time, v_taxi);
    % 计算目标函数值
    [new_total_fare, new_unit_profit] = ObjectiveFunction(newChrom1, newChrom2, newChrom3, alpha, bata, lambd, sets, ls, num_order, num_taxi, max_capacity, original_fare, original_distances, distances_km ,cE, max_walk, max_detour, base_fare);
    new_functionvalue = [new_total_fare, cF-new_unit_profit];

    % 以质心为基准，选择均优于质心的个体
    % 筛选个体，只保留费用不大于原费用且利润不小于原利润的个体（原费用和原利润是指初始种群的聚类中心的）
    condition = new_functionvalue(:,1)<=C(2) & cF-new_functionvalue(:,2)>=C(1);
    % 新的种群
    newChrom1 = newChrom1(condition,:);
    newChrom2 = newChrom2(condition,:);
    newChrom3 = newChrom3(condition,:);
    new_functionvalue = new_functionvalue(condition,:);

    newChrom1 = [Chrom1;newChrom1];
    newChrom2 = [Chrom2;newChrom2];
    newChrom3 = [Chrom3;newChrom3];
    functionvalue = [functionvalue; new_functionvalue];
    
    % 非支配排序
    frontvalue = nondominated_sort(functionvalue);
    % 计算拥挤距离、精英选择   
    newChrom = [newChrom1, newChrom3, newChrom2];
    newv = [newv;v];

    [Chrom, functionvalue, v] = crowdingDistance(functionvalue, frontvalue, Chrom, newChrom, v, newv);
    Chrom1 = Chrom(:,1:num_order);
    Chrom3 = Chrom(:,num_order+1:num_order+num_taxi*max_capacity);
    Chrom2 = Chrom(:,num_order+num_taxi*max_capacity+1:end);

%     % 非支配排序
    frontvalue = nondominated_sort(functionvalue);
    total_fare = functionvalue(:,1);
    unit_profit = cF - functionvalue(:,2);
    min_fare(iter) = min(total_fare);
    max_profit(iter) = max(unit_profit);
    p1 = 0.3 * (1-iter/maxG);   
    p2 = 0.8 * (1-iter/maxG);
    p3 = 0.4 * (1-iter/maxG);
    iter = iter+1;  
end
toc

frontvalue = nondominated_sort(functionvalue);
output=sortrows(functionvalue(frontvalue==1,:));
%% 结果展示
figure(2)
plot(1:maxG,min_fare)
xlabel("iteration count")
ylabel("total fare")
title("乘客出行成本迭代过程")

figure(3)
plot(1:maxG,max_profit)
xlabel("iteration count")
ylabel("unit profit")
title("乘客每公里利润迭代过程")

figure(4)
scatter(unit_profit,total_fare)
set(gca,'XDir','reverse'); 
xlabel("unit profit")
ylabel("total fare")
title("Pareto前沿")



% 筛选pareto解集，只保留费用不大于原费用且利润不小于原利润的个体（原费用和原利润是指初始种群的聚类中心的）
condition = output(:,1)<=C(2) & cF-output(:,2)>=C(1);
% 新的Pareto解集
new_Pareto = output(condition,:);
maxfare = max(new_Pareto(:,1));
minfare = min(new_Pareto(:,1));
maxprofit = max(cF-new_Pareto(:,2));
minprofit = min(cF-new_Pareto(:,2));
% 对新Pareto解集的目标值做归一化处理
norm_Pareto = [(new_Pareto(:,1)-minfare)/(maxfare-minfare), ((cF-new_Pareto(:,2))-minprofit)/(maxprofit-minprofit)];
med_Pareto = median(norm_Pareto);
% 找出最接近中位数的最优个体
[med_P, med_I] = min(sqrt((norm_Pareto(:,1)-med_Pareto(1)).^2 + (norm_Pareto(:,2)-med_Pareto(2)).^2));


figure(5)
% 显示聚类结果
gscatter(data(:,1), data(:,2), idx);
hold on;
scatter(initprofit, initfare, 'b')
hold on;
scatter(cF-output(:,2), output(:,1), 'r')
hold on;
scatter(cF-new_Pareto(:,2), new_Pareto(:,1), 'yellow')
hold on;
plot(C(:,1), C(:,2), 'gp','MarkerFaceColor','g', 'MarkerSize', 10);
hold on;
plot(cF-new_Pareto(med_I,2), new_Pareto(med_I,1), 'g*', 'MarkerSize', 10);
set(gca,'XDir','reverse');   % x轴反向
hold off;
xlabel("unit profit")
ylabel("total fare")
title("目标函数值分布")



bestfunc = [new_Pareto(med_I,1), cF-new_Pareto(med_I,2)];


%% -----------------------第二阶段---------------------------
%% 问题参数
v_taxi = 0.5;                   % 出租车速度 30km/h
max_walk = 0.6;                 % 最大步行距离 0.6km
%% 算法参数
popsize2 = 200;                 % 种群大小
Gmax = 1000;                     % 最大迭代次数



% 记录第一阶段的最佳个体
f_c = [functionvalue,Chrom];
new_f_c=sortrows(f_c(frontvalue==1,:));
outputChrom = new_f_c(:,3:end);
new_Pareto_Chrom = outputChrom(condition,:);
bestIndividual = new_Pareto_Chrom(med_I,:); % 最佳个体
I_Chrom1_bestIndividual = bestIndividual(1:num_order); % 时间偏移量
Chrom3_bestIndividual = bestIndividual(:,num_order+1:num_order+num_taxi*max_capacity); % 路径
I_Chrom2_bestIndividual = bestIndividual(:,num_order+num_taxi*max_capacity+1:end); % 上下车点

avg_fare = zeros(10,10);
avg_profit = zeros(10,10);
%% 循环
at = [0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1];
ap = at;

for pi=1:length(at) 
for K=1:10 % 循环多次取平均值
% 乘客意愿
prob_time = at(6); % 乘客同意时间推荐的比例
prob_point = ap(pi); % 乘客同意地点推荐的比例
willingness_time = 1*(rand(1,num_order)<prob_time);
willingness_point = 1*(rand(1,num_order)<prob_point);
Chrom1_bestIndividual = I_Chrom1_bestIndividual .* (willingness_time==1) + zeros(1,num_order) .* (willingness_time==0);
Chrom2_bestIndividual = [I_Chrom2_bestIndividual(1:num_order) .* (willingness_point==1) + ones(1,num_order) .* (willingness_point==0), I_Chrom2_bestIndividual(num_order+1:end) .* (willingness_point==1) + ones(1,num_order) .* (willingness_point==0)];

newtime = pick_up_time + Chrom1_bestIndividual;
% 新上下车点之间的距离
new_distances_km = zeros(num_order*2,num_order*2);
for i=1:size(new_distances_km,1)
    for j=1:size(new_distances_km,2)
        if i~=j
            new_distances_km(i,j) = distances_km(sets(i,Chrom2_bestIndividual(i)),sets(j,Chrom2_bestIndividual(j)));
        end
    end
end
% 步行与时间折扣
discount = zeros(num_order,1);
for i=1:num_order
    discount(i) = bata * (distances_km(sets(i,1),sets(i,Chrom2_bestIndividual(i))) + distances_km(sets(i+num_order,1),sets(i+num_order,Chrom2_bestIndividual(i+num_order)))) / max_walk + lambd * abs(Chrom1_bestIndividual(i))/10;
end
routeChrom = initRoute(popsize2, num_order, num_taxi, newtime, new_distances_km, max_capacity, v_taxi, max_detour);
rand_index = randi(popsize2);
routeChrom(rand_index,:) = Chrom3_bestIndividual;
[total_fare2,unit_profit2] = newObjectiveFunction(routeChrom,alpha, discount, num_order, num_taxi, max_capacity, original_fare, original_distances, cE, max_detour, base_fare,new_distances_km);

functionvalue2 = [total_fare2, cF-unit_profit2];
frontvalue2 = nondominated_sort(functionvalue2);

% figure(6)
% scatter(unit_profit2, total_fare2)
% set(gca,'XDir','reverse'); 
% xlabel("unit profit")
% ylabel("total fare")
% title("初始种群目标函数值分布（二）")

min_fare2 = inf(Gmax,1);
max_profit2 = zeros(Gmax,1);

for g=1:Gmax
    newrouteChrom = Evolution(routeChrom, popsize2, num_order, num_taxi, max_capacity,new_distances_km,max_detour,original_distances,newtime, d_t2o,v_taxi);
    [new_total_fare,new_unit_profit] = newObjectiveFunction(newrouteChrom,alpha, discount, num_order, num_taxi, max_capacity, original_fare, original_distances, cE, max_detour, base_fare,new_distances_km);
    new_functionvalue2 = [new_total_fare,cF-new_unit_profit];
    combine_routeChrom = [routeChrom;newrouteChrom];
    combine_functionvalue2 = [functionvalue2;new_functionvalue2];
    combine_frontvalue2 = nondominated_sort(combine_functionvalue2);
    [routeChrom, functionvalue2] = crowdingDistance2(combine_functionvalue2, combine_frontvalue2, routeChrom, combine_routeChrom);
    % 非支配排序
    frontvalue2 = nondominated_sort(functionvalue2);
    total_fare2 = functionvalue2(:,1);
    unit_profit2 = cF - functionvalue2(:,2);
    min_fare2(g) = min(total_fare2);
    max_profit2(g) = max(unit_profit2);
end

output2=sortrows(functionvalue2(frontvalue2==1,:));


avg_fare(pi,K) = mean(output2(:,1));
avg_profit(pi,K) = mean(cF-output2(:,2));

end
end
%% 结果展示
% figure(7)
% plot(1:Gmax,min_fare2)
% xlabel("iteration count")
% ylabel("total fare")
% title("乘客出行成本迭代过程")
% 
% figure(8)
% plot(1:Gmax,max_profit2)
% xlabel("iteration count")
% ylabel("unit profit")
% title("乘客每公里利润迭代过程")
% 
% figure(9)
% scatter(cF-output2(:,2),output2(:,1))
% set(gca,'XDir','reverse'); 
% xlabel("unit profit")
% ylabel("total fare")
% title("Pareto前沿")