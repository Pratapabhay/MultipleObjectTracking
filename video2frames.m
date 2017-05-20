video = VideoReader('Lec9.mp4');
Length_Video = video.NumberOfFrames;
Height_Video = video.Height;
Width_Video = video.Width;

 movie_final(1:Length_Video) = struct('cdata', zeros(Height_Video, Width_Video, 3, 'uint8'), 'colormap', []);
v = VideoReader('Lec9.mp4');

k = 1;
% Reading each frame individually
while hasFrame(v)
	movie_final(k).cdata = readFrame(v);
    frame = movie_final(k).cdata;
    imwrite(frame,['Image' int2str(k), '.jpg']);
	k=k+1;
end
