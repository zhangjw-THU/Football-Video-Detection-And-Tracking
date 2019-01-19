function [Speeds,MeanSpeed,MaxSpeed] = calspeed(segs,radis,Ball,lines)
%         ����Ҫ�����������������ļ�������ٵĹ���
%         ʾ������
% ���ֱ��cm:1---5��
DBalls = [8,15,18,19,21.5];
Radis = radis(20:end-10);
TimePer = 0.033;
DMean = 2*mean(Radis(:));
CmPerPix = DBalls(Ball)/DMean;
Lines = lines(20:end-10,:);%ǰ20�ͺ�10�µ�������
[PointsNum,dim] = size(Lines);
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
MeanSpeed = mean(Speeds(:));%Distance/((PointsNum-1)*TimePer);
MaxSpeed = max(Speeds(:));
end