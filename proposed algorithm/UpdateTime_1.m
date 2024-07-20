function [newChrom1, newv, IsChange] = UpdateTime_1(Chrom1, Chrom3, num_taxi, max_capacity, min_time, max_time, paretoset, v, w, c1, min_v, max_v,p1, IsChange)
%UpdateTime 更新时间偏移量操作，即更新种群1
%   结合PSO的更新种群策略
%   结合路径更新时间，若订单不拼车则时间不变
[m,n] = size(v);
newv = zeros(m,n);
for i=1:m
    if rand<p1
        x = randi(n,1,1);
        or = randperm(n,x);
        for j=1:x
            if rand<0.5
                newv(i,or(j)) = w * v(i,or(j)) + c1 * rand * (paretoset(randi(size(paretoset,1)),or(j)) - Chrom1(i,or(j)));
            else
                newv(i,or(j)) = 0;
            end
        end
    end
end

newv(newv > max_v) = (max_v - min_v) * rand(size(newv(newv > max_v))) + min_v;
newv(newv < min_v) = (max_v - min_v) * rand(size(newv(newv < min_v))) + min_v;
newChrom1 = Chrom1 + newv;
newChrom1(newChrom1 > max_time) = (max_time - min_time) * rand(size(newChrom1(newChrom1 > max_time))) + min_time;
newChrom1(newChrom1 < min_time) = (max_time - min_time) * rand(size(newChrom1(newChrom1 < min_time))) + min_time;
for i=1:size(newChrom1, 1)
%     for j=1:num_taxi
%         if Chrom3(i,(j-1)*max_capacity+1) ~= 0   % && Chrom3(i,(j-1)*max_capacity*2+3) == 0
%             orderid = Chrom3(i,(j-1)*max_capacity+1);
%             newChrom1(i,orderid) = 0;           
%         end
%     end
    if ~isequal(newChrom1(i,:), Chrom1(i,:))
        IsChange(i) = 1;
    end
end


end