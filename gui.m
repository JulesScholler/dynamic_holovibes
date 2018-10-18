function varargout = gui(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_OpeningFcn, ...
    'gui_OutputFcn',  @gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
addpath('./fun')
handles.com_port = "1";
handles.DAQ.s=daq.createSession('ni');
handles.DAQ.s.IsContinuous = true;
handles.DAQ.s.IsNotifyWhenScansQueuedBelowAuto=true;
handles.DAQ.s.Rate = 100e3;
handles.DAQ.lh=addlistener(handles.DAQ.s,'DataRequired',@queueMoreData);
handles.octCam.ExpTime=5;
handles.octCam.FcamOCT=150;
handles.exp.piezoMode=1;
handles.exp.PhiPiezo=0;
handles.exp.AmplPiezo=0;
addAnalogOutputChannel(handles.DAQ.s,'Dev3','ao1','Voltage'); % Piezo Ref arm OCT
addAnalogOutputChannel(handles.DAQ.s,'Dev3','ao0','Voltage'); % Trigger Camera OCT
handles.output = hObject;
guidata(hObject, handles);


function varargout = gui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function editComPort_Callback(hObject, eventdata, handles)
handles.com_port=get(hObject,'String');
guidata(hObject, handles);
    
function editComPort_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbuttonOpen_Callback(hObject, eventdata, handles)
port = strcat('com', handles.com_port);
handles.motors.port = serial(port,'BaudRate',9600);
fopen(handles.motors.port);
handles.motors.protocol=Zaber.Protocol.detect(handles.motors.port);
handles.motors.sample = Zaber.BinaryDevice.initialize(handles.motors.protocol, 1);
handles.motors.ref = Zaber.BinaryDevice.initialize(handles.motors.protocol, 2);
handles.motors.RefMode=get(handles.menuRefMotor,'Value');
handles.motors.SampleMode=get(handles.menuSampleMotor,'Value');
guidata(hObject, handles);

function pushClose_Callback(hObject, eventdata, handles)
if ~isempty(handles.motors.port)
    if strcmp(handles.motors.port.Status,'open')
        fclose(handles.motors.port);
    end
end
guidata(hObject,handles);

function pushbuttonRefStart_Callback(hObject, eventdata, handles)
x=str2double(get(handles.editRef,'String'));
handles.motors.RefMode=get(handles.menuRefMotor,'Value');
switch handles.motors.RefMode
    case 1 % Given movement
        move=round(handles.motors.ref.Units.positiontonative(x*1e-6)*5); % Translates the value in microns to the number of microsteps. We multiply by 5 for the Thorlabs translation stage.
        handles.motors.ref.moverelative(move);
    case 2 % Given speed
        set(handles.pushbuttonRefStart,'BackgroundColor',[0.94 0.94 0.94]);
        set(handles.pushbuttonRefStop,'BackgroundColor',[1 0 0]);
        speed=round(handles.motors.ref.Units.velocitytonative(x*1e-6)*5); % Translates the value in um/s to the number of microsteps/s.
        handles.motors.ref.moveatvelocity(speed);
    case 3 % Given absolute position
        handles.motors.ref.moveabsolute(x);
end
guidata(hObject,handles);

function pushbuttonRefStop_Callback(hObject, eventdata, handles)
set(handles.pushbuttonRefStart,'BackgroundColor',[0.47 0.67 0.19]);
set(handles.pushbuttonRefStop,'BackgroundColor',[0.94 0.94 0.94]);
handles.motors.ref.stop();

function pushbuttonRefPosition_Callback(hObject, eventdata, handles)
handles.motors.refPosition=handles.motors.ref.getposition();
set(handles.textRefPosition,'String',num2str(handles.motors.refPosition));
guidata(hObject,handles)

function pushbuttonSampleStart_Callback(hObject, eventdata, handles)
x=str2double(get(handles.editSample,'String'));
handles.motors.SampleMode=get(handles.menuSampleMotor,'Value');
switch handles.motors.SampleMode
    case 1 % Given movement
        move=round(handles.motors.sample.Units.positiontonative(x*1e-6)*5); % Translates the value in microns to the number of microsteps.
        handles.motors.sample.moverelative(move);
    case 2 % Given speed
        set(handles.pushbuttonSampleStart,'BackgroundColor',[0.94 0.94 0.94]);
        set(handles.pushbuttonSampleStop,'BackgroundColor',[1 0 0]);
        speed=round(handles.motors.sample.Units.velocitytonative(x*1e-6)*5); % Translates the value in um/s to the number of microsteps/s.
        handles.motors.sample.moveatvelocity(speed);
    case 3 % Given absolute position
        handles.motors.sample.moveabsolute(x);
end
guidata(hObject,handles)

function pushbuttonSampleStop_Callback(hObject, eventdata, handles)
set(handles.pushbuttonSampleStart,'BackgroundColor',[0.47 0.67 0.19]);
set(handles.pushbuttonSampleStop,'BackgroundColor',[0.94 0.94 0.94]);
handles.motors.sample.stop();

function pushbuttonSamplePosition_Callback(hObject, eventdata, handles)
handles.motors.samplePosition=handles.motors.sample.getposition();
set(handles.textSamplePosition,'String',num2str(handles.motors.samplePosition));
guidata(hObject,handles)

function menuRefMotor_Callback(hObject, eventdata, handles)

function menuRefMotor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function menuSampleMotor_Callback(hObject, eventdata, handles)

function menuSampleMotor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editRef_Callback(hObject, eventdata, handles)

function editRef_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSample_Callback(hObject, eventdata, handles)

function editSample_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbuttonTriggerStart_Callback(hObject, eventdata, handles)
set(hObject,'backgroundcolor',[0.94 0.94 0.94])
set(handles.pushbuttonTriggerStop,'backgroundcolor',[1 0 0])
handles=liveTrigger(handles);
guidata(hObject,handles)

function pushbuttonTriggerStop_Callback(hObject, eventdata, handles)
stop(handles.DAQ.s);
set(hObject,'backgroundcolor',[0.94 0.94 0.94])
set(handles.pushbuttonTriggerStart,'backgroundcolor',[0.47 0.67 0.19])
guidata(hObject,handles)

function pushbuttonQuit_Callback(hObject, eventdata, handles)
quitgui(handles)

function editExposureTime_Callback(hObject, eventdata, handles)
handles.octCam.ExpTime=str2double(get(hObject, 'String'));
if  (handles.octCam.ExpTime+0.2)>1000/handles.octCam.FcamOCT
    handles.octCam.FcamOCT=1000/(handles.octCam.ExpTime+0.2); % Condition to be satisfied for correct imaging.
end
% Update the GUI with new values.
set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
set(handles.editExposureTime, 'String', num2str(handles.octCam.ExpTime));
handles=AnalogicSignalOCT(handles);
guidata(hObject,handles)


function editExposureTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editFrameRate_Callback(hObject, eventdata, handles)
handles.octCam.FcamOCT=str2double(get(handles.editFrameRate,'String'));
handles.octCam.FrameTime=1000/handles.octCam.FcamOCT; % ms
if handles.octCam.FrameTime<(handles.octCam.ExpTime+0.2) % Condition to be satisfied for correct imaging.
    handles.octCam.ExpTime=handles.octCam.FrameTime-0.2;
end
% Update GUI with new values.
set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
set(handles.editExposureTime, 'String', num2str(handles.octCam.FrameTime));
handles=AnalogicSignalOCT(handles);
guidata(hObject,handles)

function editFrameRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPhase_Callback(hObject, eventdata, handles)
handles.exp.PhiPiezo=str2double(get(hObject,'string'))*pi/180;
handles=AnalogicSignalOCT(handles);
guidata(hObject,handles)

function editPhase_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenuPiezoModulation_Callback(hObject, eventdata, handles)
handles.exp.piezoMode=get(hObject,'Value');
switch handles.exp.piezoMode
    case 1
        handles.octCam.FcamOCT=150;
        handles.octCam.FrameTime=1000/handles.octCam.FcamOCT; % ms
        % Update GUI with new values.
        set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
        set(handles.editExposureTime, 'String', num2str(handles.octCam.ExpTime));
    case 2
        handles.exp.AmplPiezo=5.9;
        set(handles.editAmplitude,'String',num2str(handles.exp.AmplPiezo));
        handles.octCam.FcamOCT=80;
        handles.octCam.FrameTime=1000/handles.octCam.FcamOCT; % ms
        if handles.octCam.FrameTime<(handles.octCam.ExpTime+0.2) % Condition to be satisfied for correct imaging.
            handles.octCam.ExpTime=handles.octCam.FrameTime-0.2;
        end
        % Update GUI with new values.
        set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
        set(handles.editExposureTime, 'String', num2str(handles.octCam.ExpTime));
    case 3
        handles.exp.AmplPiezo=8.8;
        set(handles.editAmplitude,'String',num2str(handles.exp.AmplPiezo));
        handles.octCam.FcamOCT=80;
        handles.octCam.FrameTime=1000/handles.octCam.FcamOCT; % ms
        if handles.octCam.FrameTime<(handles.octCam.ExpTime+0.2) % Condition to be satisfied for correct imaging.
            handles.octCam.ExpTime=handles.octCam.FrameTime-0.2;
        end
        % Update GUI with new values.
        set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
        set(handles.editExposureTime, 'String', num2str(handles.octCam.ExpTime));
    case 4
        handles.exp.AmplPiezo=10;
        set(handles.editAmplitude,'String',num2str(handles.exp.AmplPiezo));
        handles.octCam.FcamOCT=80;
        handles.octCam.FrameTime=1000/handles.octCam.FcamOCT; % ms
        if handles.octCam.FrameTime<(handles.octCam.ExpTime+0.2) % Condition to be satisfied for correct imaging.
            handles.octCam.ExpTime=handles.octCam.FrameTime-0.2;
        end
        % Update GUI with new values.
        set(handles.editFrameRate, 'String', num2str(handles.octCam.FcamOCT));
        set(handles.editExposureTime, 'String', num2str(handles.octCam.ExpTime));
end
handles=AnalogicSignalOCT(handles);
guidata(hObject,handles)

function popupmenuPiezoModulation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editAmplitude_Callback(hObject, eventdata, handles)
handles.exp.AmplPiezo=str2double(get(handles.editAmplitude,'String'));
handles=AnalogicSignalOCT(handles);
guidata(hObject,handles)

function editAmplitude_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
