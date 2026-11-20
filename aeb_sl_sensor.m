function z=aeb_sl_sensor(u)
% Simulink adapter: state(5), noise(3), parameters(18).
z=aeb_sensor(u(1:5),u(6:8),u(15));
end
