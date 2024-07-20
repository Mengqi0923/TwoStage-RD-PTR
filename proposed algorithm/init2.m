function Chrom3 = init2(sets, ls, pop_size, num_order,matches,points)
%init2 个体第二部分，即集合中上下车点的下标编码
%   编码中每个非零元素表示订单的编号，上车为i，下车为i+n
length_code2 = num_order * 2;
Chrom3 = ones(pop_size, length_code2);
for i=1:pop_size
    for j=1:num_order
        if rand<0.5
            Chrom3(i,j) = randi(ls(j));
        end
        if rand<0.5
            Chrom3(i,j+num_order) = randi(ls(j+num_order));
        end
        if sum(matches(j,:))>0
            indices = find(matches(j,:) == 1); % 与订单j行程相似的订单
            if length(indices)>1
                index = randi(length(indices));
            else
                index = indices;
            end
            o1 = sets(j,1:ls(j));
            o2 = sets(index,1:ls(index));
            o2o = pdist2(points(o1,:),points(o2,:));
            d1 = sets(j+num_order,1:ls(j+num_order));
            d2 = sets(index+num_order,1:ls(index+num_order));
            d2d = pdist2(points(d1,:),points(d2,:));
            % 找出矩阵A中的最小值,即距离最短的共乘上下车点
            [~, o_min_index] = min(o2o(:));
            [orow, ocol] = ind2sub(size(o2o), o_min_index);
            [~, d_min_index] = min(d2d(:));
            [drow, dcol] = ind2sub(size(d2d), d_min_index);
            Chrom3(i,j) = orow;
            Chrom3(i,index) = ocol;
            Chrom3(i,j+num_order) = drow;
            Chrom3(i,index+num_order) = dcol;
           
        end
    end
end

end