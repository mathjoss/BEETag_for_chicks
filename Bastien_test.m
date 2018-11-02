%BEFORE STARTING:
%- Open the script "trackBEEtagsAcrossFrames.m" and change the tag number
%according to the number of the chick (line 3)
%- In the excel file "sessions_settings_ethovision_matlab.xlsx" rewrite
%manually the entries in the column named "familiar object position"
%- In this script, remember to change the video name for the variable
%"video" (line ADD)
%- In this script, remember to check the bins duration according to the
%lenght of the session, then change accordingly the variable "bin" and the


addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src\bradley\bradley')


%write the name of the sheet with the data on excel
videoname = 'C:\Users\bastien.lemaire\Desktop\videos\tags\chick1_bigtag_middle.avi'

% write the name of the output file 
outputfile_name = char(strcat('C:\Users\bastien.lemaire\Desktop\videos\chick1_middletag_side.csv')) ;

%write the code number
codelist = [15]

%write the frames you want to analyze
frames = [1:240] ;

% select side where stimuli is displayed
fam_position = 'left';

%Choose the angle between the chick and the horizontal plan, in which you assume the chick 'sees' the screen
choice_angle = 15;

% indicate a number of frame that does not work (this frame will be erased and replaced by the previous frame)
bad = [] ;

% add path to the folder src and bradley
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src\bradley\bradley')


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
    brThresh = 2 ;
    brFilt = 11 ;
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
ninty_cm = corner2 - corner1;
thirty_cm = round(ninty_cm/3);
arena_center = round(ninty_cm/2);

% if there is a problematic frame, remove it from frames
new_frames = frames ;
if isempty(bad)==0
    new_frames(find(new_frames==bad)) = bad-1 ;
end

%%%     Initialize variables

% incr measures the number of frames tracked  :
incr = 0 ;
incr2 = 0;

% session_track is a more convenient structure to use to have the result of the tracking
session_track = struct();

% those variables will be used to measure the orientation of the chick
binocular_familiar = 0  ; left_eye = 0 ; left_eye_withoutbinoc = 0 ; right_eye = 0 ; right_eye_withoutbinoc = 0 ;
binocular_unfamiliar = 0 ; left_eye_unfamiliar = 0 ; left_eye_withoutbinoc_unfamiliar = 0 ; right_eye_unfamiliar = 0 ; right_eye_withoutbinoc_unfamiliar = 0 ;

% track tags inside each frames using the function trackBEEtagsAcrossFrames
trackingDataoutput = trackBEEtagsAcrossFrames(videoname, brThresh, brFilt, new_frames, codelist );



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
        incr2 = incr2 +1
        FS = F([F.number] == codelist);
        if isempty(FS)==0
            incr = incr+1 ;
            session_track(1).CentroidX(p) = FS.Centroid(1);
            session_track(1).CentroidY(p) = FS.Centroid(2);
            session_track(1).FrontX(p) = FS.frontX;
            session_track(1).FrontY(p) = FS.frontY;
            session_track(1).number(p) = FS.number;
            
            %% ORIENTATION
            
            %    compute the angle between an horizontal line and the orientation of the tag
            cosi = sqrt((session_track(1).CentroidX(p)- session_track(1).FrontX(p))^2) / sqrt((session_track(1).CentroidX(p) - session_track(1).FrontX(p))^2 + (session_track(1).CentroidY(p) - session_track(1).FrontY(p))^2) ;
            angle = acosd(cosi) ;
            
            % compute values about the orientation and position of the chick in order to facilitate the next step
            % Those variables can be deleted and replaced in the next step
            OBJ_LEFT = strcmp(fam_position, 'left') ;
            OBJ_RIGHT = strcmp(fam_position, 'right') ;
            POSITION_LEFT = (session_track(1).CentroidX(p) <= (arena_center + thirty_cm/2)) ;
            POSITION_RIGHT = (session_track(1).CentroidX(p) >= (arena_center + thirty_cm/2));
            ORIENTATIONX = sign(session_track(1).CentroidX(p) - session_track(1).FrontX(p));
            ORIENTATIONY = sign(session_track(1).CentroidY(p) - session_track(1).FrontY(p));
            
            
            %%%    check which side the chick is looking at with binocular vision
            
            % familiar side
            if (OBJ_LEFT && POSITION_LEFT && ORIENTATIONX == -1 && angle < choice_angle) || (OBJ_RIGHT && POSITION_RIGHT && ORIENTATIONX == 1 && angle < choice_angle)
                binocular_familiar = binocular_familiar + 1 ;
            end
            % unfamiliar side
            if (OBJ_RIGHT && POSITION_LEFT  && ORIENTATIONX == -1 && angle < choice_angle) || (OBJ_LEFT && POSITION_RIGHT && ORIENTATIONX == 1 && angle < choice_angle)
                binocular_unfamiliar = binocular_unfamiliar + 1 ;
            end
            
            %%%    check which eye the chick use to look at the familiar stimulus
            
            % right eye to familiar stimulus
            if (OBJ_LEFT && POSITION_LEFT && ORIENTATIONY == 1 && (ORIENTATIONX == -1 || (ORIENTATIONX == 1 && angle > 45))) || (OBJ_RIGHT && POSITION_RIGHT && ORIENTATIONY == -1 && (ORIENTATIONX == 1 || (ORIENTATIONX == -1 && angle > 45)))
                right_eye = right_eye + 1 ;
                if angle > choice_angle
                    right_eye_withoutbinoc = right_eye_withoutbinoc +1 ;
                end
            end
            % right eye to unfamiliar stimulus
            if (OBJ_RIGHT && POSITION_LEFT && ORIENTATIONY == 1 && (ORIENTATIONX == -1 || (ORIENTATIONX == 1 && angle > 45))) || (OBJ_LEFT && POSITION_RIGHT && ORIENTATIONY == -1 && (ORIENTATIONX == 1 || (ORIENTATIONX == -1 && angle > 45)))
                right_eye_unfamiliar = right_eye_unfamiliar + 1 ;
                if angle > choice_angle
                    right_eye_withoutbinoc_unfamiliar = right_eye_withoutbinoc_unfamiliar +1 ;
                end
            end
            % left eye to familiar stimulus
            if (OBJ_LEFT && POSITION_LEFT && ORIENTATIONY == -1 && (ORIENTATIONX == -1 || (ORIENTATIONX == 1 && angle > 45))) || (OBJ_RIGHT && POSITION_RIGHT && ORIENTATIONY == 1 && (ORIENTATIONX == 1 || (ORIENTATIONX == -1 && angle > 45)))
                left_eye = left_eye + 1 ;
                if angle > choice_angle
                    left_eye_withoutbinoc = left_eye_withoutbinoc +1 ;
                end
            end
            % left eye to unfamiliar stimulus
            if (OBJ_RIGHT && POSITION_LEFT && ORIENTATIONY == -1 && (ORIENTATIONX == -1 || (ORIENTATIONX == 1 && angle > 45))) || (OBJ_LEFT && POSITION_RIGHT && ORIENTATIONY == 1 && (ORIENTATIONX == 1 || (ORIENTATIONX == -1 && angle > 45)))
                left_eye_unfamiliar = left_eye_unfamiliar + 1 ;
                if angle > choice_angle
                    left_eye_withoutbinoc_unfamiliar = left_eye_withoutbinoc_unfamiliar +1 ;
                end
            end
        end
    end
