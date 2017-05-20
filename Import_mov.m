%% Mean-Shift Video Tracking
% by Sylvain Bernhardt
% July 2008
% Updated March 2012
%% Description
% Import a AVI video file from its 'path'.
% The output is its length, size (height,width)
% and the video sequence read by Matlab from
% this AVI file.
%
% [lngth,h,w,mov]=Import_mov(path)

vid = VideoReader('slow.avi');

 numFrames = vid.NumberOfFrames;
 n=numFrames;
 for i = 1:2:n
 frames = readFrame(vid,i);
 imwrite(frames,['Image' int2str(i), '.jpg']);
 im(i)=image(frames);
 end
