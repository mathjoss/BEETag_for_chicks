% -------------
% Before to play this script to anylize one chick, you must create the txt
% file corresponding to the chick you want to analyze to give all required
% informnation about it : 
%   - to do so, use the script named transform_xls_txt_files.m


% This program can compute as many days as wanted for 1 chick.

% Output file : a csv document with :
%    - 27 columns (name indicated at the end of the script)
%    - as many lines as there are bins 

% Before running the program, please make sure that :
%    - the videos are all in the same folder
%    - the videos have the same format name : chickNUMBER_dNUMBER.avi for example

% In the Current folder, you should find .:
%    - excel file with the sessions
%    - function trackBEEtagAcrossFrames.m
%    - function locateCodes.m
%    - function optimizeTrackingParameters.m (except if you never select this option later)
%    - function naninterp.m
%    - function find_orientation.m
%    - function find_location.m

% If you implement this program on a new computer, please change the paths:
%    - videopath
%    - txtfilepath
%    - outputpath
%    - No need to change bradley path on each computer, easier to make a
%    path directly to the servor so you don't have to change it often


% If you just want to analyze a short video for an example, you can use an easier matlab script : Bastien_test.m 
% It is possible de change the time bins duration, the angle defining
% binocular vision and number of frames you want to optimize (if you call
% the function)

%--------------

% If you have changed the paths and follow the indications above, you can
% RUN the program  !

% --------------

addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src\bradley\bradley')

videopath = 'C:\Users\bastien.lemaire\Desktop\videos' ;
txtfilepath = 'C:\Users\bastien.lemaire\Desktop\Beetag\txtfiles_chicks' ;
outputpath = 'C:\Users\bastien.lemaire\Desktop\Results\Angle' ;

addpath(videopath)

%%% start timer
tic

%%% user input chick number
chick_number = input('write the chick number : ') ;

% choose the angle of the binocular view (of only one eye)
choice_angle = 15;

% user input which days he wants to analyze :
periodtoanalyze = input('write which days you want to analyze, for example write : [1 2 5] for day 1, 2 and 5. Do not forget to use these [] : ') ;

% duration of the bin in seconds :
dur_bin = 600 ;

% on how many frames do you want to optimize, if you want to optimize :
nframes_to_opt = 100 ;

% optimize tracking parameters :
optimize = input('Do you want to optimize tracking parameters ? add AT LEAST 2 hour to matlab analysis for each day [y/n] : ', 's') ;

% If you have an error with a frame, indicate its number (this frame will be erased and replaced by the previous frame)
% then run the program again and the error wont happen 
bad = [] ;

