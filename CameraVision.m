% Steps 1-5 are "initializations".
% Step 6 is the actual visual w/ color filtering once you do 1-5.
%% 1. Connect to Camera
clear; clc;
% Plug in a camera to your computer
% Find it with "webcamlist" in the command line. Put that in webcam().
webcamlist
cam=webcam('HD Web Camera');
%% 2. Camera On
% Check to make sure it works with this. The frame rate here is good,
% but will drop when using the color filter.
% You can use this to position the camera and take a snapshot of the
% current display, but close the preview afterwards.
preview(cam)
%% 3. Capture and Save Image
% This takes an image of whatever the camera is looking at and saves it to
% your file. Feed this image into the next step.
% ***Make sure to take an image of ALL 3 COLORS (Red, Green, Blue) IN THE SAME PICTURE.
% Ideally, each color is as red, green, or blue as possible (not green-blue
% or any mixture of colors).***
% ***Also make sure to take a picture on a plain background (just white paper
% works very well with nothing else in the shot).
img=snapshot(cam);
imshow(img)
imsave %RGBBoxes.png for reference
%% Camera Calibration
%cameraCalibrator
%% 4. Undistorting the Image with Intrinsic Camera Parameters
% This will undistort the image from a fisheye into more of a rectangular
% image. It is optional, but recommended, if this does not work very well,
% skip the step.
% Save the image and feed into Step 5 colorThresholder.
load('cameraParams.mat')
img=imread('RGBBoxes.png'); % <---put the saved image from last step here
figure;
[UDimg, newOrigin] = undistortImage(img, cameraParams, 'OutputView', 'valid');
% Subplot Comparison
%subplot(1,2,1); imshow(img); title('Distorted by fisheye lens')
%subplot(1,2,2); imshow(img); title('Undistorted')
imshow(UDimg)
imsave %RGBBoxesUD.png for reference
%% 5. Creating Color Filter
% Open program, load in the undistorted image from Step 5, or image from
% Step 3 if Step 4 was skipped.
% Double click HSV. If the image was taken with just the 3 different color
% boxes on white paper, all you will have to do is drag the "saturation"
% slider to about 0.2-0.4. This should black out everything and leave the
% boxes visible.
% Click Export Function and save as "colorVision".
colorThresholder
%% Create Binary Mask (RGB->Binary), Identify Box Color, Draw Boundary and Label
% To close out, press the command window and CTRL+C a bunch of times.
B{1}(:,2)=2620/2; B{1}(:,1)=1133/2;
while true
    img=snapshot(cam);
    [img_undistorted, newOrigin] = undistortImage(img, cameraParams, 'OutputView', 'valid');
    [BW,RGBmasked]=colorVision(img_undistorted);
    B = bwboundaries(BW,'noholes');

    redChannel=RGBmasked(:,:,1);
    greenChannel=RGBmasked(:,:,2);
    blueChannel=RGBmasked(:,:,3);
    channels = [max(max(redChannel)),max(max(greenChannel)),max(max(blueChannel))];
    [maxRGBval,idx]=max(channels);
    if maxRGBval == 0
        box_id_str='No Box In Sight';
        B{1}(:,2)=2620/2; B{1}(:,1)=1133/2;
    elseif idx==1
        box_id_str='Red Box';
        box_label_x = B{1}(:,2); box_label_y = B{1}(:,1);
    elseif idx==2
        box_id_str='Green Box';
        box_label_x = B{1}(:,2); box_label_y = B{1}(:,1);
    else
        box_id_str='Blue Box';  
        box_label_x = B{1}(:,2); box_label_y = B{1}(:,1);
    end
    
    %imshow(BW); <---will show black/white image
    %imshow(RGBmasked); <---will show only colored box
    imshow(img_undistorted); %<---will show real view with color filter
    hold on; plot(box_label_x,box_label_y,'w', 'LineWidth', 2)
    text(max(box_label_x),max(box_label_y),box_id_str,'FontSize',14,'Color','yellow')
    drawnow limitrate
end
%% Camera Off
closePreview(cam)