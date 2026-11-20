function c = aeb_config(name)
%AEB_CONFIG Editable settings. SI units: metres, seconds, m/s, m/s^2.
% Try: c=aeb_config('wet'); c.mu=0.3; r=aeb_simulate(c);
if nargin==0, name='dry'; end
c.name=char(name); c.dt=0.02; c.duration=15; c.seed=7;
c.egoSpeed=20; c.leadSpeed=16; c.initialGap=42; c.carLength=4.5;
c.leadBrakeTime=3; c.leadDecel=6; c.mu=0.85; c.brakeMax=8;
c.brakeTau=0.18; c.sensorPeriod=0.10; c.sensorDelay=0.12;
c.rangeNoise=0.15; c.speedNoise=0.10; c.dropoutStart=Inf;
c.dropoutEnd=Inf; c.staleTimeout=0.5; c.minGap=3;
c.ttcBrake=1.7; c.ttcWarn=3; c.assumedLeadDecel=6;
c.aebEnabled=true; c.accEnabled=false; c.timeHeadway=1.6;
c.targetSpeed=20; c.maxAccel=1.5;
switch lower(char(name))
    case 'dry'
    case 'wet', c.mu=0.4;
    case 'ice', c.mu=0.15;
    case 'delay', c.sensorDelay=0.60;
    case 'dropout', c.dropoutStart=2; c.dropoutEnd=4;
    case 'stationary'
        c.leadSpeed=0; c.initialGap=55; c.leadBrakeTime=Inf;
    case 'safe'
        c.leadSpeed=20; c.initialGap=60; c.leadBrakeTime=Inf;
    case 'acc'
        c.accEnabled=true; c.initialGap=55; c.leadBrakeTime=8;
    otherwise, error('AEB:Case','Unknown case: %s',name);
end
end
