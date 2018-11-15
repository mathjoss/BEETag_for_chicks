%% This program will create a txt file from the excel file.
% It will also check if you made any mistakes when you wrote the file.
% It will also create a new column with the borders of the arena. 

% BEFORE STARTING :
% make sure the path to the excel file is correct
% select the chick number you want
% Then, you can run the program :)

% When slecting the arena borders, always click first on the left and then
% on the right

% read excel file
xlsfile = '\\cimec-storage\gioval\projects\categorization_tracking\video_analysis\sessions_settings_ethovision_matlab_procedure2.1_2.2.xlsx';

% path to the video 
videopath = 'C:\Users\bastien.lemaire\Desktop\videos' ;
addpath(videopath);


%for chick_number = [11 12 13 15 16 17 18 19 20 21 22 23 24 25 27 28 31 32 35 36 42 43 48 50 53 54 55 56 72 74 79 83 103]
%for chick_number = [69 70 71 73 80 81 82 85 86 87 88 94 95 97 98 100]
%for chick_number = [96 101 102 104 105 106]
for chick_number = [57]
    
    %read the excel file sheet according to the chick number
    [num txt raw] = xlsread(xlsfile, strcat('chick',num2str(chick_number)));
    
    % input of tag number
    codelist = input(strcat('write the tag of the chick ', num2str(chick_number), ' : ')) ;
    
    % user input starting age of the chick
    starting_age = input(strcat('write the starting age of the chick ', num2str(chick_number), ' : ')) ;
    
    % user input origin of the chick
    origin = input(strcat('write the origin  of the chick ', num2str(chick_number), ' : '), 's') ;
    
    % those 3 steps can be added in the excel file directly and delete from
    % this matlab file
    
    % check errors in the duration of sessions
    for p = 1:size(num,1)
        diff = num(p,9)- num(p,8) ;
        if diff < 0 
            error(strcat('Error in the excel file ! the duration of the sessions is inferior to 0. check the file at line ', num2str(p), ' for chick ', num2str(chick_number)))
        end
    end    
    
    % check errors for the familiar position column
    for p = 3:size(txt,1)
        if strcmp(txt(p,7),'left')==0 && strcmp(txt(p,7),'right')==0
            error(strcat('Error in the excel file ! you did not write correctly the left and right. Check again at line ', num2str(p), ' for chick ', num2str(chick_number)))
        end
    end
    
    % check errors in the sessions column
    for p = 3:size(raw,1)
        if isnumeric(raw{p,4}) == 0
            error(strcat('Error in the excel file ! you did not write correctly the sessions. Please check again at line ', num2str(p), ' for chick ', num2str(chick_number)))
        end
    end
    
    list_days = [num(4,6)] ;
    for pp = 3:(size(num,1)-1)
        if (num(pp,6))~= num((pp+1),6)
            list_days(end+1) = pp+1;
        end
    end
    
    % check if all sessions starts with 1
    for mm = (list_days)
        if num((mm),4)~= 1
            result_input = input('The sessions do not always start with session 1. Is it normal ? If yes, you can continue by writing 1. If not, write anything else.') ;
            if result_input == 1 
                disp('Ok, we continue.')
            else
                error('Please change the sessions.')
            end
        end
    end
    
    list_days(end+1) = size(num,1)+1 ;
    
    % check if there is no mistake with sessions
    for days = 1:(size(list_days,2)-1)
        for oo = list_days(days):(list_days(days+1)-2)
            if num((oo+1),4) <= num(oo,4)
                error_number = oo+3 ;
                error(strcat('At some point you decrease the number of sessions. Please check at line : ', num2str(error_number)))
            end
        end
    end
    
    
    % select specific column on the excel file (delete the ethovision
    % related columns)
    raw2 = raw(3:size(raw,1),1:9) ;
    
    % convert time to seconds
    for p = 1:size(raw2,1)
        format short g
        raw2{p,8} = raw2{p,8}*86400 ;
        raw2{p,9} = raw2{p,9}*86400 ;
    end
    
    % read the video
    namevideo = char(strcat(videopath, '\chick', num2str(chick_number), '_d1.avi')) ;
    arena_video = VideoReader(namevideo);
    arena_pic = readFrame(arena_video);
    imshow(arena_pic)

    
    % user select the borders of the screen
    arena_border = ginput(2);
    corner1 = (round(arena_border(1,1)) - 10) ;
    corner2 = (round(arena_border(2,1)) + 10) ;

    % convert array to table in order to use writetable
    tabl = array2table(raw2) ;
    
    % delete rows with NaN (could not find an easier way to do it...)
    NAN=0 ;
    tt = table2cell(tabl) ;
    for p = 1:size(tt,1)
        bbb = string(tt(p,1)) ;
        if ismissing(bbb)==1
            NAN = 1 ;
            break
        end
    end
    if NAN==1
        tabl = tabl(1:(p-1), :) ;
    else
        tabl = tabl(1:p, :) ;
    end
    
    % add to the table 3 new columns : corner1, corner2 and tag
    tabl.corner1 = repmat(corner1,size(tabl,1),1);
    tabl.corner2 = repmat(corner2,size(tabl,1),1);
    tabl.codelist = repmat(codelist, size(tabl,1),1);
    tabl.starting_age = repmat(starting_age, size(tabl,1),1);
    tabl.origin = repmat(origin, size(tabl,1),1);
    
    % write the file
    outputfile_name = strcat('C:\Users\bastien.lemaire\Desktop\BEETag_for_chicks\txtfiles_chicks\chick', num2str(chick_number), '.txt') ;
    writetable(tabl,outputfile_name, 'WriteVariableNames',false) ;
    
end
disp('its finished :) ')