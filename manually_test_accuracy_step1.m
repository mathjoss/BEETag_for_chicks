%% The whole program is made to manually determines orientation of the chicks and compare the results with Matlab analysis.

% You should run first step 1 (fast) and then step 2 (very long)

%%%% STEP 1 :

% select random frames, that are frames detected by BEETAG and not located
% in the center
% write a txt file with the frames number and the Matlab result of the analysis


%%% Select the paths, choose your chick number and the day you want to
%%% analyze, and run the program

addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src\bradley\bradley')

% select paths
videopath = 'C:\Users\bastien.lemaire\Desktop\videos' ;
txtfilepath = 'C:\Users\bastien.lemaire\Desktop\Beetag\txtfiles_chicks' ;
outputpath = 'C:\Users\bastien.lemaire\Desktop\Beetag\test_accuracy' ;

addpath(videopath)

% choose the chick number
chick_number = 28 ;

% choose the day
i = 1 ;

% choose the angle for binocular view
% example : select an angle of 15 degrees will become an angle of 30 degrees for both eyes
choice_angle = 15 ;

% read video
namevideo = strcat(videopath, '\chick', num2str(chick_number), '_d', num2str(i),'.avi') ;
my_video = VideoReader(namevideo);
endframe = my_video.NumberOfFrames;

%choose the percentage of frames you want to test
% ex : 0.05 means 5 percent of the total number of frames in the video
nframe_to_test = endframe * 0.001 ;
nframe_to_test = round(nframe_to_test,0) ;

% select a sample of random numbers
s = RandStream('mlfg6331_64');
vector_frames = datasample(s,1:endframe,50000,'Replace',false) ;

% create empty table
datatab = table();

% open txt file
name_txtfile = strcat(txtfilepath, '\chick', num2str(chick_number),'.txt')   ;

% store each variable of txt file inside a vector
[ID, sex, condition, session, phase, day, fam_position, startsec, stopsec, corner1, corner2, codelist, starting_age] = textread(name_txtfile, '%d %s %s %d %s %d %s %d %d %d %d %d %d', 'delimiter', ',');

% select when the sessions starts and stops
sessions_list = [day(1)] ;
for pp = 1:(size(session)-1)
    if day(pp) ~= day(pp+1)
        sessions_list(end+1) = pp+1;
    end
end
sessions_list(end+1) = size(day,1) ;

% choose the part of the txt file corresponding to the day and sessions
codelist = codelist(1) ;
corner1 = corner1(1) ;
corner2 = corner2(1) ;
startsec = startsec(sessions_list(i):(sessions_list(i+1)-1)) ;
stopsec = stopsec(sessions_list(i):(sessions_list(i+1)-1));
day = day(sessions_list(i):(sessions_list(i+1)-1));
phase = phase(sessions_list(i):(sessions_list(i+1)-1));
fam_position = fam_position(sessions_list(i):(sessions_list(i+1)-1));
session = session(sessions_list(i):(sessions_list(i+1)-1));
sex = sex(sessions_list(i):(sessions_list(i+1)-1)) ;

% find the position
far_left_pos = corner1 + ((corner2 - corner1)* 15 )/90;
left_pos = corner1 + ((corner2 - corner1)* 30 )/90;
far_right_pos = corner2 - ((corner2 - corner1)* 15)/90;
right_pos = corner2 - ((corner2 - corner1)* 30)/90;

% select the starting and stopping time of each session
for kk = 1:size(startsec,1)
    frames(kk,:) = [startsec(kk):stopsec(kk)];
end
bins_session = (stopsec(1)-startsec(1))/600 ;

