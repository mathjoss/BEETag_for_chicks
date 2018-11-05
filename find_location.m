function [locations] = find_location(x_vector, far_left_pos, left_pos, right_pos, far_right_pos, corner1, corner2, fam_positionn)

locations.Far_Left = [0];
locations.Left = [0];
locations.Center = [0];
locations.Right = [0];
locations.Far_Right = [0];
locations.nan = [0];
locations.Familiar = [0];
locations.FamiliarVeryClose = [0];
locations.Unfamiliar = [0];
locations.UnfamiliarVeryClose = [0];

for iii = 1:length(x_vector)
    if x_vector(iii) >= far_left_pos  &&  x_vector(iii) <= left_pos 
        locations.Left = locations.Left + 1 ;
    elseif x_vector(iii) >= corner1 && x_vector(iii) <= far_left_pos
        locations.Far_Left = locations.Far_Left + 1 ;
    elseif x_vector(iii) > left_pos  && x_vector(iii) < right_pos
        locations.Center = locations.Center + 1 ;
    elseif x_vector(iii) >= right_pos  && x_vector(iii) <= far_right_pos
        locations.Right = locations.Right + 1 ;
    elseif x_vector(iii) >= far_right_pos && x_vector(iii) <= corner2
        locations.Far_Right = locations.Far_Right + 1 ;
    else
        locations.nan = locations.nan + 1 ;
    end
end

if ismember(fam_positionn, 'left')
    locations.Familiar = locations.Left;
    locations.Unfamiliar = locations.Right;
    locations.FamiliarVeryClose = locations.Far_Left;
    locations.UnfamiliarVeryClose = locations.Far_Right;
elseif ismember(fam_positionn, 'right')
    locations.Familiar = locations.Right;
    locations.Unfamiliar = locations.Left;
    locations.FamiliarVeryClose = locations.Far_Right;
    locations.UnfamiliarVeryClose = locations.Far_Left;
end