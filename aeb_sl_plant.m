function y=aeb_sl_plant(u)
% Simulink adapter: state(5), controller outputs(5), time(1), parameters(18).
y=aeb_plant(u(1:5),u(6),u(11),u(12:29));
end
