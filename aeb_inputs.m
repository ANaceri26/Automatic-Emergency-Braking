function [t,noise]=aeb_inputs(c)
% Reproducible synthetic radar errors; leaves the user's random stream alone.
aeb_validate(c);
t=(0:c.dt:c.duration)';
stream=RandStream('mt19937ar','Seed',c.seed);
noise=[c.rangeNoise*randn(stream,numel(t),1),...
 c.speedNoise*randn(stream,numel(t),1),...
 double(~(t>=c.dropoutStart & t<c.dropoutEnd))];
end
