function p=aeb_parameters(c)
% Numeric parameter vector shared by MATLAB and the editable Simulink model.
% 1 dt, 2 mu, 3 brakeMax, 4 brakeTau, 5 leadBrakeTime, 6 leadDecel,
% 7 carLength, 8 minGap, 9 sensorDelay, 10 staleTimeout, 11 ttcBrake,
% 12 ttcWarn, 13 assumedLeadDecel, 14 AEB on, 15 ACC on,
% 16 timeHeadway, 17 targetSpeed, 18 maxAccel.
p=[c.dt;c.mu;c.brakeMax;c.brakeTau;c.leadBrakeTime;c.leadDecel;...
 c.carLength;c.minGap;c.sensorDelay;c.staleTimeout;c.ttcBrake;...
 c.ttcWarn;c.assumedLeadDecel;double(c.aebEnabled);...
 double(c.accEnabled);c.timeHeadway;c.targetSpeed;c.maxAccel];
end
