%%% 

% This files will help you to create a video out of many different videos.

% Inputs : many videos
% Outputs : a single video

% Before running the program, read it until the end and make sure you changed :

%   - chicks_number
%   - days
%   - which frames you want to take in each video
%   - how you want to crop your frames
%   - output name

% This program should be in the same folder with the videos, or you need to
% change the path in inputfile and outputfilename.

%%% 

% Once you changed all this values, you can run the program !

%%%

%create temporary directory to save images
workingDir = 'C:\Users\bastien.lemaire\Desktop\videos';
mkdir(workingDir)

% select the chicks number from which you want to take videos
for chick = [11 13 15 17 18 22 24 31 32 35 36 43 48 50 53 54 56 69 70 71 72 79 80 81 82 83]

    % select days from which you want to take videos
    for day = [1 2 3 4 5 6]
        
        % create video name
        inputfile = strcat('chick',num2str(chick), '_d', num2str(day), '.avi')
        
        % load video
        mov = VideoReader(inputfile);

        % select when and how many frames you want to select in each videos
        for ii=[12000:12015]
           
           % read frame
           img = read(mov, ii);
           
           % crop images so they are all the same sized
           J = imcrop(img,[0 0 1280 630]);
           
           % write every frame in the workingdir folder
           filename = strcat(num2str(chick), 'day', num2str(day), '_image_', [sprintf('%8d',ii) '.jpg']);
           fullname = fullfile(workingDir, filename);
           imwrite(J,fullname);
        end

        %save all selected image names in an array
        imageNames = dir(fullfile(workingDir,'*.jpg'));
        imageNames = {imageNames.name}';
    end
end

%% Create a new reduced video putting selected images together
disp(['Creating reduced video...'])

% select the name of your output video
outputVideo = VideoWriter('shortvideo2.avi');

% select the frame rate of your output video
outputVideo.FrameRate = mov.FrameRate;

% write all images saved previously into a video
open(outputVideo)
for ii = 1:length(imageNames)
   img = imread(fullfile(workingDir,imageNames{ii}));
   writeVideo(outputVideo,img)
end
close(outputVideo)

%delete temporary folder with all the selected images
rmdir(workingDir, 's'); 