incr = 1 ;
for p=vector_frames
    
    % select the right information according to the random frame analyzed
    for o = 1:size(frames,1)
        if ismember(p, frames(o,:))==1
            sexx = sex(o);
            sessionn = session(o) ;
            dayy = day(o);
            phasee = phase(o);
            conditionn = condition(o);
            fam_positionn = fam_position(o);
        end
    end
    
    % read a frame
    im = read(my_video, p);
    
    % locates codes in the frame
    F = locateCodes(im, 'sizeThresh', 50,  'tagList',codelist,  'threshMode', 1, 'bradleyFilterSize', [14 14], 'bradleyThreshold',4) ;
    
    % if at least one tag is recognized
    if isempty(F)==0
        
        % if two tags are recognized, select the good one
        FS = F([F.number] == codelist);
        
        if isempty(FS)==0
            
            %% Orientation of the tag
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
            
            %%%    compute the angle between an horizontal line and the orientation of the tag
            cosi = sqrt((FS.Centroid(1)- FS.frontX)^2) / sqrt((FS.Centroid(1) - FS.frontX)^2 + (FS.Centroid(2) - FS.frontY)^2) ;
            angle = acosd(cosi) ;
            
            % compute values about the orientation and position of the chick in order to facilitate the next step
            % Those variables can be deleted and replaced in the next step
            OBJ_LEFT = strcmp(fam_positionn, 'left') ;
            OBJ_RIGHT = strcmp(fam_positionn, 'right') ;
            POSITION_LEFT = (FS.Centroid(1) <= left_pos && FS.Centroid(1) >= corner1) ;
            POSITION_RIGHT = (FS.Centroid(1) >= right_pos && FS.Centroid(1) <= corner2);
            ORIENTATIONX = sign(FS.Centroid(1) - FS.frontX);
            ORIENTATIONY = sign(FS.Centroid(2) - FS.frontY);
            
            if POSITION_LEFT | POSITION_RIGHT
                % familiar side
                if (OBJ_LEFT && POSITION_LEFT && ORIENTATIONX == -1 && angle < choice_angle) || (OBJ_RIGHT && POSITION_RIGHT && ORIENTATIONX == 1 && angle < choice_angle)
                    orientation_look.Binocular_Familiar = orientation_look.Binocular_Familiar + 1 ;
                end
                % unfamiliar side
                if (OBJ_RIGHT && POSITION_LEFT  && ORIENTATIONX == -1 && angle < choice_angle) || (OBJ_LEFT && POSITION_RIGHT && ORIENTATIONX == 1 && angle < choice_angle)
                    orientation_look.Binocular_Unfamiliar = orientation_look.Binocular_Unfamiliar + 1 ;
                end

                %%%    check which eye the chick use to look at the familiar stimulus

                % right eye to familiar stimulus
                if (OBJ_LEFT && POSITION_LEFT && ORIENTATIONY == 1 && (ORIENTATIONX == -1 || (ORIENTATIONX == 1 && angle > 45))) || (OBJ_RIGHT && POSITION_RIGHT && ORIENTATIONY == -1 && (ORIENTATIONX == 1 || (ORIENTATIONX == -1 && angle > 45)))
                    orientation_look.Right_Eye_Familiar = orientation_look.Right_Eye_Familiar + 1 ;
                    if angle > choice_angle
                        orientation_look.Right_Eye_Monocular_Familiar = orientation_look.Right_Eye_Monocular_Familiar +1 ;
                    end
                end
                % right eye to unfamiliar stimulus
                if (OBJ_RIGHT && POSITION_LEFT && ORIENTATIONY == 1 && (ORIENTATIONX == -1 || (ORIENTATIONX == 1 && angle > 45))) || (OBJ_LEFT && POSITION_RIGHT && ORIENTATIONY == -1 && (ORIENTATIONX == 1 || (ORIENTATIONX == -1 && angle > 45)))
                    orientation_look.Right_Eye_Unfamiliar = orientation_look.Right_Eye_Unfamiliar + 1 ;
                    if angle > choice_angle
                        orientation_look.Right_Eye_Monocular_Unfamiliar = orientation_look.Right_Eye_Monocular_Unfamiliar +1 ;
                    end
                end
                % left eye to familiar stimulus
                if (OBJ_LEFT && POSITION_LEFT && ORIENTATIONY == -1 && (ORIENTATIONX == -1 || (ORIENTATIONX == 1 && angle > 45))) || (OBJ_RIGHT && POSITION_RIGHT && ORIENTATIONY == 1 && (ORIENTATIONX == 1 || (ORIENTATIONX == -1 && angle > 45)))
                    orientation_look.Left_Eye_Familiar = orientation_look.Left_Eye_Familiar + 1 ;
                    if angle > choice_angle
                        orientation_look.Left_Eye_Monocular_Familiar = orientation_look.Left_Eye_Monocular_Familiar +1 ;
                    end
                end
                % left eye to unfamiliar stimulus
                if (OBJ_RIGHT && POSITION_LEFT && ORIENTATIONY == -1 && (ORIENTATIONX == -1 || (ORIENTATIONX == 1 && angle > 45))) || (OBJ_LEFT && POSITION_RIGHT && ORIENTATIONY == 1 && (ORIENTATIONX == 1 || (ORIENTATIONX == -1 && angle > 45)))
                    orientation_look.Left_Eye_Unfamiliar = orientation_look.Left_Eye_Unfamiliar + 1 ;
                    if angle > choice_angle
                        orientation_look.Left_Eye_Monocular_Unfamiliar = orientation_look.Left_Eye_Monocular_Unfamiliar + 1 ;
                    end
                end
                datatab(incr,:) = table(chick_number, p, fam_positionn, sexx, sessionn, dayy, phasee, conditionn, orientation_look.Binocular_Familiar , orientation_look.Binocular_Unfamiliar, orientation_look.Left_Eye_Familiar, orientation_look.Left_Eye_Unfamiliar, orientation_look.Left_Eye_Monocular_Familiar, orientation_look.Left_Eye_Monocular_Unfamiliar, orientation_look.Right_Eye_Familiar, orientation_look.Right_Eye_Unfamiliar, orientation_look.Right_Eye_Monocular_Familiar, orientation_look.Right_Eye_Monocular_Unfamiliar) ;
                
                % add to incrementor everytime a frame has been correctly
                % analyzed
                incr=incr+1 ;
                disp(strcat('find frame_',num2str(incr), '_out_of_', num2str(nframe_to_test)))
                
                % when we got enough frames, stop the loop
                if incr > nframe_to_test
                    break
                end
            end
        end
    end
end

%   define headers for the table
datatab.Properties.VariableNames = {'chick_number', 'frame_number', 'fam_position', 'sex', 'session', 'day', 'phase', 'condition', 'binocular_familiar' , 'binocular_unfamiliar', 'left_eye_familiar', 'left_eye_unfamiliar', 'left_eye_monoc_familiar', 'left_eye_monoc_unfamiliar', 'right_eye_familiar', 'right_eye_unfamiliar', 'right_eye_monoc_familiar', 'right_eye_monoc_unfamiliar'};

%   store table in an xlsx file
writetable(datatab,strcat(outputpath, '\file_for_chick_', num2str(chick_number), '_day_', num2str(i)), 'WriteVariableNames',false)




