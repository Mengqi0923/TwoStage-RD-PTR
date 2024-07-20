function distance = manhattanDistance(point1, point2)
%manhattanDistance 计算两个点之间的曼哈顿距离
%   输入两个点的位置坐标，输出其曼哈顿距离
    distance = abs(point1(1) - point2(1)) + abs(point1(2) - point2(2));
end