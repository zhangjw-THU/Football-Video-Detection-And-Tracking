function [Ls,Rs,LsNum]=interpolation(lines,radis,linesNum)
%% 将轨迹上未检测出的点进行插值补全

%把尾部没有检测到球的点去点
for ii = linesNum:-1:1
    if(lines(ii)~=-1)
        break;
    end
end
lines = lines(1:ii,:);
radis = radis(1:ii);
linesNum = ii;
%中间补全
for ii=1:linesNum
    if(lines(ii,1)==-1)
        for jj=ii-1:-1:1
            if(lines(jj,1)~=-1)
                break;
            end
        end
        forenum = ii-jj;
        
        for kk = ii+1:1:linesNum
            if(lines(kk,1)~=-1)
                break;
            end
        end
        lastnum = kk-ii;
        
        lines(ii,1) = (forenum*lines(jj,1)+lastnum*lines(kk,1))/(forenum+lastnum);
        lines(ii,2) = (forenum*lines(jj,2)+lastnum*lines(kk,2))/(forenum+lastnum);
        radis(ii) = 0.5*radis(jj)+0.5*radis(kk);
    end
end

Ls = lines;
Rs = radis;
LsNum = linesNum;

end
