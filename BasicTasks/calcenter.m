function [meanx,meany] = calcenter(I)
%         ����Ҫ����������������ĵ�ļ��㣬����ǰ��ͼ
%         ʾ������
[rows,cols] = size(I);
x = ones(rows,1)*[1:cols];
y = [1:rows]'*ones(1,cols);
area = sum(sum(I));
meanx = int16(sum(sum(I.*x))/area);
meany = int16(sum(sum(I.*y))/area);
end