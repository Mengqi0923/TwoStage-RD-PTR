function [newChrom1, newChrom2, newChrom3] = correction_1(newChrom1, newChrom2, newChrom3, distances_km, sets, ls, num_taxi, max_capacity, max_detour, original_distances, min_time, max_time, pick_up_time, v_taxi)
%correction 修正函数
%   调整种群中违反约束的个体
%   算法思想：对于违反时间的约束，先看调整其上车时间能否满足约束，若能，则调整时间分种群，若不能，则调整上下车点分种群，若仍不能，则调整路径分种群
%            对于违反绕道率的约束，先看调整上下车点分种群能否满足约束，若不能，则调整路径分种群
num_order = size(newChrom1,2);
pop_size = size(newChrom1,1);
newtime = pick_up_time + newChrom1;
distances = distances_km * 1000;
for i=pop_size
    for j=1:num_taxi
        route = newChrom3(i,(j-1)*max_capacity+1:j*max_capacity);
        route = route(route>0);
        if length(route) == 2   % 寻找最短路径
            orderid = route(1);
            mindist = distances_km(sets(orderid,newChrom2(i, orderid)), sets(orderid + num_order, newChrom2(i, orderid + num_order)));
            for k1 = 1:ls(orderid)
                for k2 = 1:ls(orderid + num_order)
                    if distances_km(sets(orderid,k1),sets(orderid + num_order, k2)) < mindist
                        newChrom2(i,orderid) = k1;
                        newChrom2(i,orderid + num_order) = k2;
                    end
                end
            end
