function [walkdistance,delta,newputime,newDistance, newFare] = Order(Chrom1, Chrom2, Chrom3, pick_up_time, sets, original_distances, distances_km, alpha, bata, lambd,  original_fare, max_detour, max_walk)
%Order 计算乘客的步行、绕道、时间偏移量
%   此处提供详细说明
[m,n] = size(Chrom1);
walkdistance = zeros(m,n);
delta = zeros(m,n);
newputime = pick_up_time + Chrom1;
newDistance = zeros(m,n);
newFare = zeros(m,n);
max_walk_km = max_walk / 1000;
for i=1:m
    for j=1:n
        % 步行距离
        walkdistance(i,j) = distances_km(sets{j}(1),sets{j}(Chrom3(i,j))) + distances_km(sets{j+n}(1),sets{j+n}(Chrom3(i,j+n)));
        k1 = find(Chrom2(i,:)==j);
        k2 = find(Chrom2(i,:)==j+n);
        newdistance = 0;
        for k=k1:k2-1
            newdistance = newdistance + distances_km(sets{Chrom2(i,k)}(Chrom3(i,Chrom2(i,k))),sets{Chrom2(i,k+1)}(Chrom3(i,Chrom2(i,k+1))));
        end
        newDistance(i,j) = newdistance;
        delta(i,j) = (newdistance - original_distances(j)) / original_distances(j); % 绕道率
        newFare(i,j) = Fare(original_fare(j), alpha, delta(i,j), bata, walkdistance(i,j), lambd, Chrom1(i,j), max_detour, max_walk_km);
    end
end
end

function fare = Fare(original_fare, alpha, delta, bata, l_walk, lambd, t, max_detour, max_walk_km)
    if delta < 0
        delta = 0;
    end
    fare = original_fare *(1 - alpha * delta / max_detour - bata * l_walk / max_walk_km - lambd * abs(t)/10);
end