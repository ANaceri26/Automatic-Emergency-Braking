function m=aeb_metrics(r)
m.collision=any(r.gap<=0);
m.minimumGap=min(r.gap); m.impactSpeed=0; m.collisionTime=NaN;
if m.collision
 k=find(r.gap<=0,1); m.impactSpeed=max(0,r.state(k,2)-r.state(k,4));
 m.collisionTime=r.time(k);
end
k=find(r.control(:,2)==2 | (r.control(:,2)==4 & r.control(:,1)<-2),1);
m.firstBrakeTime=NaN; m.stoppingDistance=NaN;
if ~isempty(k)
 m.firstBrakeTime=r.time(k);
 j=find(r.state(k:end,2)<=0.01,1);
 if ~isempty(j), m.stoppingDistance=r.state(k+j-1,1)-r.state(k,1); end
end
m.peakDecel=-min(r.state(:,5));
end
