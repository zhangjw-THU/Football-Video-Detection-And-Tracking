function ballground = segment(frame,firstframe,x,y)
%         ����Ҫ���������ÿһ֡������ǰ���ָ�
%         ʾ������
h = 20;
w = 20;
bw = rgb2gray(firstframe);
bw2 = rgb2gray(frame);
mask = zeros(size(bw2));
mask(y-h:y+h,x-w:x+w) = 1;
ballground = mask&(abs(bw2-bw)>20);
B = ones(2);
ballground = imerode(ballground,B);
ballground = imdilate(ballground,B);
end