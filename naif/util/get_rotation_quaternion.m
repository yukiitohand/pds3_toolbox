function [q] = get_rotation_quaternion(axis_vec,theta)

theta_half = theta * 0.5;
sin_tf = sin(theta_half);
q234 = axis_vec*sin_tf;
q = quaternion(cos(theta_half), q234(1),q234(2),q234(3));

end