function z=aeb_sensor(s,n,L)
% Synthetic range/range-rate sensor, not a rendered camera or radar waveform.
% s = [ego centre x; ego speed; lead centre x; lead speed; ego acceleration].
% z = [bumper gap; closing speed (positive means approaching); valid flag].
z=[max(0,s(3)-s(1)-L+n(1));s(2)-s(4)+n(2);n(3)];
end
