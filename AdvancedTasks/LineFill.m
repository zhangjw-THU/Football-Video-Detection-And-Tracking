%% 若在轨迹中途没有检测到球
function [meanx,meany] = LineFill(I)
[rows,cols] = size(I);
x = ones(rows,1)*[1:cols];
y = [1:rows]'*ones(1,cols);
area = sum(sum(I));
meanx = int16(sum(sum(I.*x))/area);
meany = int16(sum(sum(I.*y))/area);
end