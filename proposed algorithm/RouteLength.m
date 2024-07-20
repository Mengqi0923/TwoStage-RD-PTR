function [rouLen] = RouteLength(Chrom,route)
%RouteLength 计算路径距离

N=size(Chrom,1);
rouLen=zeros(N,1);
for i=1:N
    for j=1:length(route)-1
        rouLen(i)=rouLen(i)+abs(Chrom(i,route(j+1),1)-Chrom(i,route(j),1))+abs(Chrom(i,route(j+1),2)-Chrom(i,route(j),2));
    end
end
end