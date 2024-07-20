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

% 乘客意愿
prob_time = 0.5; % 乘客同意时间推荐的比例
prob_point = 0.5; % 乘客同意地点推荐的比例
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

figure(6)
scatter(unit_profit2, total_fare2)
set(gca,'XDir','reverse'); 
xlabel("unit profit")
ylabel("total fare")
title("初始种群目标函数值分布（二）")

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

output=sortrows(functionvalue2(frontvalue2==1,:));

%% 结果展示
figure(7)
plot(1:Gmax,min_fare2)
xlabel("iteration count")
ylabel("total fare")
title("乘客出行成本迭代过程")

figure(8)
plot(1:Gmax,max_profit2)
xlabel("iteration count")
ylabel("unit profit")
title("乘客每公里利润迭代过程")

figure(9)
scatter(cF-output(:,2),output(:,1))
set(gca,'XDir','reverse'); 
xlabel("unit profit")
ylabel("total fare")
title("Pareto前沿")

