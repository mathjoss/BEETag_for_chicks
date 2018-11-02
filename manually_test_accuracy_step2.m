
%%%% STEP 2 :

% use the txt file created previously
% help user to manually select data
% compare manually picked data and Beetag data
% no outputs, the results is stored inside variable at the end of the
% program : 

% LE_PERCENT : percentage of accuracy for left eye
% RE_PERCENT : percentage of accuracy for right eye
% BINOC_PERCENT : percentage of accuracy for binocular
% MONOC_PERCENT : percentage of accuracy for monocular

%%% Select the paths, choose your chick number and the day you want to
%%% analyze, and run the program

addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src')
addpath('\\cimec-storage\gioval\projects\categorization_tracking\matlab_analysis_Sara\BEEtagBastien_final\src\bradley\bradley')

% select paths
videopath = 'C:\Users\bastien.lemaire\Desktop\videos' ;
txtfilepath = 'C:\Users\bastien.lemaire\Desktop\Beetag\test_accuracy' ;

addpath(videopath)

% choose the chick number
chick_number = 28 ;

% choose the day
i = 1 ;

% read video
namevideo = strcat(videopath, '\chick', num2str(chick_number), '_d', num2str(i),'.avi') ;
my_video = VideoReader(namevideo);
endframe = my_video.NumberOfFrames;

% read txt file
name_txtfile = strcat(txtfilepath, '\file_for_chick_', num2str(chick_number),  '_day_', num2str(i), '.txt')   ;

% store each variable of txt file inside a vector
[chick_number,frame_number,fam_position,sex,session,day,phase,condition,binocular_familiar,binocular_unfamiliar,left_eye_familiar,left_eye_unfamiliar,left_eye_monoc_familiar,left_eye_monoc_unfamiliar,right_eye_familiar,right_eye_unfamiliar,right_eye_monoc_familiar,right_eye_monoc_unfamiliar] = textread(name_txtfile, '%d %d %s %s %d %d %s %s %d %d %d %d %d %d %d %d %d %d', 'delimiter', ',');

% rearrange the data so we can compare them with the manually picked data
for el = 1:length(left_eye_familiar)
    left_eye(el) = left_eye_familiar(el) + left_eye_unfamiliar(el) ;
    left_eye_monoc(el) = left_eye_monoc_familiar(el) + left_eye_monoc_unfamiliar(el);
    right_eye(el) = right_eye_familiar(el) + right_eye_unfamiliar(el);
    right_eye_monoc(el) = right_eye_monoc_familiar(el) + right_eye_monoc_unfamiliar(el);
    monocular(el) = right_eye_monoc(el) + left_eye_monoc(el);
    binocular(el) = binocular_familiar(el) + binocular_unfamiliar(el);
end

% ----- it is not useful to calculate both monocular AND binocular, as the
% percentage should be the same. I computed them both to make sure the
% program do not contain any mistakes. --------------

binoc = [] ;
monoc = [] ;
left = [] ;
right = [];

% ask manually location for each frame
for p = 1:length(frame_number)
    
    % read frame
    im = read(my_video, frame_number(p));
    
    % show frame
    imshow(im)
    
    % ask first question
    answer = questdlg('Is the chick looking at the stimulus ?', ...
        'Menu 1', ...
        'Yes','No', 'Notsure', 'Yes');
    switch answer
        case 'Yes'
            look = 1;
        case 'No'
            binoc = [binoc 0];
            monoc = [monoc 0];
            left = [left 0];
            right = [right 0];
            look = 0
        case 'Notsure'
            look = 0
            binoc = [binoc NaN];
            monoc = [monoc NaN];
            left = [left NaN];
            right = [right NaN];
    end
    
    % if the chick is looking at the stimulus, ask the other questions
    if look == 1
        answer2 = questdlg('How is the chick looking at the stimulus ?', ...
            'Menu 2', ...
            'Binocular','Monocular', 'Not sure', 'Binocular');
        switch answer2
            case 'Binocular'
                binoc = [binoc 1] ;
                monoc = [monoc 0];
            case 'Monocular'
                monoc = [monoc 1];
                binoc = [binoc 0];
            case 'Not sure'
                monoc = [monoc NaN];
                binoc = [binoc NaN];
        end
        
        answer3 = questdlg('Which eye is the chick using to look at the stimulus ?', ...
            'Menu 3', ...
            'Left Eye','Right Eye', 'Not sure', 'Left Eye');
        switch answer3
            case 'Left Eye'
                left = [left 1];
                right = [right 0];
            case 'Right Eye'
                left = [left 0];
                right = [right 1];
            case 'Not sure'
                left = [left NaN];
                right = [right NaN];
        end
    end
    disp(strcat('frame_', num2str(p),'_out_of_', num2str(length(frame_number))))
    % clear variable in order to be able to go out the program byu clicking
    % the red cross (could not find an other way to exit properly...)
    clearvars look side view
    
end


% compare manually picked data and program based data
le = 0 ; re = 0 ; bi = 0 ; mo = 0 ;
for pp = 1:length(left_eye)
    le = le + isequal(left_eye(pp),left(pp))
    re = re + isequal(right_eye(pp),right(pp))
    bi = bi + isequal(binocular(pp),binoc(pp))
    mo = mo + isequal(monocular(pp),monoc(pp))
end

%%% compute a percentage of accuracy

% left eye :
LE_PERCENT = (le/pp)*100

% write eye :
RE_PERCENT = (re/pp)*100

% binocular :
BINOC_PERCENT = (bi/pp)*100

% monocular
MONOC_PERCENT = (mo/pp)*100

% create a table with the results

% write table

