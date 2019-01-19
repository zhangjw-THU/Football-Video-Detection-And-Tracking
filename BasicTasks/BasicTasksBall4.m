clear
close all;
warning off;
videoname = './videos/0.mp4';
Ball = 4;
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
title('��ѡ������ĵ㲢�س�')
[x,y,r] = initialBall4(firstframe);
%%
% ��¼�³�ʼ���겢����lines��
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
    %����ȷ������λ��
    ballground = segment(frame,firstframe,x,y);
    %figure(2),imshow(ballground);
    [x,y] = calcenter(ballground);
    if(x==0||y==0)
        %[x,y] = initial(frame);
        x = lines(end,1);
        y = lines(end,2);
    end
    
    %��ȷ����
    Reballground = ReSegmentBall4(frame,Background,lines(count,1),lines(count,2));
    %figure(3),imshow(Reballground);
    if(count>151)
        cc=4;
    end
    
    if(count>0)
        rs = radis;
        %���ݻҶ�ͼ�ж�
        %[ballground,ftx,fty,radis(ii)]= SegmentAndcalcenter(frame,firstframe,x,y,rs);
        %���ݷָ�ͼ�ж�
        [Reballground,rex,rey,radis(ii),Flag] = ReSegmentAndcalcenterBall4(Reballground,ballground,x,y,rs,count);
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
    plot(lines(:,1),lines(:,2),'r-');
    hold off
    
    segs(ii,:,:) = Reballground;
    ii = ii+1;
    
    firstframe = frame;
    frame = readFrame(obj);
    
end

%%
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
plot(xi,yi,'r-');
hold on;
title('��ɫΪ�켣/��ɫΪ����ָ���/��ɫΪ�������')
%%
%   ������ÿһ֡�󣬸��ݱ��������ָ�ͼ��segs�����һЩ����֪ʶ����������������������ٵ�
[Speeds,MeanSpeed,MaxSpeed] = calspeedBall4(segs,radis,Ball,lines);
disp(['ƽ���ٶȣ�m/s����',num2str(MeanSpeed)]);
disp(['����ٶȣ�m/s����',num2str(MaxSpeed)]);
figure,plot(Speeds,'x-r')
ylabel('�ٶȣ�m/s��');
xlabel('֡��');
title('�ٶ�����');
%% ��ʼ������

function [x,y,r] = initialBall4(I)
%         ����Ҫ��������������ĳ�ʼ��
%         ʾ������
figure(1),imshow(I)
[x,y] = ginput();
x = round(x);
y = round(y);
h = 30;
w = 30;
Ig = rgb2gray(I);
I1edge = zeros(size(Ig));
Igedge = edge(Ig,'canny',[0.01,0.05],0.8);
I1edge(y-h:y+h,x-w:x+w) = Igedge(y-h:y+h,x-w:x+w);
[c,r]=imfindcircles(I1edge,[1,20]);

if(isempty(r))%���û�м�⵽��
    c = [x,y];
    r = 15;
end
if(length(r)>1)%�����⵽�����
    c = c(1,:);
    r = r(1);
end
c = round(c);
x = c(1);
y = c(2);
end



%% 
function ballground = ReSegmentBall4(frame,Background,x,y)
h = 40;
w = 40;
bw = rgb2gray(frame);
mask = zeros(size(bw));
mask(y-h:y+h,x-w:x+w) = 1;
ballground = mask.*(abs(bw-Background)>50);
B = ones(2);
ballground = imerode(ballground,B);
ballground = imdilate(ballground,B);
end

%% 
function [Reballground,meanx,meany,r,Flag] = ReSegmentAndcalcenterBall4(I,ballground,x,y,rs,count)
Flag = true;
h = 100;
w = 100;
Iedge = edge(I,'canny',[0.01,0.05],0.8);
[c,r]=imfindcircles(Iedge,[1,20]);

if(count<1)
    meanx = x;
    meany = y;
    r = rs(1);
    Reballground = ballground;
end

if(count>=1)
    if(length(r)==1&&r<10)
        r = mean(rs(:));
    end
    if(isempty(r))%���û�м�⵽��
        [rows,cols] = size(I);
        x = ones(rows,1)*[1:cols];
        y = [1:rows]'*ones(1,cols);
        area = sum(sum(I));
        c(1) = int16(sum(sum(I.*x))/area);
        c(2) = int16(sum(sum(I.*y))/area);
        r = mean(rs(:));
    end
    
    if(length(r)>1)%�����⵽�����
        [~,position] = max(r);
        c = c(position,:);
        r = r(position);
    end
    
    meanx = round(c(1));
    meany = round(c(2));
    
    if(meanx==0||meany==0)
        [rows,cols] = size(I);
        x = ones(rows,1)*[1:cols];
        y = [1:rows]'*ones(1,cols);
        area = sum(sum(ballground));
        c(1) = int16(sum(sum(ballground.*x))/area);
        c(2) = int16(sum(sum(ballground.*y))/area);
        meanx = round(c(1));
        meany = round(c(2));
    end
    
    if(meanx==0||meany==0)
        Flag = false;
    end
    [rows,cols] = size(I);
    X = ones(rows,1)*[1:cols];
    Y = [1:rows]'*ones(1,cols);
    Reballground = zeros(size(I));
    c = double(c);
    Reballground = ((X-c(1)).*(X-c(1))+(Y-c(2)).*(Y-c(2))<r*r);
    
end
end

function [Speeds,MeanSpeed,MaxSpeed] = calspeedBall4(segs,radis,Ball,lines)
%         ����Ҫ�����������������ļ�������ٵĹ���
%         ʾ������
% ���ֱ��cm:1---5��
DBalls = [8,15,18,19,21.5];
Radis = radis(10:end-10);
TimePer = 0.033;
DMean = 2*mean(Radis(:));
CmPerPix = DBalls(Ball)/DMean;
Lines = lines(20:end-10,:);%ǰ20�ͺ�10�µ�������
[PointsNum,~] = size(Lines);
Speeds = zeros(PointsNum-1,1);
Distance = 0;
for ii=1:PointsNum-1    
    Dis = sqrt((Lines(ii,1)-Lines(ii+1,1))*(Lines(ii,1)-Lines(ii+1,1))+(Lines(ii,2)-Lines(ii+1,2))*(Lines(ii,2)-Lines(ii+1,2)))*CmPerPix;
    Distance = Distance + Dis;
    Speeds(ii) = Dis/TimePer;
    if(ii>1 && Speeds(ii)==0)
        Speeds(ii) = Speeds(ii-1);
    end
end
speed = zeros(PointsNum-5,1);
for ii=3:PointsNum-3
    speed(ii-2) = mean(Speeds(ii-2:ii+2));
end
Speeds = speed.*8/100;   
MeanSpeed = Distance/((PointsNum-1)*TimePer).*8/100;
MaxSpeed = max(Speeds(:));
end