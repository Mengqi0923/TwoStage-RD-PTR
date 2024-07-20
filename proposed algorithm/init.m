function Chrom = init(length_code, pop_size, num_taxi, num_order, max_capacity, pick_up_time)
% init  种群初始化
% 输入：编码长度，种群大小，出租车数量，订单数量，车辆容量，上车时间
% 输出：种群
    Chrom = zeros(pop_size, length_code);

    for i = 1:pop_size
        routes = random_partition(1:num_order, num_taxi, max_capacity);  % 把订单随机分配给出租车

        for j = 1:num_taxi
            routes{j} = priority_sort(routes{j}, pick_up_time);  % 按照时间对订单重新排序
            route = [routes{j}, routes{j} + num_order];
            Chrom(i, (j-1)*max_capacity*2+1 : (j-1)*max_capacity*2+length(route)) = route;  % 将第j辆车的路线加入个体中
        end

        recommend_point = zeros(1, num_order*2);
        for j = 1:(num_order*2)
            s_length = length(s{j});
            recommend_point(j) = randi(s_length);  % 随机在集合中选一个点
        end

        Chrom(i, num_taxi*max_capacity*2+1:end) = recommend_point;
    end
end

function sorted_routes = priority_sort(routes, pick_up_time)
    [~, idx] = sort(pick_up_time(routes));
    sorted_routes = routes(idx);
end