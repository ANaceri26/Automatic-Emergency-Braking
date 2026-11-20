function summary=aeb_run_tests
% Behavioral tests, analytic physics checks, reproducibility and limits.
cases={'dry','wet','ice','delay','dropout','stationary','safe','acc'};
rows=zeros(numel(cases),6);
for k=1:numel(cases)
 c=aeb_config(cases{k}); r=aeb_simulate(c);
 assert(all(isfinite(r.state),'all'),'AEB:Test','Nonfinite state.');
 assert(all(r.state(:,[2 4])>=0,'all'),'AEB:Test','Negative speed.');
 assert(all(diff(r.state(:,[1 3]),1,1)>=-1e-10,'all'),'AEB:Test','Reversing position.');
 assert(min(r.state(:,5))>=-min(c.brakeMax,c.mu*9.81)-1e-10,...
  'AEB:Test','Friction/brake limit violated.');
 if r.metrics.collision
  assert(r.gap(end)<=0 && all(r.gap(1:end-1)>0),'AEB:Test','Contact termination failed.');
 end
 rows(k,:)=[r.metrics.collision,r.metrics.minimumGap,r.metrics.impactSpeed*3.6,...
  r.metrics.firstBrakeTime,r.metrics.stoppingDistance,r.computeSeconds];
end
c=aeb_config; on=aeb_simulate(c); c.aebEnabled=false; off=aeb_simulate(c);
assert(~on.metrics.collision && off.metrics.collision,'AEB:Test','Dry baseline behavior changed.');
safe=aeb_simulate(aeb_config('safe'));
assert(~safe.metrics.collision && ~any(safe.control(:,2)==2),'AEB:Test','False brake in safe case.');
drop=aeb_simulate(aeb_config('dropout'));
assert(any(drop.control(:,2)==4 & drop.control(:,1)<-2),'AEB:Test','Dropout fallback did not brake.');
again=aeb_simulate(aeb_config);
assert(isequal(on.state,again.state) && isequal(on.sensor,again.sensor),'AEB:Test','Seed not reproducible.');
% Analytic stopping distance with zero actuator lag: v^2/(2a).
c=aeb_config; c.brakeTau=0; c.mu=1; p=aeb_parameters(c);
s=[0;20;1000;0;0];
for k=1:300, s=aeb_plant(s,-8,(k-1)*c.dt,p); end
assert(abs(s(1)-25)<1e-9 && s(2)==0,'AEB:Test','Analytic stopping distance failed.');
% With AEB disabled, changing only friction must not change unbraked motion.
c=aeb_config; c.aebEnabled=false; a=aeb_simulate(c); c.mu=.15; b=aeb_simulate(c);
assert(isequal(a.state,b.state),'AEB:Test','Friction affected unbraked motion.');
% Smaller time step should leave the central dry-case result close.
c=aeb_config; c.rangeNoise=0; c.speedNoise=0; a=aeb_simulate(c);
c.dt=.01; b=aeb_simulate(c);
assert(a.metrics.collision==b.metrics.collision && ...
 abs(a.metrics.minimumGap-b.metrics.minimumGap)<1,'AEB:Test','Time-step sensitivity too large.');
summary=array2table(rows,'VariableNames',{'Collision','MinGap_m','Impact_kmh',...
 'BrakeTime_s','StopDistance_m','Compute_s'},'RowNames',cases);
root=fileparts(mfilename('fullpath')); folder=fullfile(root,'results');
if ~exist(folder,'dir'), mkdir(folder); end
writetable(summary,fullfile(folder,'case_summary.csv'),'WriteRowNames',true);
disp(summary); fprintf('PASS: 8 scenarios + physics, AEB comparison, fallback, seed and time-step checks.\n');
end
