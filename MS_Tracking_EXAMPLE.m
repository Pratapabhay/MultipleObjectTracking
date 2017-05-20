
clear all
close all

tic
[Length,height,width,Movie]=...
    Import_mov('Videos/dance.avi');
toc

%% Variables 
index_start = 1;
% Similarity Threshold
f_thresh = 0.16;
% Number max of iterations to converge
max_it = 10;
% Parzen window parameters
kernel_type = 'Gaussian';
radius = 1;

%% Target Selection in Reference Frame
[T,x0,y0,H,W] = Select_patch(Movie(index_start).cdata,0);
[T1,x1_0,y1_0,H1,W1] = Select_patch(Movie(index_start).cdata,0);
[T2,x2_0,y2_0,H2,W2] = Select_patch(Movie(index_start).cdata,0);

pause(0.2);

%% Run the Mean-Shift algorithm

[k,gx,gy] = Parzen_window(H,W,radius,kernel_type,0);
[k1,gx1,gy1] = Parzen_window(H1,W1,radius,kernel_type,0);
[k2,gx2,gy2] = Parzen_window(H2,W2,radius,kernel_type,0);

% Compute the colour probability functions (PDFs)
[I,map] = rgb2ind(Movie(index_start).cdata,65536);
Lmap = length(map)+1;


T = rgb2ind(T,map);
T1 = rgb2ind(T1,map);
T2 = rgb2ind(T2,map);


% Estimation of the target PDF
q = Density_estim(T,Lmap,k,H,W,0);
q1 = Density_estim(T1,Lmap,k1,H1,W1,0);
q2 = Density_estim(T2,Lmap,k2,H2,W2,0);



% Flag for target loss
loss = 0;
loss1 = 0;
loss2 = 0;


% Similarity evolution along tracking
f = zeros(1,(Length-1)*max_it);
f1 = zeros(1,(Length-1)*max_it);
f2 = zeros(1,(Length-1)*max_it);


% Sum of iterations along tracking and index of f
f_indx = 1;
f_indx1 = 1;
f_indx2 = 1;


% Draw the selected target in the first frame
Movie(index_start).cdata = Draw_target(x0,y0,W,H,...
    Movie(index_start).cdata,2);
    
Movie(index_start).cdata = Draw_target1(x1_0,y1_0,W1,H1,...
    Movie(index_start).cdata,2);
    
Movie(index_start).cdata = Draw_target2(x2_0,y2_0,W2,H2,...
    Movie(index_start).cdata,2);
    
    
    
    
 flag =0;
 flag1=0;  
 flag2=0; 
    
    
%%%% TRACKING
WaitBar = waitbar(0,'Tracking in progress, be patient...');
% From 1st frame to last one
for t=1:Length-1
    % Next frame
    I2 = rgb2ind(Movie(t+1).cdata,map);
    
    
    % Apply the Mean-Shift algorithm to move (x,y)
    % to the target location in the next frame.
    
    if flag==0
    
    [x,y,loss,f,f_indx] = MeanShift_Tracking(q,I2,Lmap,...
        height,width,f_thresh,max_it,x0,y0,H,W,k,gx,...
        gy,f,f_indx,loss);
        
    end
   
   if flag1==0
   	
    [x1,y1,loss1,f1,f_indx1] = MeanShift_Tracking1(q1,I2,Lmap,...
        height,width,f_thresh,max_it,x1_0,y1_0,H1,W1,k1,gx1,...
        gy1,f1,f_indx1,loss1);
   end
   
    if flag2==0
   	
    [x2,y2,loss2,f2,f_indx2] = MeanShift_Tracking(q2,I2,Lmap,...
        height,width,f_thresh,max_it,x2_0,y2_0,H2,W2,k2,gx2,...
        gy2,f2,f_indx2,loss2);
   end
   
   
   
    % Check for target loss. If true, end the tracking
    if loss == 1
        flag = 1
    else
        % Drawing the target location in the next frame
        Movie(t+1).cdata = Draw_target(x,y,W,H,Movie(t+1).cdata,2);
        
        % Next frame becomes current frame
        y0 = y;
        x0 = x;
        
       
        % Updating the waitbar
        waitbar(t/(Length-1));
    end
    
    
     if loss1 == 1
        flag1 = 1
     else
        % Drawing the target location in the next frame
         Movie(t+1).cdata = Draw_target1(x1,y1,W1,H1,Movie(t+1).cdata,2);
        
        y1_0 = y1;
        x1_0 = x1;
        % Updating the waitbar
        waitbar(t/(Length-1));
    end
    
    if loss2 == 1
        flag2 = 1
     else
        % Drawing the target location in the next frame
         Movie(t+1).cdata = Draw_target2(x2,y2,W2,H2,Movie(t+1).cdata,2);
        
        y2_0 = y2;
        x2_0 = x2;
        % Updating the waitbar
        waitbar(t/(Length-1));
    end
    
    
	if flag1==1 && flag==1 && flag2==1
		break;
	end
    
    
    
end
close(WaitBar);
%%%% End of TRACKING

%% Export/Show the processed movie
% Export the video sequence as an AVI file in the Videos folder
% WaitBar = waitbar(0,'Exporting the output AVI file, be patient...');

v = VideoWriter('Videos\Movie_out.avi');
open(v);
writeVideo(v, Movie);
close(v);
 
% waitbar(1);
% close(WaitBar);

% Put a figure in the center of the screen,
% without menu bar and axes.
scrsz = get(0,'ScreenSize');
figure(1)
set(1,'Name','Movie Player','Position',...
    [scrsz(3)/2-width/2 scrsz(4)/2-height/2 width height],...
    'MenuBar','none');
axis off
% Image position inside the figure
set(gca,'Units','pixels','Position',[1 1 width height])
% Play the movie
movie(Movie);

%% End of File
%=============%
