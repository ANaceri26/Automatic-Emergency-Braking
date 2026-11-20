function y=aeb_sl_controller(u)
% Simulink adapter: observation(3), state(5), memory(5), parameters(18).
u=u(:);
[out,memory]=aeb_controller(u(1:3),u(5),u(14:31),u(9:13));
% This legacy Simulink block requires finite outputs. Preserve the decision
% logic and encode infinite display-only TTC with a large finite sentinel.
if ~isfinite(out(3)), out(3)=1e9; end
y=[out;memory];
end
