function [original_fare, original_distances] = InitialFare(distances, num_order, cF, min_fare)
%originFare 计算原价
%   原价为初始上下车点之间的距离(km) * 单位里程费用
original_fare = zeros(num_order,1);
original_distances = zeros(num_order,1);
for i=1:num_order
    original_distances(i) = distances(i, i+num_order);    % 计算原距离
    original_fare(i) = original_distances(i) * cF + min_fare;     % 计算原价
end

end