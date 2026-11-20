function model=build_aeb_model(showModel)
%BUILD_AEB_MODEL Generate an editable R2024a Simulink model from source.
if nargin==0, showModel=true; end
assert(license('test','Simulink'),'AEB:License','Simulink is required for this option.');
root=fileparts(mfilename('fullpath')); addpath(root); model='AEB_ClosedLoop_R2024a';
if bdIsLoaded(model)
 assert(strcmp(get_param(model,'Dirty'),'off'),'AEB:Unsaved',...
  'Save your model edits before rebuilding. Rebuilding replaces the generated model.');
 close_system(model,0);
end
new_system(model); load_system('simulink');
set_param(model,'SolverType','Fixed-step','Solver','FixedStepDiscrete',...
 'ReturnWorkspaceOutputs','on','SaveTime','on','TimeSaveName','tout',...
 'SaveOutput','off','SignalLogging','off');
add('simulink/Sources/Constant','Parameters',[30 315 105 350],'Value','aebP');
add('simulink/Discrete/Unit Delay','Vehicle state',[190 70 285 125],...
 'InitialCondition','aebInitial','SampleTime','aebDt');
add('simulink/Sources/From Workspace','Noise and validity',[25 180 125 225],...
 'VariableName','aebNoise','Interpolate','off','SampleTime','aebDt',...
 'OutputAfterFinalValue','Holding final value');
add('simulink/Signal Routing/Mux','Sensor inputs',[345 85 350 185],'Inputs','3');
add('built-in/MATLABFcn','Synthetic radar',[395 100 530 145],...
 'MATLABFcn','aeb_sl_sensor(u)','OutputDimensions','3');
add('simulink/Discrete/Zero-Order Hold','Sensor sample hold',[570 100 670 145],'SampleTime','aebTs');
add('simulink/Discrete/Delay','Sensor latency',[710 100 805 145],...
 'DelayLength','aebDelay','InitialCondition','repmat(aebObservation,1,max(1,aebDelay))','SampleTime','aebDt');
add('simulink/Discrete/Unit Delay','Controller memory',[680 260 800 305],...
 'InitialCondition','aebMemory','SampleTime','aebDt');
add('simulink/Signal Routing/Mux','Controller inputs',[855 110 860 265],'Inputs','4');
add('built-in/MATLABFcn','AEB and cruise controller',[905 135 1075 185],...
 'MATLABFcn','aeb_sl_controller(u)','OutputDimensions','10');
add('simulink/Signal Routing/Demux','Control and memory',[1120 125 1125 215],'Outputs','[5 5]');
add('simulink/Sources/Digital Clock','Time',[920 405 985 440],'SampleTime','aebDt');
add('simulink/Signal Routing/Mux','Plant inputs',[1120 330 1125 440],'Inputs','4');
add('built-in/MATLABFcn','Vehicle and brake dynamics',[785 495 985 545],...
 'MATLABFcn','aeb_sl_plant(u)','OutputDimensions','5');
add('simulink/Sinks/To Workspace','State log',[395 20 500 50],...
 'VariableName','stateLog','SaveFormat','Timeseries');
add('simulink/Sinks/To Workspace','Control log',[1170 80 1280 115],...
 'VariableName','controlLog','SaveFormat','Timeseries');
add('simulink/Sinks/To Workspace','Sensor log',[705 20 805 50],...
 'VariableName','sensorLog','SaveFormat','Timeseries');
add('simulink/User-Defined Functions/Fcn','True bumper gap',[350 400 490 440],...
 'Expr','u(3)-u(1)-aebLength');
add('simulink/Logic and Bit Operations/Compare To Constant','Collision',[535 400 635 440],...
 'relop','<=','const','0');
add('simulink/Sinks/Stop Simulation','Stop at contact',[680 405 750 435]);
wire('Vehicle and brake dynamics/1','Vehicle state/1');
wire('Vehicle state/1','Sensor inputs/1'); wire('Noise and validity/1','Sensor inputs/2');
wire('Parameters/1','Sensor inputs/3'); wire('Sensor inputs/1','Synthetic radar/1');
wire('Synthetic radar/1','Sensor sample hold/1'); wire('Sensor sample hold/1','Sensor latency/1');
wire('Sensor latency/1','Controller inputs/1'); wire('Vehicle state/1','Controller inputs/2');
wire('Controller memory/1','Controller inputs/3'); wire('Parameters/1','Controller inputs/4');
wire('Controller inputs/1','AEB and cruise controller/1');
wire('AEB and cruise controller/1','Control and memory/1');
wire('Control and memory/2','Controller memory/1');
wire('Vehicle state/1','Plant inputs/1'); wire('Control and memory/1','Plant inputs/2');
wire('Time/1','Plant inputs/3'); wire('Parameters/1','Plant inputs/4');
wire('Plant inputs/1','Vehicle and brake dynamics/1');
wire('Vehicle state/1','State log/1'); wire('Control and memory/1','Control log/1');
wire('Sensor latency/1','Sensor log/1'); wire('Vehicle state/1','True bumper gap/1');
wire('True bumper gap/1','Collision/1'); wire('Collision/1','Stop at contact/1');
aeb_model_config(model,aeb_config);
set_param(model,'PreLoadFcn',...
 'addpath(fileparts(get_param(bdroot,''FileName'')));');
annotation=Simulink.Annotation(model,...
 ['AEB | R2024a' newline ...
 'Plant -> sampled noisy sensor -> latency -> controller -> brake/plant' newline ...
 'Memory blocks store previous values. Double-click equation blocks for the function name.' newline ...
 'Use aeb_model_config(bdroot,aeb_config(''wet'')) to change a case.']);
annotation.Position=[25 600];
save_system(model,fullfile(root,[model '.slx']));
if showModel, open_system(model); end
    function add(lib,name,pos,varargin)
        add_block(lib,[model '/' name],'Position',pos,varargin{:});
    end
    function wire(a,b)
        add_line(model,a,b,'autorouting','on');
    end
end
