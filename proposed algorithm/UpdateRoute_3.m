function [newChrom3, IsChange] = UpdateRoute_3(Chrom1, Chrom3, newChrom1, newChrom2, pick_up_time, num_order, num_taxi, max_capacity, p2, distances, v_taxi, sets, IsChange)
%UpdateRoute 更新种群第二部分（路径）
%   仅限于最多允许两辆车拼单
newChrom3 = Chrom3;
newtime = pick_up_time + newChrom1;   % 更新后的上车时间
isChange = newChrom1 - Chrom1;
new_max_capacity = max_capacity;
for i=1:size(newChrom3,1)
    if ~all(isChange(i,:)==0)   % 该个体有订单上车时间改变，则需重新调整订单上下车点的顺序
        against_order = [];
        for j=i:num_taxi
            route = newChrom3(i, (j-1)*new_max_capacity+1:j*new_max_capacity);
            route = route(route>0);
            if length(route)>2
                k = 2;
                while k<=length(route)
                    front_r = route(1:k-1);   % 计算时间，判断该订单是否违反时间约束
                    time_front = CaculateTime(front_r, num_order, newtime(i,:),distances, v_taxi, sets, newChrom2(i,:));
                    actual_time = time_front + distances(sets(route(k-1),newChrom2(i,route(k-1))),sets(route(k),newChrom2(i,route(k)))) / v_taxi;
                    if route(k)<=num_order
                        if actual_time>newtime(i,route(k))   % 违反时间约束
                            tag = 0;   % 标记是否调整了违反约束的订单，0为否，1为是
                            for kk=(k-1):-1:1
                                extime = CaculateTime(route(kk), num_order, newtime(i,:),distances, v_taxi, sets, newChrom2(i,:)) + distances(sets(route(kk),newChrom2(i,route(kk))),sets(route(k),newChrom2(i,route(k)))) / v_taxi;
                                if extime<=newtime(i,route(k))
                                    element = route(k);
                                    route = route(route ~= element);
                                    route = [route(1:kk), element, route(kk+1:end)];
                                    tag = 1;   % 标记已调整
                                    break;
                                end
                            end
                            if tag == 0   % 标记未调整
                                ele = route(k);
                                route = route(route~=ele);   % 在该路径中删除订单上车点
                                route = route(route~=ele+num_order);   % 在该路径中删除下车点
                                against_order = [against_order, ele];
                            end
                        end
                    end
                    k = k + 1;
                end
            end
            newChrom3(i, (j-1)*new_max_capacity+1:(j-1)*new_max_capacity+length(route)) = route;
            newChrom3(i, (j-1)*new_max_capacity+length(route)+1:j*new_max_capacity) = 0;

        end
        if ~isempty(against_order)   % 存在时间违约订单
            k = 1;
            for j=1:num_taxi
                if all(newChrom3(i, (j-1)*new_max_capacity+1:j*new_max_capacity) == 0)
                    newChrom3(i, (j-1)*new_max_capacity+1:(j-1)*new_max_capacity+2) = [against_order(k), against_order(k) + num_order];
                    if k==length(against_order)
                        break;
                    end
                    k = k + 1;
                end
            end
        end


    end
    % 随机交换订单上下车点（仅限于2辆车拼车）
    if rand < p2 && IsChange(i)
        routes = cell(num_taxi,1);   % 存储每辆车的路径
        last_pu_time = zeros(num_taxi,1);   % 存储每条路径最后一个上车时间
        len_r = zeros(num_taxi,1);    % 存储每条路径的长度
        lastIndex = zeros(num_taxi,1);   % 最后一个上车点的下标
        for j=1:num_taxi
            route = newChrom3(i, (j-1)*new_max_capacity+1:j*new_max_capacity);
            sub_route = route(route>0);
            if length(sub_route) > 2   % 交换同一辆车中不同订单的下车点和上车点的先后顺序
                if route(2)>num_order && route(3)<=num_order % 若前一个是下车点，后一个是上车点——1 3 2 4
                    if route(2) ~= route(3) + num_order
                        d32 = distances(sets(route(1),newChrom2(i,route(1))), sets(route(3),newChrom2(i,route(3)))) + distances(sets(route(3),newChrom2(i,route(3))), sets(route(2),newChrom2(i,route(2))));
                        if newtime(route(1)) + d32 / v_taxi <= newtime(route(3))
                            [route(2), route(3)] = swap(route(2), route(3));
                        end
                    end
                elseif route(2) <= num_order && route(3) > num_order
                    if route(2) + num_order == route(3)
                        d34 = distances(sets(route(2),newChrom2(i,route(2))), sets(route(3),newChrom2(i,route(3)))) + distances(sets(route(3),newChrom2(i,route(3))), sets(route(4),newChrom2(i,route(4))));
                        d43 = distances(sets(route(2),newChrom2(i,route(2))), sets(route(4),newChrom2(i,route(4)))) + distances(sets(route(4),newChrom2(i,route(4))), sets(route(3),newChrom2(i,route(3))));
                        if d43 < d34
                            [route(3), route(4)] = swap(route(3), route(4));
                        end
                    else
                        d34 = distances(sets(route(2),newChrom2(i,route(2))), sets(route(3),newChrom2(i,route(3)))) + distances(sets(route(3),newChrom2(i,route(3))), sets(route(4),newChrom2(i,route(4))));
                        d43 = distances(sets(route(2),newChrom2(i,route(2))), sets(route(4),newChrom2(i,route(4)))) + distances(sets(route(4),newChrom2(i,route(4))), sets(route(3),newChrom2(i,route(3))));
                        if d43 < d34
                            [route(3), route(4)] = swap(route(3), route(4));
                        else
                            d32 = distances(sets(route(1),newChrom2(i,route(1))), sets(route(3),newChrom2(i,route(3)))) + distances(sets(route(3),newChrom2(i,route(3))), sets(route(2),newChrom2(i,route(2))));
                            if newtime(route(1)) + d32 / v_taxi <= newtime(route(2))
                                [route(2), route(3)] = swap(route(2), route(3));
                            end
                        end
                    end
                end
                routes{j} = route;
            end
            newChrom3(i, (j-1)*new_max_capacity+1:j*new_max_capacity) = route;
            temp = newChrom3(i, (j-1)*new_max_capacity+1:j*new_max_capacity);
            routes{j} = temp(temp>0);   % 记录每辆车的路径
            len_r(j) = length(routes{j});    % 记录路径的长度
            if len_r(j)>0
                indices = find(routes{j} <= num_order);
                lastIndex(j) = max(indices);   % 最后一个上车点的下标
                last_pu_time(j) = newtime(i, routes{j}(lastIndex(j)));   % 最后一个上车时间
            end
        end
        % 车辆之间交换订单，两个只有一个订单的车合并为由一辆车服务
        for j=1:num_taxi
            len_r(j) = length(routes{j});
        end
        one_index = find(len_r==2);    % 存储只有一个订单的路径下标
        if length(one_index) > 1
            % 随机选择两辆车
            a = randi(length(one_index),1,2);
            k1 = one_index(a(1));
            k2 = one_index(a(2));
            if k1 ~= k2
                if newtime(i,routes{k1}(1)) < newtime(i,routes{k2}(1))
                    routes{k1} = [routes{k1}(1), routes{k2}(1), routes{k1}(1)+num_order,routes{k2}(1)+num_order];
                    routes{k2} = [];
                else
                    routes{k2} = [routes{k2}(1), routes{k1}(1), routes{k2}(1)+num_order,routes{k1}(1)+num_order];
                    routes{k1} = [];
                end
            end
        end
        for j=1:num_taxi
            x = zeros(1,new_max_capacity - length(routes{j}));
            newChrom3(i, (j-1)*new_max_capacity+1:j*new_max_capacity) = [routes{j}, x];
        end
        IsChange(i) = 1;
    end


end
end

% 交换函数
function [x,y] = swap(a,b)

    x = b;
    y = a;

end
