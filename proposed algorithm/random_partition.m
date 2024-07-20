function partitions = random_partition(numbers, num_partitions, max_per_partition)
% random_partition 随机分块
% 输入：待分块数据，分块数量，最大分块长度
    partitions = cell(1, num_partitions);
    for number = numbers
        while true
            partition_index = randi(num_partitions);
            if numel(partitions{partition_index}) < max_per_partition
                partitions{partition_index} = [partitions{partition_index}, number];
                break;
            end
        end
    end
end