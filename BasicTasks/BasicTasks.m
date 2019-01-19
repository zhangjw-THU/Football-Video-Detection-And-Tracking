clear
close all;
warning off;
videoname = './videos/4.mp4';%%参数适合视频1——8
Ball = 5;
obj = VideoReader(videoname);
NumFrames= obj.NumberOfFrames;
Frames = cell(NumFrames,1);
obj = VideoReader(videoname);
for ii=1:NumFrames
    Frames{ii} = rgb2gray(readFrame(obj));
end
Background = GetBackground(Frames,NumFrames);

obj = VideoReader(videoname);
firstframe = readFrame(obj);
figure(1),imshow(firstframe);
title('点选球的中心点并回车')
[x,y,r] = initial(firstframe);
%%
% 记录下初始坐标并存入lines中
count = 1;
lines = [];
radis = [];
radis(count) = r;
lines(count,:) = [x,y];
%%
segs = [];
frame = readFrame(obj);
ii=count;
while obj.CurrentTime<obj.Duration
    %初步确定足球位置
    ballground = segment(frame,firstframe,x,y);
    %figure(2),imshow(ballground);
    [x,y] = calcenter(ballground);
    if(x==0||y==0)
        %[x,y] = initial(frame);
        x = lines(end,1);
        y = lines(end,2);
    end
    
    %精确测量
    Reballground = ReSegment(frame,Background,x,y);
    if(count>151)
        cc=4;
    end
    
    if(count>0)
        rs = radis;
        [Reballground,rex,rey,radis(ii),Flag] = ReSegmentAndcalcenter(Reballground,ballground,x,y,rs,count);
    end
    if(~Flag)
        break;
    end
    
    %figure(2),imshow(Reballground)
    %viscircle([ftx,fty], radis(ii),'EdgeColor','b');
    figure(1),imshow(frame)
    viscircles([rex,rey],radis(ii),'EdgeColor','r');
    count = count+1;
    hold on
    lines(count,:) = [rex,rey];
    hold off
    
    segs(ii,:,:) = Reballground;
    ii = ii+1;
    
    firstframe = frame;
    frame = readFrame(obj);
    
end

%% 最终显示
I = frame;
P = polyfit(lines(:,1),lines(:,2),3);
xi = lines(:,1);
yi = polyval(P,xi);
lines(:,1) = xi;
lines(:,2) = yi;
[rows,cols] = size(I(:,:,1));
X = ones(rows,1)*[1:cols];
Y = [1:rows]'*ones(1,cols);
Imask = zeros(size(I(:,:,1))); 
c = lines(end,:);
r = mean(radis(:));
Imask = ((X-c(1)).*(X-c(1))+(Y-c(2)).*(Y-c(2))<r*r);
for kk = 1:3
    I(:,:,kk) = I(:,:,kk).*uint8(1-Imask)+uint8(Imask).*255;
end
figure(1),imshow(I)
viscircles([lines(end,1),lines(end,2)], mean(radis(:)),'EdgeColor','b');
hold on;
%plot(xi,yi,'r-');
plot(lines(:,1),lines(:,2),'r-');
hold on;
title('红色为轨迹/白色为足球分割结果/蓝色为足球检测框')
%%
%   处理完每一帧后，根据保存的足球分割图集segs，结合一些先验知识，计算足球面积、估算球速等
[Speeds,MeanSpeed,MaxSpeed] = calspeed(segs,radis,Ball,lines);
disp(['平均速度（m/s）：',num2str(MeanSpeed)]);
disp(['最大速度（m/s）：',num2str(MaxSpeed)]);
figure,plot(Speeds,'x-r')
ylabel('速度（m/s）');
xlabel('帧数');
title('速度曲线');