function [matches] = IsCarpool(n,pickuptime,points,sets)
%ISCARPOOL 判断两个订单是否可以拼车
%   输入: 订单数量；订单原上下车点之间的距离（千米）；原上车时间（分钟）,上下车点,点集合
%   输出: 订单之间能否匹配的0-1矩阵
matches = zeros(n,n);
for i = 1:n-1
    for j = (i+1):n
        o1 = points(sets(i,1),:);
        o2 = points(sets(j,1),:);
        o_distances = sqrt((o2(1) - o1(1))^2 + (o2(2) - o1(2))^2)/1000;
        d1 = points(sets(i+n,1),:);
        d2 = points(sets(j+n,1),:);
        d_distances = sqrt((d2(1) - d1(1))^2 + (d2(2) - d1(2))^2)/1000;
        if o_distances<=0.8 && d_distances<=0.8 && abs(pickuptime(i)-pickuptime(j))<=10
            matches(i,j) = 1;
            matches(j,i) = 1;
        end
    end
end

