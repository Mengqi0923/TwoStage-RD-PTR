function Chrom3 = init3(Chrom1, Chrom2, pop_size, num_taxi, num_order, max_capacity, pick_up_time, distances_km,v_taxi,sets, max_detour, original_distances,matches,d_t2o)
%   init31 出租车订单匹配初始化
%   新增行程相似的订单拼车，考虑出租车的初始位置
Chrom3 = zeros(pop_size,num_taxi*max_capacity);
newtime = pick_up_time + Chrom1;
sub_num_taxi = ceil(num_taxi/2);
taxiCapacity = ones(num_taxi,1).*max_capacity; % 记录出租车当前容量
taxiTime = zeros(num_taxi,1); % 记录出租车送达已有乘客的时间
taxiLocation = zeros(num_taxi,1); % 记录出租车送达已有乘客的最终位置
for i=1:pop_size
    match_t_o = zeros(num_taxi,num_order); % 出租车订单匹配的01矩阵
    taxiCapacity = ones(num_taxi,1).*max_capacity; % 记录出租车当前容量
    taxiTime = zeros(num_taxi,1); % 记录出租车送达已有乘客的时间
    taxiLocation = zeros(num_taxi,1); % 记录出租车送达已有乘客的最终位置

    % 记录距离订单上车点最近的出租车
    [~, minInd] = min(d_t2o, [], 1);
    % 值为1说明距离最近
    for col = 1:size(d_t2o, 2)
        match_t_o(minInd(col), col) = 1;
    end
    % 首先每辆车至多被分配一个订单
    for j=1:num_taxi
        if sum(match_t_o(j,:))>1
            x = match_t_o(j,:).*d_t2o(j,:);
            indicesx = find(x ~= 0);
%             x = x(x>0);
            [~,minIndex] = min(x(indicesx));
            match_t_o(j,:) = zeros(1,num_taxi);
            match_t_o(j,indicesx(minIndex)) = 1;
        end
        index = find(match_t_o(j,:)==1);
        if ~isempty(index)
            taxiTime(j) = distances_km(sets(index,Chrom2(i,index)),sets(index+num_order,Chrom2(i,index+num_order)))/v_taxi;
            taxiCapacity(j) = taxiCapacity(j) - 2;
            taxiLocation(j) = sets(index+num_order,Chrom2(i,index+num_order));
        end
    end

    for j=1:num_order
        if sum(match_t_o(:,j))==0 % 若订单j未被分配
            newdis = distances_km(sets(1:num_order,1), sets(j,Chrom2(i,j)));
            for k=1:num_taxi
                if taxiLocation(k)==0
                    newdis(k) = 0;
                else
                    newdis(k) = distances_km(taxiLocation(k), sets(j,Chrom2(i,j)));
                end
            end
            x = taxiTime + newdis/v_taxi;
            indexT = find(x <= newtime(i,j)); % 筛选符合时间约束的车
            indexC = find(taxiCapacity-2>=0); % 筛选符合容量约束的车
            index_to = intersect(indexT,indexC); % 记录同时符合时间和容量约束的出租车
            if length(index_to)>=1
                index1 = index_to(randi(length(index_to)));
                match_t_o(index1,j) = 1; % 匹配出租车与订单j
                taxiTime(index1) = taxiTime(index1) + distances_km(sets(j,Chrom2(i,j)), sets(j+num_order, Chrom2(i,j+num_order)))/v_taxi;
                taxiCapacity(index1) = taxiCapacity(index1) - 2;
                taxiLocation(index1) = sets(j+num_order,Chrom2(i,j+num_order));
            else
                index_emptyTaxis = find(sum(match_t_o,2) == 0);
                [~,minIndex] = min(d_t2o(index_emptyTaxis,j));
                index1 = index_emptyTaxis(minIndex);
                match_t_o(index1,j) = 1; % 匹配出租车与订单j
                taxiTime(index1) = taxiTime(index1) + distances_km(sets(j,Chrom2(i,j)), sets(j+num_order, Chrom2(i,j+num_order)))/v_taxi;
                taxiCapacity(index1) = taxiCapacity(index1) - 2;
                taxiLocation(index1) = sets(j+num_order,Chrom2(i,j+num_order));
            end
        end
    end
    % 对于行程相似的订单
    for k = 1:num_order
        indices = find(matches(k,:) == 1); % 与订单k行程相似的所有订单
        if ~isempty(indices)
            for z=1:length(indices)
                taxi_index = find(match_t_o(:,k)>0);
                if taxiTime(taxi_index) + distances_km(sets(z,Chrom2(i,z)), sets(z+num_order, Chrom2(i,z+num_order)))/v_taxi <= newtime(i,z) && ...
                        taxiCapacity(taxi_index) - 2>=0
                    match_t_o(:,z) = zeros(num_taxi,1);
                    match_t_o(taxi_index,z) = 1;
                    taxiTime(taxi_index) = taxiTime(taxi_index) + distances_km(sets(j,Chrom2(i,j)), sets(j+num_order, Chrom2(i,j+num_order)))/v_taxi;
                    taxiCapacity(taxi_index) = taxiCapacity(taxi_index) - 2;
                    taxiLocation(taxi_index) = sets(j+num_order,Chrom2(i,j+num_order));
                    break;
                end
            end
        end
    end
    for l=1:num_taxi % 初始化种群3
        if sum(match_t_o(l,:))>0 % 出租车被分配订单
            if sum(match_t_o(l,:))==1
                indx = find(match_t_o(l,:) == 1);
