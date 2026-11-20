function [u,m]=aeb_controller(z,v,p,m)
% m = [brake latch; last valid gap; last closing speed; stale age; seen flag].
% u = [requested acceleration; mode; TTC; trigger gap; estimated current gap].
% Modes: 0 cruise, 1 warning, 2 emergency brake, 3 stopped, 4 sensor fault.
dt=p(1);
if z(3)>0.5
    m(2)=z(1); m(3)=z(2); m(4)=0; m(5)=1;
else
    m(4)=m(4)+dt;
end
closing=max(m(3),0);
% Compensate configured latency and the time since the last valid reading.
gap=max(0,m(2)-closing*(p(9)+m(4)));
vLead=max(0,v-m(3));
aAvailable=max(0.1,min(p(3),p(2)*9.81));
trigger=p(8)+v*p(4)+max(0,v^2/(2*aAvailable)-vLead^2/(2*p(13)));
ttc=Inf;
if closing>0.1, ttc=gap/closing; end
fault=m(4)>p(10);
danger=(closing>0.1 && (gap<=trigger || ttc<=p(11))) || gap<=p(8);
if p(14)>0.5 && (danger || fault), m(1)=1; end
cmd=min(p(18),max(-2,0.6*(p(17)-v))); mode=0;
if p(15)>0.5
    desired=p(8)+p(16)*v;
    follow=0.25*(gap-desired)-0.8*m(3);
    cmd=min(cmd,max(-2,follow));
end
if ttc<p(12) || (closing>0.1 && gap<1.4*trigger), mode=1; end
if m(1)>0.5
    cmd=-p(3); mode=2;
    if fault, mode=4; end
    if v<=0.01, cmd=0; mode=3; end
elseif fault
    mode=4;
end
u=[cmd;mode;ttc;trigger;gap];
end