%% loop for each day (i)
for i = periodtoanalyze
    
    % clear all variables except the one that does not vary thorough days
    clearvars -except arena_border corner1 corner2 chick_number codelist choice_angle bad fam_obj i xlsfile periodtoanalyze parameters tic optimize videopath txtfilepath outputpath dur_bin nframes_to_opt
    
    % write path of video according to the chick number and day
    namevideo = char(strcat(videopath, '\chick', num2str(chick_number), '_d', num2str(i), '.avi')) ;
    video = dir(fullfile(namevideo));
    
    % get total number of frames for each video
    my_video = VideoReader(video.name);
    endframe = my_video.NumberOfFrames;

    % preallocate table for data
    data_tab = table();
    data_tab_p = table();
    
    % read txt file
    name_txtfile = strcat(txtfilepath, '\chick', num2str(chick_number), '.txt')   ;
    
    % store each variable of txt file inside a vector
    [ID, sex, condition, session, phase, day, fam_position, startsec, stopsec, corner1, corner2, codelist, starting_age, origin] = textread(name_txtfile, '%d %s %s %d %s %d %s %d %d %d %d %d %d %s', 'delimiter', ',');
    
    % compute how many sessions per day
    sessions_list = [day(1)] ;   
    for pp = 1:(size(session)-1)
        if day(pp) ~= day(pp+1)
            sessions_list(end+1) = pp+1;
        end
    end
    sessions_list(end+1) = size(day,1) ;
    
    % select variables that never changes accross days
    codelist = codelist(1) ;
    starting_age = starting_age(1) ;
    corner1 = corner1(1) ;
    corner2 = corner2(1) ;
    origin = origin(1) ;
    
    % select variables according to the day
    startsec = startsec(sessions_list(i):(sessions_list(i+1)-1)) ;
    stopsec = stopsec(sessions_list(i):(sessions_list(i+1)-1));
    day = day(sessions_list(i):(sessions_list(i+1)-1));
    phase = phase(sessions_list(i):(sessions_list(i+1)-1));
    fam_position = fam_position(sessions_list(i):(sessions_list(i+1)-1));
    session = session(sessions_list(i):(sessions_list(i+1)-1));
    sex = sex(sessions_list(i):(sessions_list(i+1)-1)) ;
    
    % optimize tracking parameters for this video
    if optimize== 'y'
        [brThresh brFilt optTime] = optimizeTrackingParameters(my_video, 1:6, 9:18, nframes_to_opt, codelist, chick_number, i) ;
        parameters = strcat('_thresh',num2str(brThresh),'_filter',num2str(brFilt)) ;
        
    elseif optimize== 'n'
        brThresh = 4 ;
        brFilt = 12 ;
        parameters = 'baseline' ;
        nframes_to_opt = 0 ;
    else
        disp('you did not write y or n to this question. Please stop the program (CTRL + C) and run everything again.') ;
    end
    
    % write outputfile name according to the chick number, day, and parameters chosen
    outputfile_name = char(strcat(outputpath, '\chick', num2str(chick_number), '_d', num2str(i), '_orientation_', parameters,'_opt_on_', num2str(nframes_to_opt), '.txt')) ;

    % find the area limits (in our case, the dimension of arena is 90cm and we want areas of 15 cm and 30 cm in the left and right)
    far_left_pos = corner1 + ((corner2 - corner1)* 15 )/90;
    left_pos = corner1 + ((corner2 - corner1)* 30 )/90;
    far_right_pos = corner2 - ((corner2 - corner1)* 15)/90;
    right_pos = corner2 - ((corner2 - corner1)* 30)/90;
    
    %   create a table called frames with the times delimiting the sessions
    for kk = 1:size(startsec,1)
        frames(kk,:) = [startsec(kk):stopsec(kk)];
    end
    bins_session = (stopsec(1)-startsec(1))/dur_bin ;
    
    % divide each session in time bins
    bins = [];
    for bb = 1:bins_session
        bins = [bins ; 1+dur_bin*(bb-1):dur_bin*bb] ;
    end
    
    % allocate structure session_track (records ouput of the tracking)
    session_track = struct();
    
    
    %% loop across sessions (frames) inside each day (i)
    
    for ii = 1:size(frames,1)
        
        % select the variables according to the session
        sexx = sex(ii);
        sessionn = session(ii) ;
        dayy = day(ii);
        phasee = phase(ii);
        conditionn = condition(ii);
        fam_positionn = fam_position(ii);
        
        %% loop across bins (v) inside each sessions (frames) inside each day (i)
        
        for v = 1:bins_session
            
            % in case of there is a frame to delete (bad) create new vector new_frames
            new_frames = frames(ii,bins(v,:)) ;
            if isempty(bad)==0
                new_frames(find(new_frames==bad)) = bad-1 ;
            end
            
            % track tags within the function trackBEEtagsAcrossFrames
            trackingDataoutput = trackBEEtagsAcrossFrames(video.name, brThresh, brFilt, new_frames, codelist );
            
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
            
            
            %% loop across each frames inside each bins (v) inside each sessions (frames) inside each day (i)
            for p = new_frames
                F = trackingDataoutput(p).F;
                
                % error case : if last frame of a bin is empty, can generate problems with interpolation later
                % because of this reason, 0  is automatically assigned to each last empty frame of a bin
                if p==new_frames(length(new_frames)) && isempty(F)==1
                    session_track(1).CentroidX(p) = 0;
                    session_track(1).CentroidY(p) = 0;
                    session_track(1).FrontX(p) = 0;
                    session_track(1).FrontY(p) = 0;
                    session_track(1).number(p) = 0;
                end
                
                % if the tag is recognized
                if isempty(F)==0
                    % if two tags are recognized, select the good one
                    FS = F([F.number] == codelist);
                    if isempty(FS)==0
                       
                        % put coordinate of trackingDataoutput into an easier format to read
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
            
            % ------------- COMPUTE LOCATION OF TAG
            
            % compute x_track and y_track (coordinate X and Y) for interpolation
            x_track = session_track.CentroidX(frames(ii,bins(v,1)):length(session_track.CentroidX));
            y_track = session_track.CentroidY(frames(ii,bins(v,1)):length(session_track.CentroidY));

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
            % stop exponantial answer
            format long
            % convert distance moved from pixel to cm
            distance_moved = (round(distance_moved*90)/(corner2-corner1)) ;
            
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
            data_tab_p(v,:) = table(chick_number, starting_age, origin, dayy, phasee, sessionn, bins(v), sexx, conditionn, fam_positionn, locations_overall.Far_Left, locations_overall.Left, locations_overall.Center, locations_overall.Right, locations_overall.Far_Right, locations_overall.nan, locations_overall.Familiar, locations_overall.FamiliarVeryClose, locations_overall.Unfamiliar, locations_overall.UnfamiliarVeryClose, locations_not_interpolate.Far_Left, locations_not_interpolate.Left, locations_not_interpolate.Center, locations_not_interpolate.Right, locations_not_interpolate.Far_Right, locations_not_interpolate.nan, locations_not_interpolate.Familiar, locations_not_interpolate.FamiliarVeryClose, locations_not_interpolate.Unfamiliar, locations_not_interpolate.UnfamiliarVeryClose, tot_tracked, tot_secs, total_tracked, orientation_look.Binocular_Familiar , orientation_look.Binocular_Unfamiliar, orientation_look.Left_Eye_Familiar, orientation_look.Left_Eye_Unfamiliar, orientation_look.Left_Eye_Monocular_Familiar, orientation_look.Left_Eye_Monocular_Unfamiliar, orientation_look.Right_Eye_Familiar, orientation_look.Right_Eye_Unfamiliar, orientation_look.Right_Eye_Monocular_Familiar, orientation_look.Right_Eye_Monocular_Unfamiliar, distance_moved);
        end
        
        if ii > 1
            data_tab = vertcat(data_tab, data_tab_p);
        else
            data_tab = data_tab_p;
        end
        
    end
    %   define headers for the table
    data_tab.Properties.VariableNames = {'CHICK_ID', 'STARTING_AGE', 'ORIGIN', 'DAY', 'PHASE', 'SESSION', 'BIN','SEX', 'CONDITION', 'FAMILIAR_POS', 'secs_FAR_LEFT', 'secs_LEFT', 'secs_CENTER', 'secs_RIGHT', 'secs_FAR_RIGHT', 'secs_NAN', 'secs_FAMILIAR', 'secs_FAMILIAR_VERY_CLOSE', 'secs_UNFAMILIAR', 'secs_UNFAMILIAR_VERY_CLOSE', 'secs_FAR_LEFT_no_interp', 'secs_LEFT_no_interp', 'secs_CENTER_no_interp', 'secs_RIGHT_no_interp', 'secs_FAR_RIGHT_no_interp', 'secs_NAN_no_interp', 'secs_FAMILIAR_no_interp', 'secs_FAMILIAR_VERY_CLOSE_no_interp', 'secs_UNFAMILIAR_no_interp', 'secs_UNFAMILIAR_VERY_CLOSE_no_interp', 'TOT_secs_tracked', 'TOT_secs', 'secs_tracked', 'binocular_familiar' , 'binocular_unfamiliar', 'left_eye_familiar', 'left_eye_unfamiliar', 'left_eye_monoc_familiar', 'left_eye_monoc_unfamiliar', 'right_eye_familiar', 'right_eye_unfamiliar', 'right_eye_monoc_familiar', 'right_eye_monoc_unfamiliar', 'distance_moved'};
    
    %   store table in an xlsx file
    writetable(data_tab,outputfile_name)

end

% count time needed to do the computation
t= toc ;
disp(strcat('Time spent to run the program was ', num2str(t/3600), ' hours')) ;