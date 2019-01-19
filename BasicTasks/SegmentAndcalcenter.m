function [ballground,meanx,meany,r]= SegmentAndcalcenter(frame,firstframe,x,y,rs)
%小球
h = 20;
w = 20;
%大球
% h =30;
% w = 30;
bw = rgb2gray(firstframe);
bw2 = rgb2gray(frame);
I1edge = zeros(size(bw2)); 
bw2gedge = edge(bw2,'canny',[0.04,0.10],1.5);
I1edge(y-h:y+h,x-w:x+w) = bw2gedge(y-h:y+h,x-w:x+w);

[c,r]=imfindcircles(I1edge,[1,7]);

if(length(r)==1&&r<2.5)
    r = mean(rs(:));
end
if(isempty(r))%如果没有检测到球
    c = [x,y];
    r = mean(rs(:));
end
if(length(r)>1)%如果检测到多个球
    c = c(1,:);
    r = r(1);
end
[rows,cols] = size(bw2);
X = ones(rows,1)*[1:cols];
Y = [1:rows]'*ones(1,cols);
ballground = zeros(size(bw2)); 
c = double(c);
ballground = ((X-c(1)).*(X-c(1))+(Y-c(2)).*(Y-c(2))<r*r);
meanx = round(c(1));
meany = round(c(2));

figure(3),imshow(frame)
viscircles(c, r,'EdgeColor','b');
end