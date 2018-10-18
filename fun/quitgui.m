function quitgui(handles)
% Function to exit the GUI and close properly every opened objects.

if isfield(handles,'motors')
    if(strcmp(handles.motors.port.Status,'open'))
        fclose(handles.motors.port);
    end
end

if isfield(handles,'DAQ')
    stop(handles.DAQ.s);
    delete(handles.DAQ.lh);
end

fprintf('The program has exited properly.\n');

close all
clear all