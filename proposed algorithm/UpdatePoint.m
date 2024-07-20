function [newChrom2, IsChange] = UpdatePoint(Chrom2, sets, ls, p3, IsChange)
%UpdatePoint 更新集合中选择的点，即Chrom2
%   此处提供详细说明
newChrom2 = Chrom2;
m = size(newChrom2,1);
n = size(newChrom2,2);
for i=1:m
    if rand<p3 && IsChange(i) == 0
        p = randi(n,1,1);   % 随机产生需更新的上下车点的数量
        s = randperm(n,p);  % 随机选择上下车点集合
        s = sort(s);
        for j=1:length(s)
            a = sets(s(j),1:ls(s(j)));
            x = randi(length(a),1,1);
            newChrom2(i,s(j)) = x;
        end
        IsChange(i) = 1;
    end

end
end