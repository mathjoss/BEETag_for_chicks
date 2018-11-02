%%%

%  This program adds a column into a txt file

%%%


% select the number of chicks in which you want to add data
%for chick_number = [11 12 13 15 16 17 18 19 20 21 22 23 24 25 27 28 29 30 31 32 35 36 42 43 48 50 53 54 55 56 57 85 86]
for chick_number = [71 72 73 74 79 80 81 82 83 96 97 98 100 101]
    
    % change path
    txtfilepath = 'C:\Users\bastien.lemaire\Desktop\Beetag\txtfiles_chicks' ;
    
    % read txt file
    name_txtfile = strcat(txtfilepath, '\chick', num2str(chick_number), '.txt')   ;
    
    % store each variable of txt file inside a vector
    [ID, sex, condition, session, phase, day, fam_position, startsec, stopsec, corner1, corner2, codelist, starting_age] = textread(name_txtfile, '%d %s %s %d %s %d %s %d %d %d %d %d %d', 'delimiter', ',');
    
    % add new variables
    origin = input(strcat('write the origin of the chick ', num2str(chick_number), ' : '), 's') ;
    
    % create new tables with all data
    data_tab_p = table() ;
    for i = 1:length(ID)
        cell_content = {ID(i), sex(i), condition(i), session(i), phase(i), day(i), fam_position(i), startsec(i), stopsec(i), corner1(i), corner2(i), codelist(i), starting_age(i) origin} ;
        data_tab_p(i,:) = cell2table(cell_content) ;
    end
    
    % write the file with the same name as inputfile
    writetable(data_tab_p,name_txtfile, 'WriteVariableNames',false) ;
end

