function [meanx,meany] = calcenter(I)
%         你需要在这里完成足球中心点的计算，根据前景图
%         示例代码
[rows,cols] = size(I);
x = ones(rows,1)*[1:cols];
y = [1:rows]'*ones(1,cols);
area = sum(sum(I));
meanx = int16(sum(sum(I.*x))/area);
meany = int16(sum(sum(I.*y))/area);
end