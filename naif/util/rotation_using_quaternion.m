function [tvec_dash,q] = rotation_using_quaternion(axis_vec,theta,tvec)

if length(axis_vec) ~= 3
    error('axis_vec needs to be 3-dimensional vector.');
end

if length(tvec) ~= 3
    error('tvec needs to be 3-dimensional vector.');
end

if iscolumn(tvec)
    tvec = tvec';
    is_column_tvec = true;
else
    is_column_tvec = false;
end
    

theta_half = theta * 0.5;
sin_tf = sin(theta_half);
q234 = axis_vec*sin_tf;
q = quaternion(cos(theta_half), q234(1),q234(2),q234(3));
tvec_dash = rotatepoint(q, tvec);

if is_column_tvec
    tvec_dash = tvec_dash';
end

end