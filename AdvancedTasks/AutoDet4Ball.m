close all
clear
path = 'videos/0.mp4';
Ball = 4;
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
    if(i<10)
        continue;
    end
    [centroids, bboxes, mask] = detectObjects(frame,obj);
 
    if(FirstBallFlag)
        masktmp = zeros(size(mask));
        masktmp(xtmp-150:xtmp+150,ytmp-150:ytmp+150) = 1;
        mask = mask;
    end
  
    predictNewLocationsOfTracks(tracks);
    Igedge = edge(mask,'canny',[0.04,0.10],1.5);
    [c,r]=imfindcircles(Igedge,[5,20]);
   
    if((~isempty(r)) && (FirstBallFlag==false))
        if(length(r)>1)
            [~,position] = max(r(:));
            r = r(position);
            c = c(position,:);
        end
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
        continue;
        linesNum = linesNum+1;
        lines(linesNum,:) = [-1,-1];
        radis(linesNum) = 0;
        segs(linesNum,:,:) = mask;

    end
    if((FirstBallFlag==1) && length(r)>=1)
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
    figure(2),imshow(frametmp),viscircles(c, r,'EdgeColor','b');
end
[lines,radis,linesNum] = interpolation(lines,radis,linesNum);
[lines,radis,linesNum] = RomverBurry(lines,radis,linesNum);
figure(2),imshow(frametmp)
hold on
viscircles([lines(linesNum,2),lines(linesNum,1)], radis(linesNum),'EdgeColor','b');
plot(lines(:,2),lines(:,1),'r-');
hold off

[Speeds,MeanSpeed,MaxSpeed] = calspeed(segs,radis,Ball,lines);
disp(['平均速度（m/s）：',num2str(MeanSpeed)]);
disp(['最大速度（m/s）：',num2str(MaxSpeed)]);
figure,plot(Speeds,'x-r')
ylabel('速度（m/s）');
xlabel('帧数');
title('速度曲线');
