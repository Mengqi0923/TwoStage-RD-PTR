function [total_fare,unit_profit] = ObjectiveFunction(Chrom1, Chrom2, Chrom3, alpha, bata, lambd, sets, ls, num_order, num_taxi, max_capacity, original_fare, original_distances, distances_km ,cE, max_walk, max_detour, base_fare)
%payment 支付金额
%   输入：
% Chrom1, Chrom3, Chrom2三个分种群
% cF  单位里程价格
% alpha  绕道折扣系数
% bata  步行折扣系数
% lambd  时间折扣系数
% num_taxi  出租车数量
% num_order  订单数量
% max_capacity  出租车最大容量
% origintime  原上车时间
% v_taxi   出租车速度
% v_walk   步行速度

len = size(Chrom3,1);
delta = zeros(len,num_order); % 绕道率
l_walk = zeros(len,num_order); % 步行距离
total_fare = zeros(len,1); %所有订单的总费用
total_distance = zeros(len,1); %所有出租车的总距离
unit_profit = zeros(len,1); % 出租车的单位里程利润
max_walk_km = max_walk / 1000;
for i=1:len
    e = zeros(num_order,1);
    % 使用reshape分割向量为多个子向量
%     subVectors = reshape(Chrom3(i,:),[max_capacity*2, num_taxi])';
    for j=1:num_taxi
        s = Chrom3(i,(j-1)*max_capacity+1:j*max_capacity);
        s1 = s(s ~= 0);   % 删除0元素
        
        if length(s1)>1
            % 计算乘客付费
            for k=1:length(s1)-1
                newdistance = 0;
                pu = sets(s1(k),1:ls(s1(k)));
                if s1(k)<=num_order
                    k1 = k;
                    for kk=k+1:length(s1)
                        pu1 = sets(s1(k1),1:ls(s1(k1)));
                        do = sets(s1(kk),1:ls(s1(kk)));
                        newdistance = newdistance + distances_km(pu1(Chrom2(i,s1(k1))), do(Chrom2(i,s1(kk))));
                        k1 = k1 + 1;
                        if s1(kk)==s1(k) + num_order
                            
                            break
                        end
                    end
                    if original_distances(s1(k))==0
                        delta(i,s1(k)) = max_detour;
                    else
                        delta(i,s1(k)) = (newdistance - original_distances(s1(k))) / original_distances(s1(k)); % 绕道率
                    end
                    l_walk(i,s1(k)) = distances_km(pu(1),pu(Chrom2(i,s1(k)))) + distances_km(do(1),do(Chrom2(i,s1(kk))));
                    e(s1(k)) = Fare(original_fare(s1(k)), alpha, delta(i,s1(k)), bata, l_walk(i,s1(k)), lambd, Chrom1(i,s1(k)), max_detour, max_walk_km, base_fare);
                end
%                 if k==1
%                   % 计算出租车到第一个上车点的距离
%                     total_distance(i) = total_distance(i) + d_t2o(j,Chrom3(i,(j-1)*max_capacity+1));
%                 end
                % 计算出租车总距离
                total_distance(i) = total_distance(i) + distances_km(sets(s1(k),Chrom2(i,s1(k))),sets(s1(k+1),Chrom2(i,s1(k+1))));
            end

            
            
                
        end

    end
    total_fare(i) = sum(e);
    unit_profit(i) = total_fare(i) / total_distance(i) - cE;
end


            
    



end

% function detour = Detour(distance, origin_distance)
% 
% detour = (distance - origin_distance) / origin_distance;
% end
% 
% function distance = Walking(a,b)
%     distance = a + b;
% end

function fare = Fare(original_fare, alpha, delta, bata, l_walk, lambd, t, max_detour, max_walk_km, base_fare)
    if delta < 0
        delta = 0;
    end
    fare = base_fare+(original_fare-base_fare) *(1 - alpha * delta / max_detour - bata * l_walk / max_walk_km - lambd * abs(t)/10);
end

