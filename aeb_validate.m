function aeb_validate(c)
% Reject settings that would silently invalidate the discrete-time model.
positive={'dt','duration','carLength','brakeMax','sensorPeriod',...
 'staleTimeout','ttcBrake','ttcWarn','assumedLeadDecel','timeHeadway','maxAccel'};
for k=1:numel(positive)
 validateattributes(c.(positive{k}),{'numeric'},{'scalar','real','finite','positive'},'',positive{k});
end
nonnegative={'egoSpeed','leadSpeed','initialGap','brakeTau','sensorDelay',...
 'rangeNoise','speedNoise','minGap','leadDecel','targetSpeed'};
for k=1:numel(nonnegative)
 validateattributes(c.(nonnegative{k}),{'numeric'},{'scalar','real','finite','nonnegative'},'',nonnegative{k});
end
validateattributes(c.mu,{'numeric'},{'scalar','real','finite','positive','<=',1.5});
assert(c.initialGap>0,'AEB:InitialGap','Initial bumper gap must be positive.');
assert(c.sensorPeriod>=c.dt,'AEB:SampleTime','Sensor period must be >= dt.');
for value=[c.sensorPeriod,c.sensorDelay,c.duration]
 assert(abs(value/c.dt-round(value/c.dt))<1e-8,'AEB:Timing',...
  'Sensor period, delay and duration must be whole multiples of dt.');
end
assert(c.dropoutEnd>=c.dropoutStart,'AEB:Dropout','Dropout end must follow its start.');
end
