function [Reballground,meanx,meany,r,Flag] = ReSegmentAndcalcenter(I,ballground,x,y,rs,count)
Flag = true;
h = 20;
w = 20;
Iedge = edge(I,'canny',[0.04,0.10],1.5);
[c,r]=imfindcircles(Iedge,[1,7]);

if(count<20)
    meanx = x;
    meany = y;
    r = rs(1);
    Reballground = ballground;
end

if(count>=20)
    if(length(r)==1&&r<2.5)
        r = mean(rs(:));
    end
    if(isempty(r))%如果没有检测到球
        [rows,cols] = size(I);
        x = ones(rows,1)*[1:cols];
        y = [1:rows]'*ones(1,cols);
        area = sum(sum(I));
        c(1) = int16(sum(sum(I.*x))/area);
        c(2) = int16(sum(sum(I.*y))/area);
        r = mean(rs(:));
    end
    
    if(length(r)>1)%如果检测到多个球
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