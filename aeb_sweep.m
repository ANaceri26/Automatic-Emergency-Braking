function summary=aeb_sweep(makePlot)
%AEB_SWEEP Change friction and delay, run independent cases sequentially.
if nargin==0, makePlot=true; end
friction=[.15 .25 .4 .6 .85]; delay=[0 .1 .3 .6 .9];
rows=zeros(numel(friction)*numel(delay),5); k=0;
for mu=friction
 for latency=delay
  k=k+1; c=aeb_config; c.mu=mu; c.sensorDelay=latency;
  r=aeb_simulate(c);
  rows(k,:)=[mu latency r.metrics.collision r.metrics.minimumGap r.metrics.impactSpeed*3.6];
 end
end
summary=array2table(rows,'VariableNames',{'Friction','Delay_s','Collision','MinGap_m','Impact_kmh'});
root=fileparts(mfilename('fullpath')); folder=fullfile(root,'results');
if ~exist(folder,'dir'), mkdir(folder); end
writetable(summary,fullfile(folder,'friction_delay_sweep.csv'));
if makePlot
 figure('Name','Friction and delay experiment','Color','w');
 imagesc(delay,friction,reshape(rows(:,5),numel(delay),numel(friction))');
 set(gca,'YDir','normal'); xlabel('Sensor latency (s)'); ylabel('Road friction coefficient');
 title('Impact closing speed (km/h); zero means no detected collision'); colorbar;
end
disp(summary);
end
