close all;
clear;
warning off;
path = 'videos/4.mp4';%%适合视频1——8
Ball = 5;
obj = setupSystemObjects(path);
tracks = initializeTracks(); % Create an empty array of tracks.
nextId = 1; % ID of the next track
i = 1;
FirstBallFlag = false;%第一次检测到球的标志
lines = [];
radis = [];
linesNum = 0;
segs = [];
while ~isDone(obj.reader)
    frame = readFrame(obj);
    frametmp = frame;
    i = i+1;
    if(i<20)
        continue;
    end
    [centroids, bboxes, mask] = detectObjects(frame,obj);
    %figure(2),imshow(mask);
    if(FirstBallFlag)
        masktmp = zeros(size(mask));
        masktmp(xtmp-20:xtmp+20,ytmp-20:ytmp+20) = 1;
        mask  = mask.*masktmp;
    end
  
    %figure(3),imshow(mask);
    predictNewLocationsOfTracks(tracks);
    Igedge = edge(mask,'canny',[0.04,0.10],1.5);
    % figure(4),imshow(Igedge);
    [c,r]=imfindcircles(Igedge,[1,8]);
   
    
    %首次检测球
    if((~isempty(r)) && (FirstBallFlag==false))
        FirstBallFlag = true;
        xtmp = round(c(2));
        ytmp = round(c(1));
        linesNum = linesNum+1;
        lines(linesNum,:) = [xtmp,ytmp];
        radis(linesNum) = r;
        segs(linesNum,:,:) = mask;
    end
    
    %再次检测
    %若没有球
    if((FirstBallFlag==1) && isempty(r))
        
        linesNum = linesNum+1;
        lines(linesNum,:) = [-1,-1];%-1表示没有检测到球
        radis(linesNum) = 0;
        segs(linesNum,:,:) = mask;
        continue;
    end
    if((FirstBallFlag==1) && length(r)>=1)
        %找最近的点给接近的点
        if(length(r)>1)
            [c,r]= ChoseCandR(c,r,[lines(linesNum,2),lines(linesNum,1)]);
            xtmp = round(c(1,2));
            ytmp = round(c(1,1));
            c = [0,0];
            c(1) = ytmp;
            c(2) = xtmp;
            r = r(1);
            linesNum = linesNum+1;
            lines(linesNum,:) = [xtmp,ytmp];
            radis(linesNum) = r;
            segs(linesNum,:,:) = mask;
        end
        if(length(r)==1)
            xtmp = round(c(2));
            ytmp = round(c(1));
            linesNum = linesNum+1;
            lines(linesNum,:) = [xtmp,ytmp];
            radis(linesNum) = r;
            segs(linesNum,:,:) = mask;
        end
    end
    figure(1),imshow(frametmp),viscircles(c, r,'EdgeColor','b');
end
%% 未检测到的地方进行插值
[lines,radis,linesNum] = interpolation(lines,radis,linesNum);

%% 显示
% figure(2),imshow(frametmp)
% hold on
% viscircles([lines(linesNum,2),lines(linesNum,1)], radis(linesNum),'EdgeColor','b');
% plot(lines(:,2),lines(:,1),'r-');
% hold off

I = uint8(frame.*255);
P = polyfit(lines(:,2),lines(:,1),3);
yi = lines(:,2);
xi = polyval(P,yi);
lines(:,1) = xi;
lines(:,2) = yi;
[rows,cols] = size(I(:,:,1));
Y = ones(rows,1)*[1:cols];
X = [1:rows]'*ones(1,cols);
Imask = zeros(size(I(:,:,1))); 
c = lines(end,:);
r = mean(radis(:));
Imask = ((X-c(1)).*(X-c(1))+(Y-c(2)).*(Y-c(2))<r*r);
for kk = 1:3
    I(:,:,kk) = I(:,:,kk).*uint8(1-Imask)+uint8(Imask).*255;
end
figure(1),imshow(I)
viscircles([lines(end,2),lines(end,1)], mean(radis(:)),'EdgeColor','b');
hold on;
plot(lines(:,2),lines(:,1),'r-');
hold on;
title('红色为轨迹/白色为足球分割结果/蓝色为足球检测框')


%%检测速度
[Speeds,MeanSpeed,MaxSpeed] = calspeed(segs,radis,Ball,lines);
disp(['平均速度（m/s）：',num2str(MeanSpeed)]);
disp(['最大速度（m/s）：',num2str(MaxSpeed)]);
figure,plot(Speeds,'x-r')
ylabel('速度（m/s）');
xlabel('帧数');
title('速度曲线');