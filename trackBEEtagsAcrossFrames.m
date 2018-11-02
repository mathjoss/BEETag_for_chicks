function [trackingData] = trackBEEtagsAcrossFrames(videoname, Thresh, Filt, frames, codelist) %% Beta/example code to track beetags across all frames of a video

%[filename pathname] = uigetfile('*'); %User-specified file input - this can be modified to be automated if you need to track over lots of files

mov = VideoReader(videoname); %Make a VideoReader object for the movie
nframes = mov.NumberOfFrames; %how many frames are in the video?

%Create empty frame for tracking output
trackingData = struct();

%% Loop across frames
for i = frames
%for i=[5124 5127 5128]  
    %% Read in each frames and track codes in it
    disp(strcat('tracking frame_', num2str(i), '_of_', num2str(nframes)));
    im = read(mov, i);
    
    % Locate Codes inside a picture
    % try catch : if there is a problem, continue to run the program
    try
        F = locateCodes(im, 'sizeThresh', 50,  'tagList',codelist,  'threshMode', 1, 'bradleyFilterSize', [Filt Filt], 'bradleyThreshold',Thresh);
    catch
        continue
    end
    
    %Append this single frame data to the master tracking output
    trackingData(i).F = F;
    
end


%% if there's no 'codelist' object defined, extract it from all the unique codes tracked in the movie
if ~exist('codelist')
    for i = frames
        %for i = 1:numel(trackingData)
        curNumbers = [trackingData(i).F.number];
        %%
        if i == 1
            allNumbers = [] ;
        else
            allNumbers = [allNumbers curNumbers];
        end
        codelist = unique(allNumbers);
    end
end



%% Save data
save('trackingData.mat')
end

