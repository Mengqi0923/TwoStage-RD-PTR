function routeChrom = initRoute(popsize2, num_order, num_taxi, newtime, new_distances_km, max_capacity, v_taxi, max_detour)
%initRoute 第二阶段种群初始化
%   此处提供详细说明
routeChrom = zeros(popsize2,num_taxi*max_capacity);
for i=1:size(routeChrom,1)
    orders = randperm(num_order);
    remaining_order = zeros(num_order,1); % 记录剩余订单
    carpoolorder = zeros(num_order/2,max_capacity);
    for j=1:num_order/2
        suborders = orders(2*j-1:2*j); % 两个订单
        if newtime(suborders(1))>newtime(suborders(2))
            suborders = [suborders(2), suborders(1)];
        end
        % 时间约束符合
        if new_distances_km(suborders(1),suborders(2))/v_taxi < newtime(suborders(2))-newtime(suborders(1))
            % 符合绕道率约束
            if new_distances_km(suborders(1),suborders(2)) + new_distances_km(suborders(2),suborders(1) + num_order) <= max_detour*new_distances_km(suborders(1),suborders(1) + num_order) ...
                    && new_distances_km(suborders(2),suborders(1) + num_order) + new_distances_km(suborders(1) + num_order, suborders(2) + num_order) <= max_detour*new_distances_km(suborders(2),suborders(2) + num_order)
                carpoolorder(j,:) = [suborders,suborders(1) + num_order, suborders(2) + num_order];
            elseif new_distances_km(suborders(1),suborders(2)) + new_distances_km(suborders(2),suborders(2)+num_order) + new_distances_km(suborders(2) + num_order, suborders(1) + num_order)...
                    <= max_detour*new_distances_km(suborders(1),suborders(1) + num_order)
                carpoolorder(j,:) = [suborders,suborders(2) + num_order, suborders(1) + num_order];
            elseif (new_distances_km(suborders(1),suborders(1)+num_order) + new_distances_km(suborders(1)+num_order,suborders(2)))/v_taxi < newtime(suborders(2))-newtime(suborders(1))
                carpoolorder(j,:) = [suborders(1), suborders(1) + num_order, suborders(2), suborders(2) + num_order];
            else % 不符合约束，只添加第一个订单
                carpoolorder(j,1:2) = [suborders(1),suborders(1)+num_order];
                remaining_order(suborders(2)) = 1;
            end
        else % 不符合约束，只添加第一个订单
            carpoolorder(j,1:2) = [suborders(1),suborders(1)+num_order];
            remaining_order(suborders(2)) = 1;
        end      
    end
    % 记录所有订单的匹配
    count = sum(remaining_order);
    match_order = zeros(num_taxi,max_capacity);
    match_order(1:num_order/2,:) = carpoolorder;
    k = num_order/2+1;
    % 分配剩余订单
    for j=1:num_order
        if remaining_order(j) == 1 % 该订单未被分配
            match_order(k,1:2) = [j,j+num_order];
            k = k + 1;
        end
    end
    randseq = randperm(num_taxi);
    for j = 1:num_taxi
        routeChrom(i,(j-1)*max_capacity+1:j*max_capacity) = match_order(randseq(j),:);
    end
end
end