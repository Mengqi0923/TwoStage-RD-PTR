function [newrouteChrom] = Evolution(routeChrom, popsize2, num_order, num_taxi, max_capacity,new_distances_km,max_detour,original_distances,newtime, d_t2o,v_taxi)
%Evolution 种群进化
%   破坏与修复
newrouteChrom = routeChrom;

for i=1:popsize2
    p = rand(1);
    if p<=1/3
        % 破坏解
        range = randi(num_taxi,1,2);
        mint = min(range);
        maxt = max(range);

        % 内部
        for j=mint:maxt
            route = newrouteChrom(i,(j-1)*max_capacity+1:j*max_capacity);
            route = route(route>0);
            if length(route)>2
                r1 = route;
                % 1 2 3 4
                if route(3)==route(1)+num_order && route(4)==route(2)+num_order
                    r1(3) = route(4);
                    r1(4) = route(3);
                    % 距离更短
                    if new_distances_km(r1(2),r1(3))+new_distances_km(r1(3),r1(4))<new_distances_km(route(2),route(3))+new_distances_km(route(3),route(4))
                        % 满足绕道率约束
                        if (new_distances_km(r1(1),r1(2))+new_distances_km(r1(2),r1(3))+new_distances_km(r1(3),r1(4))-original_distances(r1(1)))/original_distances(r1(1))<=max_detour
                            newrouteChrom(i,(j-1)*max_capacity+1:j*max_capacity) = r1;
                        end
                    end
                    % 1 2 4 3
                elseif route(3)==route(2)+num_order && route(4)==route(1)+num_order
                    r1(3) = route(4);
                    r1(4) = route(3);
                    % 距离更短
                    if new_distances_km(r1(2),r1(3))+new_distances_km(r1(3),r1(4))<new_distances_km(route(2),route(3))+new_distances_km(route(3),route(4))
                        % 满足绕道率约束
                        if (new_distances_km(r1(2),r1(3))+new_distances_km(r1(3),r1(4))-original_distances(r1(2)))/original_distances(r1(2))<=max_detour && ...
                                (new_distances_km(r1(1),r1(2))+new_distances_km(r1(2),r1(3))-original_distances(r1(1)))/original_distances(r1(1))<=max_detour
                            newrouteChrom(i,(j-1)*max_capacity+1:j*max_capacity) = r1;
                        end
                    end
                    % 1 3 2 4
                elseif route(2)==route(1)+num_order && route(4)==route(3)+num_order
                    r1(2) = route(3);
                    r1(3) = route(2);
                    % 距离更短
                    if new_distances_km(r1(1),r1(2))+new_distances_km(r1(2),r1(3))+new_distances_km(r1(3),r1(4))<new_distances_km(route(1),route(2))+new_distances_km(route(2),route(3))+new_distances_km(route(3),route(4))
                        % 满足绕道率约束
                        if (new_distances_km(r1(2),r1(3))+new_distances_km(r1(3),r1(4))-original_distances(r1(2)))/original_distances(r1(2))<=max_detour && ...
                                (new_distances_km(r1(1),r1(2))+new_distances_km(r1(2),r1(3))-original_distances(r1(1)))/original_distances(r1(1))<=max_detour
                            newrouteChrom(i,(j-1)*max_capacity+1:j*max_capacity) = r1;
                        end
                    end
                end
            end
        end % 内部订单调整
    elseif p>1/3 && p<=2/3
        % 订单重组
        range2 = randi(num_taxi,1,2);
        mint2 = min(range2);
        maxt2 = max(range2);
        seat = zeros(num_taxi,1); % 记录空座位数量
        for j=mint2:maxt2
            route = newrouteChrom(i,(j-1)*max_capacity+1:j*max_capacity);
            route = route(route>0);
            if length(route)==2
                seat(j) = 1;
            end
            if isempty(route)
                seat(j) = 2;
            end
        end
        indices = find(seat==1);
        indices = indices(indices>=mint2 & indices<=maxt2);
        if ~isempty(indices)
            for j=1:length(indices)
                index2 = randi([j,length(indices)]);
                if index2 ~= j
                    route1 = newrouteChrom(i,(indices(j)-1)*max_capacity+1:(indices(j)-1)*max_capacity+2);
                    route2 = newrouteChrom(i,(indices(index2)-1)*max_capacity+1:(indices(index2)-1)*max_capacity+2);
                    route = [route1(1), route2(1),route1(2), route2(2)];
                    if newtime(route1(1))>newtime(route2(1))
                        route = [route2(1), route1(1),route2(2), route1(2)];
                    end
                    % 满足最短时间约束
                    if newtime(route(2))-newtime(route(1))>=new_distances_km(route(1),route(2))/v_taxi
                        % 满足绕道率约束
                        if (new_distances_km(route(2),route(3))+new_distances_km(route(3),route(4))-original_distances(route(2)))/original_distances(route(2))<=max_detour && ...
                                (new_distances_km(route(1),route(2))+new_distances_km(route(2),route(3))-original_distances(route(1)))/original_distances(route(1))<=max_detour
                            newrouteChrom(i,(indices(j)-1)*max_capacity+1:indices(j)*max_capacity) = route;
                            newrouteChrom(i,(indices(index2)-1)*max_capacity+1:indices(index2)*max_capacity) = zeros(1,max_capacity);
                            seat(indices(j)) = 0;
                            seat(indices(index2)) = 2;
                            indices = indices(indices ~= indices(index2));                            
                        end
                    end
                end
                if j==length(indices)
                    break;
                end
            end % 订单重组
        end
    else
        % 交换片段
        range3 = randi(num_taxi,1,2);
        mint3 = min(range3);
        maxt3 = max(range3);
        length_fag = maxt3-mint3;
        if length_fag>=1
            routes = routeChrom(i,(mint3-1)*max_capacity+1:maxt3*max_capacity);
            routes = routes(end:-1:1);
            k1 = 0; % 记录原个体中该片段车辆位置与第一个上车点的总距离
            k2 = 0; % 记录新个体中该片段车辆位置与第一个上车点的总距离
            k = mint3;
            for j=1:length_fag+1
                temp = routes((j-1)*max_capacity+1:j*max_capacity);
                temp = temp(end:-1:1);
                routes((j-1)*max_capacity+1:j*max_capacity) = temp;
                if routeChrom(i,(k-1)*max_capacity+1) ~= 0
                    k1 = k1 + d_t2o(k,routeChrom(i,(k-1)*max_capacity+1));
                end
                if routes((j-1)*max_capacity+1) ~= 0
                    k2 = k2 + d_t2o(k,routes((j-1)*max_capacity+1));
                end
                k = k + 1;
            end
            % 若车初始位置离第一个上车点更近
            if k2<k1
                routeChrom(i,(mint3-1)*max_capacity+1:maxt3*max_capacity) = routes;
            else
                if rand(1)>0.5
                    routeChrom(i,(mint3-1)*max_capacity+1:maxt3*max_capacity) = routes;
                end
            end
        end
    end
end
end