end

%% POSITION

% x_track (vector with values x) will be used for interpolation
x_track = session_track.CentroidX(frames):length(session_track.CentroidX);

%   preallocate array to store the spatial indications for each frame
area_beetag = categorical();
area_beetag = categorical(area_beetag, {'Left', 'Center', 'Right', 'nan'});

%   change 0 to nan in the tracked coordinates for better counting
for z = 1:length(x_track)
    if x_track(z) == 0
        x_track(z) = nan;
    end
end

%      use "naninterp" function to interpolate NaN values
if length(x_track(~isnan(x_track))) > 1
    x_track_interpol = naninterp(x_track);
else
    x_track_interpol = x_track ;
end

%      detect area for each frame, given the Beetag X coordinates for each frame
for iii = 1: length(x_track_interpol)
    if x_track_interpol(iii) >= corner1  &&  x_track_interpol(iii) <= arena_center - thirty_cm/2
        area_beetag(iii) = 'Left';
    elseif x_track_interpol(iii) > arena_center - thirty_cm/2  && x_track_interpol(iii)< arena_center + thirty_cm/2
        area_beetag(iii) = 'Center';
    elseif x_track_interpol(iii) >= arena_center + thirty_cm/2  && x_track_interpol(iii) <= corner2
        area_beetag(iii) = 'Right';
    else
        area_beetag(iii) = 'nan';
    end
end


%% OVERALL results for each bin

%   count overall secs spent in fields
count_cats = countcats(area_beetag);
cat_names = categories(area_beetag);
locations_overall = [];
for k = 1:length(count_cats)
    locations_overall = setfield(locations_overall, cat_names{k}, count_cats(k));
end


% get seconds spent to familiar/unfamiliar object
locations_overall.Familiar = [];
locations_overall.Unfamiliar = [];
if strcmp(fam_position, 'left') || strcmp(fam_position, 'left ')
    locations_overall.Familiar = locations_overall.Left;
    locations_overall.Unfamiliar = locations_overall.Right;
elseif strcmp(fam_position, 'right') ||strcmp(fam_position, 'right ')
    locations_overall.Familiar = locations_overall.Right;
    locations_overall.Unfamiliar = locations_overall.Left;
end


tot_secs = length(x_track_interpol);
tot_tracked = sum(locations_overall.Left+locations_overall.Center+locations_overall.Right);


%%  CREATE TABLE AND STORE DATA
data_tab = table({sscanf(videoname, 'chick%d')}, length(frames), locations_overall.Left, locations_overall.Right, locations_overall.Center, locations_overall.nan, locations_overall.Familiar, locations_overall.Unfamiliar, tot_tracked, tot_secs, incr, binocular_familiar , binocular_unfamiliar, left_eye, left_eye_unfamiliar, left_eye_withoutbinoc, left_eye_withoutbinoc_unfamiliar, right_eye, right_eye_unfamiliar, right_eye_withoutbinoc, right_eye_withoutbinoc_unfamiliar);

%   define headers for the table
data_tab.Properties.VariableNames = {'CHICK_ID', 'BIN', 'secs_LEFT', 'secs_RIGHT', 'secs_CENTER', 'secs_NAN', 'secs_FAMILIAR', 'secs_UNFAMILIAR', 'TOT_secs_tracked', 'TOT_secs', 'sec_tracked', 'binocular_familiar' , 'binocular_unfamiliar', 'left_eye', 'left_eye_unfamiliar', 'left_eye_withoutbinoc', 'left_eye_withoutbinoc_unfamiliar', 'right_eye', 'right_eye_unfamiliar', 'right_eye_withoutbinoc', 'right_eye_withoutbinoc_unfamiliar'};

%   store table in an xlsx file
writetable(data_tab,outputfile_name)

