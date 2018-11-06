%BEFORE STARTING:
%- Open the script "trackBEEtagsAcrossFrames.m" and change the tag number
%according to the number of the chick (line 3)
%- In the excel file "sessions_settings_ethovision_matlab.xlsx" rewrite
%manually the entries in the column named "familiar object position"
%- In this script, remember to change the video name for the variable
%"video" (line ADD)
%- In this script, remember to check the bins duration according to the
%lenght of the session, then change accordingly the variable "bin" and the

% add path to the folder src and bradley
addpath('D:\ACN\BEEtagBastien_final')
addpath('D:\ACN\\BEEtagBastien_final\src')
addpath('D:\ACN\\BEEtagBastien_final\src\bradley\bradley')


%write the name and path of the video you want to analyze
videoname = 'D:\ACN\Videos\chick1_bigtag_middle.avi';

% write the name of the output file 
outputfile_name = char(strcat('D:\ACN\results\chick1_middletag_side.csv')) ;

%write the code number
codelist = [15] ;

% write the chick number
chick_number = 1 ;

%write the frames you want to analyze
%for example : [1:240] means that you want to analyze frame 1 to 240
frames = [1:325] ;

% select side where stimuli is displayed
fam_positionn = 'left';

%Choose the angle between the chick and the horizontal plan, in which you assume the chick 'sees' the screen
choice_angle = 15;

% indicate a number of frame that does not work (this frame will be erased and replaced by the previous frame)
bad = [] ;



%% RUN THE PROGRAM :) 

%%
%  get total number of frames for each video
my_video = VideoReader(videoname);
endframe = my_video.NumberOfFrames;

% ask users whereas to optimize tracking parameters, or not
optimize = input('Do you want to optimize tracking parameters ? add AT LEAST 2 hours to matlab analysis [y/n] : ', 's') ;
if optimize == 'y'
    disp('optimize tracking parameters started !') ;
    [brThresh brFilt optTime] = optimizeTrackingParameters(my_video, 1:6, 9:15, 200, codelist) ;
    parameters = strcat('_thresh',num2str(brThresh),'_filter',num2str(brFilt)) ;
elseif optimize == 'n'
    disp('base tracking parameters chosen') ;
    brThresh = 4 ;
    brFilt = 12 ;
    parameters = 'condition3' ;
else
    disp('you did not write y or n to this question. Please stop the program (CTRL + C) and run everything again.') ;
end


% preallocate table for data
data_tab = table();
data_tab_p = table();

% select borders of the video
arena_video = VideoReader(videoname);
arena_pic = readFrame(arena_video);
imshow(arena_pic)
arena_border = ginput(2);
corner1 = round(arena_border(1,1));
corner2 = round(arena_border(2,1));

% find the area limits (in our case, the dimension of arena is 90cm and we want areas of 15 cm and 30 cm in the left and right)
far_left_pos = corner1 + ((corner2 - corner1)* 15 )/90;
left_pos = corner1 + ((corner2 - corner1)* 30 )/90;
far_right_pos = corner2 - ((corner2 - corner1)* 15)/90;
right_pos = corner2 - ((corner2 - corner1)* 30)/90;

% if there is a problematic frame, remove it from frames
new_frames = frames ;
if isempty(bad)==0
    new_frames(find(new_frames==bad)) = bad-1 ;
end

%%%     Initialize variables

% session_track is a more convenient structure to use to have the result of the tracking
session_track = struct();

% track tags inside each frames using the function trackBEEtagsAcrossFrames
trackingDataoutput = trackBEEtagsAcrossFrames(videoname, brThresh, brFilt, new_frames, codelist );

% allocate structure for data : orientation_look
orientation_look.Binocular_Familiar = [0] ;
orientation_look.Binocular_Unfamiliar = [0];
orientation_look.Left_Eye_Familiar = [0];
orientation_look.Left_Eye_Monocular_Familiar = [0];
orientation_look.Left_Eye_Unfamiliar = [0];
orientation_look.Left_Eye_Monocular_Unfamiliar = [0];
orientation_look.Right_Eye_Familiar = [0];
orientation_look.Right_Eye_Monocular_Familiar = [0];
orientation_look.Right_Eye_Unfamiliar = [0];
orientation_look.Right_Eye_Monocular_Unfamiliar = [0];

%%%      analyze the file output of trackBEEtagAcrossFrames : trackingDataoutput

for p = new_frames
    
    % F : result of a single frame p
    F = trackingDataoutput(p).F;
    
    % error case : if last frame of a bin is empty, can generate problems with interpolation later
    % because of this error, we write 0 in the last frame of a bin if no tags are detected
    if p==new_frames(length(new_frames)) && isempty(F)==1
        session_track(1).CentroidX(p) = 0;
        session_track(1).CentroidY(p) = 0;
        session_track(1).FrontX(p) = 0;
        session_track(1).FrontY(p) = 0;
        session_track(1).number(p) = 0;
    end
    
    % add values to session_track when tag is detected
    % add values to incr, in order to measure how many tags are detected
    if isempty(F)==0
        FS = F([F.number] == codelist);
        if isempty(FS)==0
            session_track(1).CentroidX(p) = FS.Centroid(1);
            session_track(1).CentroidY(p) = FS.Centroid(2);
            session_track(1).FrontX(p) = FS.frontX;
            session_track(1).FrontY(p) = FS.frontY;
            session_track(1).number(p) = FS.number;
            
            % compute orientation of the taf
            [orientation_look] = find_orientation(session_track, fam_positionn, choice_angle, p, far_left_pos, left_pos, right_pos, far_right_pos, orientation_look, corner1, corner2) ;
            
        end
    end
