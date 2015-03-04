%%FacePulse - try to calculate your purse using the webcam!

function t = facepulse
global cam recX recY idx p q a;

close all;

rImage = zeros(360,640,3);

%rectangle coordinates
recX = [128:191];
recY = [256:383];

%plot line
p = zeros(64,1);
%p = 0;
q = zeros(64,1);

%figure(1);
figure(2);

idx = 1;

t = timer;

%create object for passing data to camera
t.TimerFcn = @facepulse_processFrame;
t.Period = 0.2;
t.StartDelay = 1;
t.ExecutionMode = 'fixedRate';

a = clock;
start(t);
    
    
end

function facepulse_processFrame(mTimer,~)
global cam recX recY idx p q a;
        
       % Acquire a single image.
       rgbImage = snapshot(cam);
       
       %clock check
       a_old = a;
       a = clock;
       disp(a(6) - a_old(6));
       
       rgbImage = fliplr(imresize(rgbImage, 0.5));

       %overlay rectangle
       rImage = rgbImage;
       rImage(recX, recY,2:3) = 0.5;

       %show image
       %figure(2); imshow(rImage); drawnow;

       %run fourier analysis on ROI in the green channel
       ROI = rgbImage(recX, recY,2);
       %ROI = rgbImage(:,:,1);

       %get average in ROI
       m = mean(ROI(:));

       %p(mod(idx,64)+1) = m;
       %add to p, replace first element
       if length(p) > 64
        p(1) = [];
       end
       p(end+1) = m;
       
       %detrend
       r = detrend(p);
       %r = p - mean(p);

       %do fft and show real component
       q = abs(real(fft(r,256)));

       %truncate
       q = q(1:128);
       
       %look only at frequency range 0.5 - 1.5 Hz
       %128 pixels evenly spaced from 0 - 2.5 Hz
       q = q(26:75);
       
       
       %get peak
       [mx i] = max(q);
       

       subplot(2,2,1); plot(r);
       subplot(2,2,2); plot(q); set(gca,'XTick',0:2.5:50,'XTickLabel', 30:3:90);
       subplot(2,2,3); imshow(rImage); 
       drawnow;
    
       idx = idx + 1;
end