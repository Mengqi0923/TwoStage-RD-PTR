function [total_fare,unit_profit] = newObjectiveFunction(routeChrom,alpha, discount, num_order, num_taxi, max_capacity, original_fare, original_distances, cE, max_detour, base_fare,new_distances_km)
%newObjectiveFunction 计算第二阶段获得的目标函数值
%   此处提供详细说明
popsize2 = size(routeChrom,1);
total_fare = zeros(popsize2,1);
unit_profit = zeros(popsize2,1);
for i=1:popsize2
    detour = zeros(num_order,1);
    total_dist = zeros(num_taxi,1);
    for j=1:num_taxi
        if routeChrom(i,(j-1)*max_capacity+1)>0 % 出租车不为空
            route = routeChrom(i,(j-1)*max_capacity+1:j*max_capacity);
            route = route(route>0);
            if length(route)==max_capacity % 出租车有两个订单
                if route(1)<=num_order && route(2)<=num_order && route(3)>num_order && route(4) > num_order
                    if route(3) == route(1) + num_order && route(4) == route(2) + num_order
                        dist1 = new_distances_km(route(1),route(2)) + new_distances_km(route(2),route(3));
                        dist2 = new_distances_km(route(2),route(3)) + new_distances_km(route(3),route(4));
                        total_dist(j) = new_distances_km(route(1),route(2)) + new_distances_km(route(2),route(3)) + new_distances_km(route(3),route(4));
                    else
                        dist1 = new_distances_km(route(1),route(2)) + new_distances_km(route(2),route(3)) + new_distances_km(route(3),route(4));
                        dist2 = new_distances_km(route(2),route(3));
                        total_dist(j) = dist1;
                    end
                    if original_distances(route(1))==0
                        detour(route(1)) = 0;
                    else
                        detour(route(1)) = (dist1 - original_distances(route(1))) / original_distances(route(1));
                    end
                    if original_distances(route(2))==0
                        detour(route(2)) = 0;
                    else
                        detour(route(2)) = (dist2 - original_distances(route(2))) / original_distances(route(2));
                    end
                else
                    dist1 = new_distances_km(route(1),route(2));
                    dist2 = new_distances_km(route(3),route(4));
                    total_dist(j) = new_distances_km(route(1),route(2)) + new_distances_km(route(2),route(3)) + new_distances_km(route(3),route(4));
                    if original_distances(route(1))==0
                        detour(route(1)) = 0;
                    else
                        detour(route(1)) = (dist1 - original_distances(route(1))) / original_distances(route(1));
                    end
                    if original_distances(route(3))==0
                        detour(route(3)) = 0;
                    else
                        detour(route(3)) = (dist2 - original_distances(route(3))) / original_distances(route(3));
                    end
                end
            else % 出租车有一个订单
                dist1 = new_distances_km(route(1),route(2));
                total_dist(j) = dist1;
                if original_distances(route(1))==0
                    detour(route(1)) = 0;
                else 
                    detour(route(1)) = (dist1 - original_distances(route(1))) / original_distances(route(1));
                end
            end
        end
    end
    detour(detour<0) = 0;
    total_fare(i) = sum(base_fare + (original_fare - base_fare).* (1-discount-alpha .* detour./max_detour)); 
    unit_profit(i) = total_fare(i)./sum(total_dist) - cE;
end
end