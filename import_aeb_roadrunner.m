function rr=import_aeb_roadrunner(projectFolder,installationFolder,caseName)
% Import into a NEW scene/scenario in an existing dedicated RoadRunner project.
% Requires RoadRunner + RoadRunner Scenario; MATLAB API requires AD Toolbox.
% Example: rr=import_aeb_roadrunner('C:\RR\AEB_Project', ...
%          'C:\Program Files\RoadRunner R2024a','dry');
% The installation path varies: supply the application's actual folder.
if nargin<2, installationFolder=''; end
if nargin<3, caseName='dry'; end
assert(exist(projectFolder,'dir')==7,'AEB:RRProject',...
 'Create a dedicated project in RoadRunner first, then pass its folder.');
assert(exist('roadrunner','file')~=0,'AEB:RRAPI',...
 'RoadRunner MATLAB API not found. Use the manual import instructions.');
folder=aeb_export_roadrunner(aeb_simulate(aeb_config(caseName)));
if isempty(installationFolder)
 rr=roadrunner(projectFolder);
else
 rr=roadrunner(projectFolder,'InstallationFolder',installationFolder);
end
newScene(rr);
importScene(rr,fullfile(folder,'straight_road.xodr'),'OpenDRIVE');
stamp=datestr(now,'yyyymmdd_HHMMSS');
sceneName=['AEB_' char(caseName) '_' stamp '.rrscene'];
saveScene(rr,sceneName);
newScenario(rr);
ego=actorImportOptions('Name','Ego_AEB','Color','#2584e5');
lead=actorImportOptions('Name','Lead','Color','#ef8129');
importScenario(rr,fullfile(folder,'ego.csv'),'CSV Trajectory',...
 csvTrajectoryImportOptions('ActorImportOptions',ego));
importScenario(rr,fullfile(folder,'lead.csv'),'CSV Trajectory',...
 csvTrajectoryImportOptions('ActorImportOptions',lead));
saveScenario(rr,['AEB_' char(caseName) '_' stamp '.rrscenario']);
fprintf('Imported replay. Use Play in RoadRunner Scenario.\n');
end
