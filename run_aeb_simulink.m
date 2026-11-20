function [out,r]=run_aeb_simulink(name,showModel)
% Run the editable model and check it against the MATLAB reference.
if nargin<1, name='dry'; end
if nargin<2, showModel=true; end
root=fileparts(mfilename('fullpath')); addpath(root);
model='AEB_ClosedLoop_R2024a'; file=fullfile(root,[model '.slx']);
if ~exist(file,'file'), build_aeb_model(false); else, load_system(file); end
c=aeb_config(name); aeb_model_config(model,c);
if showModel, open_system(model); end
out=sim(model); r=aeb_simulate(c);
ts=out.stateLog; cs=out.controlLog;
% Use timestamps, not array length, to align the contact-stop final step.
state=interp1(ts.Time,squeeze(ts.Data),r.time,'nearest');
err=max(abs(state-r.state),[],'all');
assert(all(isfinite(state),'all') && err<1e-8,'AEB:Parity',...
 'MATLAB/Simulink states differ (max absolute error %.3g).',err);
ctrl=interp1(cs.Time,squeeze(cs.Data),r.time,'nearest');
errControl=max(abs(ctrl(:,[1 2 4 5])-r.control(:,[1 2 4 5])),[],'all');
assert(errControl<1e-8,'AEB:Parity','Controller outputs differ by %.3g.',errControl);
fprintf('MATLAB/Simulink parity: PASS (%s, max state error %.3g).\n',name,err);
end
