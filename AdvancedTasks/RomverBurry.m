function [Ls,Rs,LsNum]=RomverBurry(lines,radis,linesNum)
%% ��һЩë�̵�ȥ��
% �˺��������ڴ��򣬼�1����
%��β��û�м�⵽��ĵ�
rmean = mean(radis(:));
%��ͷȥβ
% for ii = 1:1:linesNum
%     if(abs(radis(ii)-rmean)<5)
%         break;
%     end
% end
% lines = lines(1:ii,:);
% radis = radis(1:ii);
% linesNum = ii;

for ii = linesNum:-1:1
    if(abs(radis(ii)-rmean)<5)
        break;
    end
end
lines = lines(1:ii,:);
radis = radis(1:ii);
linesNum = ii;
%�м䲹ȫ
for ii=1:linesNum
    if(abs(radis(ii)-rmean)>5)
        for jj=ii-1:-1:1
            if(abs(radis(jj)-rmean)<5)
                break;
            end
        end
        forenum = ii-jj;
        
        for kk = ii+1:1:linesNum
            if(abs(radis(kk)-rmean)<5)
                break;
            end
        end
        lastnum = kk-ii;
        
        lines(ii,1) = (forenum*lines(jj,1)+lastnum*lines(kk,1))/(forenum+lastnum);
        lines(ii,2) = (forenum*lines(jj,2)+lastnum*lines(kk,2))/(forenum+lastnum);
        radis(ii) = rmean;
    end
end

Ls = lines;
Rs = radis;
LsNum = linesNum;

end
