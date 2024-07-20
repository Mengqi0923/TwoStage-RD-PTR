function Chrom1 = init1(pop_size, num_order, minValue, maxValue,matches,pick_up_time)
%init3 个体第三部分，即每个订单上车时间的偏移量
%   编码中每值表示订单上车时间的偏移量，负值为提前，正值为延后
%   新增部分：考虑初始具有相似行程的订单

Chrom1 = zeros(pop_size,num_order);
for i=1:size(Chrom1,1)
    if rand<0.8
        n = ceil(num_order/2);
        x = randi(n,1,1);
        or = randperm(num_order,x);
        for j=1:x
            Chrom1(i,or(j)) = (maxValue - minValue) * rand + minValue;
        end
    end
    % 更改行程相似的订单的上车时间偏移量
    for j=1:num_order
        if sum(matches(j,:))>0
            indices = find(matches(j,:) == 1); % 与订单j行程相似的订单
            if length(indices)>1
                index = randi(length(indices));
            else
                index = indices;
            end
            Chrom1(i,j) = pick_up_time(j) - (pick_up_time(j) + pick_up_time(index))/2;
            Chrom1(i,index) = pick_up_time(index) - (pick_up_time(j) + pick_up_time(index))/2;
        end
    end
end

end