%             newChrom1(i,orderid) = 0;   % 一个订单的路径，订单的上车时间不变
        end
        if length(route) > 2  % 路径中有多个订单
            for k=1:length(route)   % 遍历路径中的每个订单
                if route(k)<=num_order
                    kk = find(route==route(k)+num_order);
                    if kk == k + 1
                        dist = distances_km(sets(route(k),newChrom2(i,route(k))), sets(route(kk),newChrom2(i,route(kk))));
                        if (dist - original_distances(route(k)))/original_distances(route(k)) > max_detour
                            % 违反绕道率约束，新上下车点之间的距离远大于原上下车点
                            if k == 1
                                orderid = route(1);
                                mindist = distances_km(sets(orderid, newChrom2(i, orderid)), sets(route(kk), newChrom2(i, route(kk)))) + distances_km(sets(route(kk), newChrom2(i, route(kk))), sets(route(kk+1), newChrom2(i, route(kk+1))));
                                for k1 = 1:ls(orderid)
                                    for k2 = 1:ls(route(kk))
                                        if distances_km(sets(orderid,k1),sets(route(kk),k2)) + distances_km(sets(route(kk),k2), sets(route(kk+1),newChrom2(i, route(kk+1)))) < mindist
                                            newChrom2(i,orderid) = k1;
                                            newChrom2(i,route(kk)) = k2;
                                        end
                                    end
                                end
                            else   % k>1
                                if kk < length(route)
                                    d1 = distances_km(sets(route(k-1),newChrom2(i, route(k-1))), sets(route(k),newChrom2(i, route(k))));
                                    d2 = distances_km(sets(route(k),newChrom2(i, route(k))), sets(route(kk),newChrom2(i, route(kk))));
                                    d3 = distances_km(sets(route(kk),newChrom2(i, route(kk))), sets(route(kk+1),newChrom2(i, route(kk+1))));
                                    mindist = d1 + d2 + d3;

                                    for k1 = 1:ls(route(k))
                                        for k2 = 1:ls(route(kk))
                                            d1 = distances_km(sets(route(k-1),newChrom2(i, route(k-1))), sets(route(k),k1));
                                            d2 = distances_km(sets(route(k),k1), sets(route(kk),k2));
                                            d3 = distances_km(sets(route(kk),k2), sets(route(kk+1),newChrom2(i, route(kk+1))));
                                            if d1 + d2 + d3 < mindist
                                                newChrom2(i,route(k)) = k1;
                                                newChrom2(i,route(kk)) = k2;
                                            end
                                        end
                                    end
                                else
                                    d1 = distances_km(sets(route(k-1),newChrom2(i, route(k-1))), sets(route(k),newChrom2(i, route(k))));
                                    d2 = distances_km(sets(route(k),newChrom2(i, route(k))), sets(route(kk),newChrom2(i, route(kk))));                                    
                                    mindist = d1 + d2;

                                    for k1 = 1:ls(route(k))
                                        for k2 = 1:ls(route(kk))
                                            d1 = distances_km(sets(route(k-1),newChrom2(i, route(k-1))), sets(route(k),k1));
                                            d2 = distances_km(sets(route(k),k1), sets(route(kk),k2));
                                            if d1 + d2 < mindist
                                                newChrom2(i,route(k)) = k1;
                                                newChrom2(i,route(kk)) = k2;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    else
                        % 若拼车时，违反绕道率约束
                        dist = 0;
                        for ll=k:kk-1
                            dist = dist + distances_km(sets(route(ll),newChrom2(i,route(ll))), sets(route(ll+1),newChrom2(i,route(ll+1))));
                        end
                        % 违反绕道率，先调整上下车点
                        if (dist - original_distances(route(k))) / original_distances(route(k)) > max_detour
                            d1 = distances_km(sets(route(1),newChrom2(i, route(1))), sets(route(2),newChrom2(i, route(2))));
                            d2 = distances_km(sets(route(2),newChrom2(i, route(2))), sets(route(3),newChrom2(i, route(3))));
                            d3 = distances_km(sets(route(3),newChrom2(i, route(3))), sets(route(4),newChrom2(i, route(4))));
                            mindist = d1 + d2 + d3;

                            for k1 = 1:ls(route(k))
                                for k2 = 1:ls(route(kk))
                                    if k == 1 && kk == 4
                                        d1 = distances_km(sets(route(1),k1), sets(route(2),newChrom2(i, route(2))));
                                        d3 = distances_km(sets(route(3),newChrom2(i, route(3))), sets(route(4),k2));
                                        if d1 + d2 + d3 < mindist
                                            newChrom2(i,route(k)) = k1;
                                            newChrom2(i,route(kk)) = k2;
                                        end
                                    elseif k == 1 && kk == 3
                                        d1 = distances_km(sets(route(1),k1), sets(route(2),newChrom2(i, route(2))));
                                        d2 = distances_km(sets(route(2),newChrom2(i, route(2))), sets(route(3),k2));
                                        d3 = distances_km(sets(route(3),k2), sets(route(4),newChrom2(i, route(4))));
                                        if d1 + d2 + d3 < mindist
                                            newChrom2(i,route(k)) = k1;
                                            newChrom2(i,route(kk)) = k2;
                                        end
                                    elseif k == 2 && kk == 4
                                        d1 = distances_km(sets(route(1),newChrom2(i, route(1))), sets(route(2),k1));
                                        d2 = distances_km(sets(route(2),k1), sets(route(3),newChrom2(i, route(3))));
                                        d3 = distances_km(sets(route(3),newChrom2(i, route(3))), sets(route(4),k2));
                                        if d1 + d2 + d3 < mindist
                                            newChrom2(i,route(k)) = k1;
                                            newChrom2(i,route(kk)) = k2;
                                        end
                                    end
                                end
                            end
                        end
                        % 仍然违反绕道率约束，调整路径
                        dist = 0;
                        for ll=k:kk-1
                            dist = dist + distances_km(sets(route(ll),newChrom2(i,route(ll))), sets(route(ll+1),newChrom2(i,route(ll+1))));
                        end
                        if (dist - original_distances(route(k))) / original_distances(route(k)) > max_detour
                            % 违反绕道率约束，将拼车改为非拼车
                            rk = route(kk);
                            route = route(route ~= rk);
                            route = [route(1:k), rk, route(k+1:end)];
                        end
                    end
                    % 判断是否违反时间约束
                    if k > 1
                        front_t = CaculateTime(route(1:k-1),num_order, newtime(i,:),distances,v_taxi,sets,newChrom2(i,:));
                        subt = distances(sets(route(k-1),newChrom2(i, route(k-1))), sets(route(k),newChrom2(i, route(k)))) / v_taxi;
                        if front_t + subt > newtime(i,route(k))
                            if front_t + subt - pick_up_time(route(k)) <= max_time
                                newChrom1(i,route(k)) = front_t + subt - pick_up_time(route(k));
                            else
                                if front_t + subt - pick_up_time(route(k)) <= max_time - min_time
                                    newChrom1(i,route(k)) = max_time;
                                    newChrom1(i,route(1)) = -(front_t + subt - pick_up_time(route(k)) - max_time);
                                end
                            end
                        end
                    end
                end
            end
        end
        newChrom3(i,(j-1)*max_capacity+1:(j-1)*max_capacity+length(route)) = route;

    end
end
end