end

%% POSITION

% compute x_track and y_track (coordinate X and Y) for interpolation
x_track = session_track.CentroidX(new_frames):length(session_track.CentroidX);
y_track = session_track.CentroidY(new_frames):length(session_track.CentroidY);

% change 0 to nan in the tracked coordinates for better counting
x_track(x_track == 0) = NaN ;
y_track(y_track == 0) = NaN ;

% use "naninterp" function to interpolate NaN values
% if only less than 1 value is tracked, then no interpolation
if length(x_track(~isnan(x_track))) > 1
    x_track_interpol = naninterp(x_track);
else
    x_track_interpol = x_track ;
end

% same steps with y_track (y_track will be used to compute the distance moved later)
if length(y_track(~isnan(y_track))) > 1
    y_track_interpol = naninterp(y_track);
else
    y_track_interpol = y_track ;
end

% Calculate distance moved
distance_moved = 0;
for dist = 2:length(x_track_interpol)
    d = sqrt((x_track_interpol(dist)- x_track_interpol(dist-1))^2 + (y_track_interpol(dist)- y_track_interpol(dist-1))^2) ;
    distance_moved = distance_moved + d ;
end

% Find location of the tag in the interpolate x vector
locations_overall = find_location(x_track_interpol, far_left_pos, left_pos, right_pos, far_right_pos, corner1, corner2, fam_positionn);

% create vector without 0 values
x_track_nointerpol = x_track ;
x_track_nointerpol(isnan(x_track_nointerpol)) = [] ;

% number of frames tracked in the bin
total_tracked = length(x_track_nointerpol) ;

% Find location of the tag in the vector without interpolation
locations_not_interpolate = find_location(x_track_nointerpol, far_left_pos, left_pos, right_pos, far_right_pos, corner1, corner2, fam_positionn);

% Find total of seconds tracked
tot_secs = length(x_track_interpol);

% Find total of seconds in the arena
tot_tracked = sum(locations_overall.Far_Left + locations_overall.Left + locations_overall.Center + locations_overall.Right + locations_overall.Far_Right);


%%  CREATE TABLE AND STORE DATA
cell_content = {chick_number, length(new_frames), fam_positionn, locations_overall.Far_Left, locations_overall.Left, locations_overall.Center, locations_overall.Right, locations_overall.Far_Right, locations_overall.nan, locations_overall.Familiar, locations_overall.FamiliarVeryClose, locations_overall.Unfamiliar, locations_overall.UnfamiliarVeryClose, locations_not_interpolate.Far_Left, locations_not_interpolate.Left, locations_not_interpolate.Center, locations_not_interpolate.Right, locations_not_interpolate.Far_Right, locations_not_interpolate.nan, locations_not_interpolate.Familiar, locations_not_interpolate.FamiliarVeryClose, locations_not_interpolate.Unfamiliar, locations_not_interpolate.UnfamiliarVeryClose, tot_tracked, tot_secs, total_tracked, orientation_look.Binocular_Familiar , orientation_look.Binocular_Unfamiliar, orientation_look.Left_Eye_Familiar, orientation_look.Left_Eye_Unfamiliar, orientation_look.Left_Eye_Monocular_Familiar, orientation_look.Left_Eye_Monocular_Unfamiliar, orientation_look.Right_Eye_Familiar, orientation_look.Right_Eye_Unfamiliar, orientation_look.Right_Eye_Monocular_Familiar, orientation_look.Right_Eye_Monocular_Unfamiliar, distance_moved} ;
data_tab = cell2table(cell_content) ;

%   define headers for the table
data_tab.Properties.VariableNames = {'CHICK_ID', 'BIN', 'FAMILIAR_POS', 'secs_FAR_LEFT', 'secs_LEFT', 'secs_CENTER', 'secs_RIGHT', 'secs_FAR_RIGHT', 'secs_NAN', 'secs_FAMILIAR', 'secs_FAMILIAR_VERY_CLOSE', 'secs_UNFAMILIAR', 'secs_UNFAMILIAR_VERY_CLOSE', 'secs_FAR_LEFT_no_interp', 'secs_LEFT_no_interp', 'secs_CENTER_no_interp', 'secs_RIGHT_no_interp', 'secs_FAR_RIGHT_no_interp', 'secs_NAN_no_interp', 'secs_FAMILIAR_no_interp', 'secs_FAMILIAR_VERY_CLOSE_no_interp', 'secs_UNFAMILIAR_no_interp', 'secs_UNFAMILIAR_VERY_CLOSE_no_interp', 'TOT_secs_tracked', 'TOT_secs', 'secs_tracked', 'binocular_familiar' , 'binocular_unfamiliar', 'left_eye_familiar', 'left_eye_unfamiliar', 'left_eye_monoc_familiar', 'left_eye_monoc_unfamiliar', 'right_eye_familiar', 'right_eye_unfamiliar', 'right_eye_monoc_familiar', 'right_eye_monoc_unfamiliar', 'distance_moved'};

%   store table in an xlsx file
writetable(data_tab,outputfile_name) ;





