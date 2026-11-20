function next=aeb_plant(s,cmd,t,p)
% First-order brake response + friction limit + exact constant-a substep.
dt=p(1); aLimit=min(p(3),p(2)*9.81);
target=max(-aLimit,min(p(18),cmd));
if p(4)>0
    a=s(5)+(1-exp(-dt/p(4)))*(target-s(5));
else
    a=target;
end
% Clamp residual negative acceleration at rest. No reversing.
if s(2)<=0 && a<0, a=0; end
leadA=0;
if t+1e-10>=p(5) && s(4)>0, leadA=-p(6); end
[xe,ve]=advance(s(1),s(2),a,dt);
[xl,vl]=advance(s(3),s(4),leadA,dt);
next=[xe;ve;xl;vl;a];
end
function [x,v]=advance(x,v,a,dt)
step=dt;
if a<0 && v+a*dt<0, step=-v/a; end
x=x+v*step+0.5*a*step^2;
v=max(0,v+a*dt);
end
