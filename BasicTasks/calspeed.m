function [Speeds,MeanSpeed,MaxSpeed] = calspeed(segs,radis,Ball,lines)
%         你需要在这里完成足球面积的计算和球速的估算
%         示例代码
% 球的直径cm:1---5号
DBalls = [8,15,18,19,21.5];
Radis = radis(20:end-10);
TimePer = 0.033;
DMean = 2*mean(Radis(:));
CmPerPix = DBalls(Ball)/DMean;
Lines = lines(20:end-10,:);%前20和后10章当做噪声
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
if(PointsNum>100)
    speed = speed(50:end);
elseif(PointsNum>50)
    speed = speed(20:end);
end
Speeds = speed.*8/100;   
MeanSpeed = Distance/((PointsNum-1)*TimePer)*8/100;
MaxSpeed = max(Speeds(:));
end