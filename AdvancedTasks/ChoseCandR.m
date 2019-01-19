function [C,R]=ChoseCandR(c,r,lastc)
[~,position] = min(abs(c(:,1)-lastc(1))+abs(c(:,2)-lastc(2)));
C = c(position,:);
R = r(position);
end
