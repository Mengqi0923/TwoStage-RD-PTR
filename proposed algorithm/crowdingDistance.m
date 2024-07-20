function [Chrom, new_functionvalue, v] = crowdingDistance(functionvalue, frontvalue, Chrom, newChrom, v, newv)
%crowdingDistance 拥挤距离和精英选择
%   输入：
% Chrom 更新前的种群
% newChrom 更新前后合并的种群
% v 更新前的速度
% newv 更新前后合并的速度
fnum=0;                                                                 %当前前沿面
NIND = size(Chrom,1);
new_functionvalue = zeros(NIND,size(functionvalue,2));
% new_frontvalue = zeros(NIND,1);
while numel(frontvalue,frontvalue<=fnum+1)<=NIND                      %判断前多少个面的个体能完全放入下一代种群
    fnum=fnum+1;
end
newnum=numel(frontvalue,frontvalue<=fnum);                              %前fnum个面的个体数
Chrom(1:newnum,:)=newChrom(frontvalue<=fnum,:);                         %将前fnum个面的个体复制入下一代
new_functionvalue(1:newnum,:) = functionvalue(frontvalue<=fnum,:);
% new_frontvalue(1:newnum,:) = new_frontvalue(frontvalue<=fnum,:);
v(1:newnum,:) = newv(frontvalue<=fnum,:);
popu=find(frontvalue==fnum+1);                                          %popu记录第fnum+1个面上的个体编号
distancevalue=zeros(size(popu));                                        %popu各个体的拥挤距离
fmax=max(functionvalue(popu,:),[],1);                                   %popu每维上的最大值
fmin=min(functionvalue(popu,:),[],1);                                   %popu每维上的最小值
for i=1:size(functionvalue,2)                                           %分目标计算每个目标上popu各个体的拥挤距离
    [~,newsite]=sortrows(functionvalue(popu,i));
    distancevalue(newsite(1))=inf;
    distancevalue(newsite(end))=inf;
    for j=2:length(popu)-1
        distancevalue(newsite(j))=distancevalue(newsite(j))+(functionvalue(popu(newsite(j+1)),i)-functionvalue(popu(newsite(j-1)),i))/(fmax(i)-fmin(i));
    end
end

popu=-sortrows(-[distancevalue;popu]')';                                %按拥挤距离降序排序第fnum+1个面上的个体
Chrom(newnum+1:NIND,:)=newChrom(popu(2,1:NIND-newnum),:);	%将第fnum+1个面上拥挤距离较大的前NIND-newnum个个体复制入下一代
new_functionvalue(newnum+1:NIND,:)=functionvalue(popu(2,1:NIND-newnum),:);
% new_frontvalue(newnum+1:NIND,:)=new_frontvalue(popu(2,1:NIND-newnum),:);
v(newnum+1:NIND,:)=newv(popu(2,1:NIND-newnum),:);
end