function [Ls,Rs,LsNum]=interpolation(lines,radis,linesNum)
%% ���켣��δ�����ĵ���в�ֵ��ȫ

%��β��û�м�⵽��ĵ�ȥ��
for ii = linesNum:-1:1
    if(lines(ii)~=-1)
        break;
    end
end
lines = lines(1:ii,:);
radis = radis(1:ii);
linesNum = ii;
%�м䲹ȫ
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
