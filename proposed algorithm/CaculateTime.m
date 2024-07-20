function time = CaculateTime(route,num_order, pickuptime,distances,v,sets,re_points)
%CaculateTime 计算一段路径的时间
%   此处提供详细说明
if isempty(route)
    time = 0;
end
if length(route) == 1
    if route <= num_order
        time = pickuptime(route);
    else
        time = 0;
    end
else
    for i=2:length(route)
        if route(i) <= num_order
            time = pickuptime(route(i));
        else
            if route(i-1) <= num_order
                time = pickuptime(route(i-1)) + distances(sets(route(i-1),re_points(route(i-1))),sets(route(i),re_points(route(i)))) / v;   % 其中距离应为该点的推荐点集合里的点之间的距离
            else
                time = time + distances(sets(route(i-1),re_points(route(i-1))),sets(route(i),re_points(route(i)))) / v;
            end
        end
    end
end