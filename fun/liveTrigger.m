function handles=liveTrigger(handles)

global SignalDAQ

handles=AnalogicSignalOCT(handles);
queueOutputData(handles.DAQ.s,SignalDAQ);
startBackground(handles.DAQ.s);
