%% 初始化函数

function [x,y,r] = initial(I)

[x,y] = ginput();
x = round(x);
y = round(y);
h = 10;
w = 10;
Ig = rgb2gray(I);
I1edge = zeros(size(Ig));
Igedge = edge(Ig,'canny',[0.04,0.10],1.5);
I1edge(y-h:y+h,x-w:x+w) = Igedge(y-h:y+h,x-w:x+w);
[c,r]=imfindcircles(I1edge,[1,8]);

if(isempty(r))%如果没有检测到球
    c = [x,y];
    r = 4.65;
end
if(length(r)>1)%如果检测到多个球
    c = c(1,:);
    r = r(1);
end
figure(1),imshow(I)
viscircles(c, r,'EdgeColor','b');
c = round(c);
x = c(1);
y = c(2);
end