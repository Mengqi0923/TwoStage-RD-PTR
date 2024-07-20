% 定义非支配排序函数
function [frontvalue] = nondominated_sort(functionvalue)
fnum=0;                                             %当前分配的前沿面编号
cz=false(1,size(functionvalue,1));                  %记录个体是否已被分配编号
frontvalue=zeros(size(cz));                         %每个个体的前沿面编号
[functionvalue_sorted,newsite]=sortrows(functionvalue);    %对种群按第一维目标值大小进行排序
while ~all(cz)                                      %开始迭代判断每个个体的前沿面,采用改进的deductive sort
    fnum=fnum+1;
    d=cz;
    for i=1:size(functionvalue,1)
        if ~d(i)
            for j=i+1:size(functionvalue,1)
                if ~d(j)
                    k=1;
                    for m1=1:size(functionvalue,2)
                        if functionvalue_sorted(i,m1)>functionvalue_sorted(j,m1)
                            k=0;
                            break
                        end
                    end
                    if k
                        d(j)=true;
                    end
                end
            end
            frontvalue(newsite(i))=fnum;
            cz(i)=true;
        end
    end
end