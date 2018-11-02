function [locations_overall] = find_location(x_vector, far_left_pos, left_pos, right_pos, far_right_pos, corner1, corner2, fam_positionn)

%   preallocate array to store the spatial indications for each frame
area_beetag = categorical();
area_beetag = categorical(area_beetag, {'Left', 'Far_Left', 'Center', 'Right', 'Far_Right', 'nan'});

% detect area for each frame, given the Beetag X coordinates for each frame
for iii = 1: length(x_vector)
    if x_vector(iii) >= corner1  &&  x_vector(iii) <= left_pos
        area_beetag(iii) = 'Left';
        if x_vector(iii) >= corner1  &&  x_vector(iii) <= far_left_pos
            area_beetag(iii) = 'Far_Left';
        end
    elseif x_vector(iii) > left_pos  && x_vector(iii) < right_pos
        area_beetag(iii) = 'Center';
    elseif x_vector(iii) >= right_pos  && x_vector(iii) <= corner2
        area_beetag(iii) = 'Right';
        if x_vector(iii) >= far_right_pos  && x_vector(iii) <= corner2
            area_beetag(iii) = 'Far_Right' ;
        end
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
locations_overall.FamiliarVeryClose = [];
locations_overall.Unfamiliar = [];
locations_overall.UnfamiliarVeryClose = [];
if ismember(fam_positionn, 'left')
    locations_overall.Familiar = locations_overall.Left;
    locations_overall.Unfamiliar = locations_overall.Right;
    locations_overall.FamiliarVeryClose = locations_overall.Far_Left;
    locations_overall.UnfamiliarVeryClose = locations_overall.Far_Right;
elseif ismember(fam_positionn, 'right')
    locations_overall.Familiar = locations_overall.Right;
    locations_overall.Unfamiliar = locations_overall.Left;
    locations_overall.FamiliarVeryClose = locations_overall.Far_Right;
    locations_overall.UnfamiliarVeryClose = locations_overall.Far_Left;
end