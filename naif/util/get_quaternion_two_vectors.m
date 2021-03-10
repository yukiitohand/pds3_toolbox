function [q] = get_quaternion_two_vectors(tvec,tvec_rot)

if iscolumn(tvec_rot)
    tvec_rot = tvec_rot';
end

if iscolumn(tvec)
    tvec = tvec';
end

tvec_rot = tvec_rot / norm(tvec_rot);
tvec = tvec / norm(tvec);
rot_axis = cross(tvec,tvec_rot);
rot_axis = rot_axis / norm(rot_axis);
theta = acos(tvec * tvec_rot');

[q] = get_rotation_quaternion(rot_axis,theta);

end