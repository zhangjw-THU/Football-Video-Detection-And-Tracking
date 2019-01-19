function Background = GetBackground(Frames,Num)
Background = zeros(size(Frames{1}));
for ii = 1:Num
    Background = Background +im2double(Frames{ii});
end
Background = Background./Num;
Background = Background.*255;
Background = uint8(Background);
end