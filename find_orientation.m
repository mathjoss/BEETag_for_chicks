function [orientation_look] = find_orientation(session_track, fam_positionn, choice_angle, p, far_left_pos, left_pos, right_pos, far_right_pos, orientation_look, corner1, corner2)

%%%    compute the angle between an horizontal line and the orientation of the tag
cosi = sqrt((session_track(1).CentroidX(p)- session_track(1).FrontX(p))^2) / sqrt((session_track(1).CentroidX(p) - session_track(1).FrontX(p))^2 + (session_track(1).CentroidY(p) - session_track(1).FrontY(p))^2) ;
angle = acosd(cosi) ;

% compute values about the orientation and position of the chick in order to facilitate the next step
% Those variables can be deleted and replaced in the next step
OBJ_LEFT = strcmp(fam_positionn, 'left') ;
OBJ_RIGHT = strcmp(fam_positionn, 'right') ;
POSITION_LEFT = (session_track(1).CentroidX(p) <= left_pos && session_track(1).CentroidX(p) >= corner1) ;
POSITION_RIGHT = (session_track(1).CentroidX(p) >= right_pos && session_track(1).CentroidX(p) <= corner2);
ORIENTATIONX = sign(session_track(1).CentroidX(p) - session_track(1).FrontX(p));
ORIENTATIONY = sign(session_track(1).CentroidY(p) - session_track(1).FrontY(p));

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