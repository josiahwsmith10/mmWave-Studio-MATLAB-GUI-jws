function Connect_mmWaveStudio(app)
%% Do TI Work
% Initialize Radarstudio .NET connection
try
    ErrStatus = Init_RSTD_Connection(app.RSTD_DLL_Path);
catch
    warndlg("Check the public properties of the app and change RSTD_DLL_PATH to one that works for you!","ERROR: please make changes and restart the app!");
end
if (ErrStatus ~= 30000)
    app.mmWaveStudioTextArea.Value = 'Error inside Init_RSTD_Connection';
    app.mmWaveStudioLamp.Color = 'red';
    app.isConnectedmmWaveStudio = false;
    return;
else
    app.mmWaveStudioTextArea.Value = 'RSTD connection is successful';
    app.mmWaveStudioLamp.Color = 'green';
    app.isConnectedmmWaveStudio = true;
end