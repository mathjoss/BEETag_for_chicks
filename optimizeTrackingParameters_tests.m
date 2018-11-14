function [brThresh brFilt optTime] = optimizeTrackingParameters_tests(vid, threshVals, filtVals, nframes, taglist, chick_number)

%% This function is used if you want to optimize frames with the main function : tracking_coordinator_tests


%Inputs:
%vid: VideoReader object
%threshVals - range of bradley threshold values to test
%filtVals - range of bradley threshold values to test
%nframes - how many frames to sample over?


%Outputs:
%brThresh - optimal threshold value
%brFilt - optimal filter size value


% nframes = 20
% chick_number = 17
% i = 1
%  namevideo = char(strcat('C:\Users\bastien.lemaire\Desktop\videos\chick', num2str(chick_number), '_d', num2str(i), '.avi')) ;
% video = dir(fullfile(namevideo));
% vid = VideoReader(video.name);
% threshVals =1:6
% filtVals =9:18
% tagList = 491


addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src\bradley\bradley')
   
%create temporary directory to save images
workingDir = 'C:\Users\bastien.lemaire\Desktop\videos\Temporary';
mkdir(workingDir)

%save images 
for ii=[1:nframes]
    img = read(vid, ii);
    filename = [sprintf('%8d',ii) '.jpg'];
    fullname = fullfile(workingDir, filename);
    imwrite(img,fullname);
end

%save all selected image names in an array
imageNames = dir(fullfile(workingDir,'*.jpg'));
imageNames = {imageNames.name}';


%create a new reduced video putting selected images together
namevideooutput = strcat('C:\Users\bastien.lemaire\Desktop\videos\delete_this_after_optimizing_', num2str(chick_number), num2str(i), '.avi') ;
outputVideo = VideoWriter(namevideooutput);
%outputVideo.FrameRate = mov.FrameRate/step;
outputVideo.FrameRate = 1;
open(outputVideo)
for ii = 1:length(imageNames)
   img = imread(fullfile(workingDir,imageNames{ii}));
   writeVideo(outputVideo,img)
end
close(outputVideo)

%delete temporary folder with all the selected images
rmdir(workingDir, 's'); 


vid = VideoReader(namevideooutput); %Make a VideoReader object for the movie
nframes = vid.NumberOfFrames ;

%% Track across frames
frameIndex = round(linspace(1,vid.NumberOfFrames, nframes));
outData = nan(numel(threshVals), numel(filtVals), nframes,2);
%h = waitbar(0, 'Optimizing tracking across frames...');

for i = 1:nframes
    %%
    %i
    disp(strcat('Optimization started, optimization on frame_', num2str(i), '_out of_', num2str(nframes))) ;
    im = rgb2gray(read(vid,frameIndex(i)));
    imshow(im);
    for j = 1:numel(threshVals)
        %j
        for k = 1:numel(filtVals)
            %k
            tic
            %F = locateCodes(im,'threshMode', 1,'sizeThresh', [300 1500], 'bradleyFilterSize', [filtVals(k) filtVals(k)], 'bradleyThreshold', threshVals(j), 'vis', 0);
            F = locateCodes(im,'threshMode', 1,'sizeThresh', 50, 'bradleyFilterSize', [filtVals(k) filtVals(k)], 'bradleyThreshold', threshVals(j), 'vis', 0);
            timeS = toc;
            if ~isempty(F)
                outData(j,k,i,1) = sum(ismember([F.number], taglist));
                
            end
            outData(j,k,i,2) = timeS;
        end
    end
    %waitbar(i/nframes,h) ;
end

%% Normalize and plot
outData(isnan(outData)) = 0; %Replace nans with zeros;

nbees = sum(outData(:,:,:,1),3);
nbeesNorm = nbees./max(max(nbees));
%Visualize performance surface

%% Identify maxima
[r,c] = find(nbeesNorm == 1);
brThresh = threshVals(r);
brFilt = filtVals(c);


%% track time spent 
timeSpent = outData(:,:,:,2);
timeSpent = mean(timeSpent,3);
optTime = timeSpent(find(nbeesNorm == 1));

%% break ties with time performance
if numel(brThresh) > 1 %If there's more than one optimum
    ind = find(optTime == min(optTime));
    ind = ind(1); %Tie breaker
    brThresh = brThresh(ind);
    brFilt = brFilt(ind);
    [r,c] = find(timeSpent == optTime(ind));
end
% 
% subplot(2,1,1);
% imagesc(nbees);
% colormap hot
% set(gca, 'XTick', 1:numel(filtVals), 'XTickLabels', filtVals, 'YTick', 1:numel(threshVals), 'YTickLabels', threshVals);
% colorbar
% hold on
% plot(c,r, 'go', 'MarkerSize', 30);
% text(c,r,strcat('Optimum: thresh = ', num2str(brThresh), ',filter size = ', num2str(brFilt)));
% hold off
% subplot(2,1,2);
% imagesc(timeSpent);
% colormap hot
% colorbar
% hold on
% plot(c,r, 'go', 'MarkerSize', 30);
% hold off