%                 if l==1 || (l>1 && sum(match_t_o(1:l-1,indx))==0) % 订单在前面的车里未出现过
                    Chrom3(i,(l-1)*max_capacity+1) = find(match_t_o(l,:) == 1);
                    Chrom3(i,(l-1)*max_capacity+2) = Chrom3(i,(l-1)*max_capacity+1) + num_order;
%                 end               

            else   % if sum(match_t_o(l,:))==2 % 多于一个订单时
                ind = find(match_t_o(l,:) == 1);
                ind1 = ind(1);
                ind2 = ind(2);
                if newtime(i,ind(1))>newtime(i,ind(2))
                    ind1 = ind(2);
                    ind2 = ind(1);
                end
%                 if l==1 || (~any(sum(match_t_o(1:l-1,ind)))) %(l>1 && sum(match_t_o(1:l-1,ind))==0) % 订单在前面的车里未出现过                  
                    randx = rand();
                    if randx<=2/3
                        Chrom3(i,(l-1)*max_capacity+1) = ind1;
                        Chrom3(i,(l-1)*max_capacity+2) = ind2;
                        if randx<=1/2
                            Chrom3(i,(l-1)*max_capacity+3) = ind1 + num_order;
                            Chrom3(i,(l-1)*max_capacity+4) = ind2 + num_order;
                        else
                            Chrom3(i,(l-1)*max_capacity+3) = ind2 + num_order;
                            Chrom3(i,(l-1)*max_capacity+4) = ind1 + num_order;
                        end
                    else
                        Chrom3(i,(l-1)*max_capacity+1) = ind1;
                        Chrom3(i,(l-1)*max_capacity+2) = ind1 + num_order;
                        Chrom3(i,(l-1)*max_capacity+3) = ind2;
                        Chrom3(i,(l-1)*max_capacity+4) = ind2 + num_order;
                    end
%                 else
%                     if l==1 || (l>1 && sum(match_t_o(1:l-1,ind1))==0)
%                         Chrom3(i,(l-1)*max_capacity+1) = ind2;
%                         Chrom3(i,(l-1)*max_capacity+2) = ind2 + num_order;
%                     end
%                     if l==1 || (l>1 && sum(match_t_o(1:l-1,ind2))==0)
%                         Chrom3(i,(l-1)*max_capacity+1) = ind1;
%                         Chrom3(i,(l-1)*max_capacity+2) = ind1 + num_order;
%                     end 
%                 end
                
            end
        end
    end
    % 若推荐的上下车点在行程中的距离大于原来的距离，则更新其上下车点，使其减少绕行（仅限未拼车的订单）
    for j=1:num_taxi
        rt = Chrom3(i,(j-1)*max_capacity+1:j*max_capacity);
        rt = rt(rt>0);
        if ~isempty(rt) && length(rt)<=2
            mino2d = min([distances_km(sets(rt(1),1),sets(rt(2),1)),distances_km(Chrom2(i,rt(1)),Chrom2(i,rt(2))),...
                distances_km(sets(rt(1),1),Chrom2(i,rt(2))),distances_km(Chrom2(i,rt(1)),sets(rt(2),1))]);
            if mino2d==distances_km(sets(rt(1),1),sets(rt(2),1))
                Chrom2(i,rt(1)) = 1;
                Chrom2(i,rt(2)) = 1;
            elseif mino2d==distances_km(sets(rt(1),1),Chrom2(i,rt(2)))
                Chrom2(i,rt(1)) = 1;
            elseif mino2d==distances_km(Chrom2(i,rt(1)),sets(rt(2),1))
                Chrom2(i,rt(2)) = 1;
            end
        end
    end
end


end