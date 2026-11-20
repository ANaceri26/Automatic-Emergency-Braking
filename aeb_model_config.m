function aeb_model_config(model,c)
% Configure existing model. Parameters live inside the model workspace.
if nargin<2, c=aeb_config; end
[t,n]=aeb_inputs(c); w=get_param(model,'ModelWorkspace');
assignin(w,'aebP',aeb_parameters(c)); assignin(w,'aebDt',c.dt);
assignin(w,'aebTs',c.sensorPeriod); assignin(w,'aebDelay',round(c.sensorDelay/c.dt));
assignin(w,'aebInitial',[0;c.egoSpeed;c.initialGap+c.carLength;c.leadSpeed;0]);
assignin(w,'aebObservation',[c.initialGap;c.egoSpeed-c.leadSpeed;1]);
assignin(w,'aebMemory',[0;c.initialGap;c.egoSpeed-c.leadSpeed;0;1]);
assignin(w,'aebNoise',[t n]); assignin(w,'aebLength',c.carLength);
set_param(model,'StopTime',num2str(c.duration,17),'FixedStep','aebDt');
end
