clear
close all;
warning off;
videoname = './videos/4.mp4';%%�����ʺ���Ƶ1����8
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
title('��ѡ������ĵ㲢�س�')
[x,y,r] = initial(firstframe);
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

%% ������ʾ
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
title('��ɫΪ�켣/��ɫΪ����ָ���/��ɫΪ�������')
%%
%   ������ÿһ֡�󣬸��ݱ��������ָ�ͼ��segs�����һЩ����֪ʶ����������������������ٵ�
[Speeds,MeanSpeed,MaxSpeed] = calspeed(segs,radis,Ball,lines);
disp(['ƽ���ٶȣ�m/s����',num2str(MeanSpeed)]);
disp(['����ٶȣ�m/s����',num2str(MaxSpeed)]);
figure,plot(Speeds,'x-r')
ylabel('�ٶȣ�m/s��');
xlabel('֡��');
title('�ٶ�����');