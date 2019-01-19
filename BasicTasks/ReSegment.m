function ballground = ReSegment(frame,Background,x,y)
h = 20;
w = 20;
bw = rgb2gray(frame);
mask = zeros(size(bw));
mask(y-h:y+h,x-w:x+w) = 1;
ballground = mask.*(abs(bw-Background)>10);
B = ones(2);
ballground = imerode(ballground,B);
ballground = imdilate(ballground,B);
end
