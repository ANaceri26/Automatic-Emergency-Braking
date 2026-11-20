function r=aeb_simulate(c)
%AEB_SIMULATE Run without graphics. Requires only base MATLAB R2024a.
if nargin==0, c=aeb_config; end
[t,noise]=aeb_inputs(c); p=aeb_parameters(c); N=numel(t);
state=zeros(N,5); sensor=zeros(N,3); control=zeros(N,5);
state(1,:)=[0 c.egoSpeed c.initialGap+c.carLength c.leadSpeed 0];
initial=[c.initialGap;c.egoSpeed-c.leadSpeed;1];
held=initial; memory=[0;initial(1:2);0;1];
sampleEvery=round(c.sensorPeriod/c.dt); delay=round(c.sensorDelay/c.dt);
history=repmat(initial',N,1);
started=tic;
for k=1:N
    s=state(k,:)';
    if mod(k-1,sampleEvery)==0, held=aeb_sensor(s,noise(k,:)',c.carLength); end
    history(k,:)=held';
    z=initial;
    if k>delay, z=history(k-delay,:)'; end
    sensor(k,:)=z';
    [u,memory]=aeb_controller(z,s(2),p,memory);
    control(k,:)=u';
    if s(3)-s(1)-c.carLength<=0, break; end
    if k<N, state(k+1,:)=aeb_plant(s,u(1),t(k),p)'; end
end
r.config=c; r.time=t(1:k); r.state=state(1:k,:);
r.sensor=sensor(1:k,:); r.control=control(1:k,:);
r.gap=r.state(:,3)-r.state(:,1)-c.carLength;
r.computeSeconds=toc(started);
r.metrics=aeb_metrics(r);
end
