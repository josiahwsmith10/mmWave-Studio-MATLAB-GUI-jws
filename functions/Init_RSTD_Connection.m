%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZE CONNECTION WITH TI AWR1443 FMCW RADAR
%
% CREATED BY:
% MUHAMMET EMIN YANIK
%
% ADVISOR:
% PROFESSOR MURAT TORLAK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ErrStatus = Init_RSTD_Connection(RSTD_DLL_Path)
%This script establishes the connection with Radarstudio software
%   Pre-requisites:
%   Type RSTD.NetStart() in Radarstudio Luashell before running the script. This would open port 2777
%   Returns 30000 if no error.

if (strcmp(which('RtttNetClientAPI.RtttNetClient.IsConnected'),'')) %First time the code is run after opening MATLAB
    disp('Adding RSTD Assembly');
    try
        RSTD_Assembly = NET.addAssembly(RSTD_DLL_Path);
    catch ex
    end
    if exist('ex','var')
        ex.ExceptionObject.LoaderExceptions.Get(0).Message
        disp('RSTD Assembly not loaded correctly. Check DLL path');
        ErrStatus = -10;
        return
    end
    if ~strcmp(RSTD_Assembly.Classes{1},'RtttNetClientAPI.RtttClient')
        disp('RSTD Assembly not loaded correctly. Check DLL path');
        ErrStatus = -10;
        return
    end
    Init_RSTD_Connection = 1;
elseif ~RtttNetClientAPI.RtttNetClient.IsConnected() %Not the first time but port is diconnected
    % Reason:
    % Init will reset the value of Isconnected. Hence Isconnected should be checked before Init
    % However, Isconnected returns null for the 1st time after opening MATLAB (since init was never called before)
    Init_RSTD_Connection = 1;
else
    Init_RSTD_Connection = 0;
end
if Init_RSTD_Connection
    disp('Initializing RSTD client');
    ErrStatus = RtttNetClientAPI.RtttNetClient.Init();
    if (ErrStatus ~= 0)
        disp('Unable to initialize NetClient DLL');
        return;
    end
    disp('Connecting to RSTD client');
    ErrStatus = RtttNetClientAPI.RtttNetClient.Connect('127.0.0.1',2777);
    if (ErrStatus ~= 0)
        disp('Unable to connect to Radarstudio');
        disp('Reopen port in Radarstudio. Type RSTD.NetClose() followed by RSTD.NetStart()')
        return;
    end
    pause(1);%Wait for 1sec. NOT a MUST have.
end
disp('Sending test message to RSTD');
Lua_String = 'WriteToLog("Running script from MATLAB\n", "green")';
ErrStatus = RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
if (ErrStatus ~= 30000)
    disp('Radarstudio Connection Failed');
end
disp('Test message success');
end

