%% Add Directories
%-------------------------------------------------------------------------%
addpath(genpath("../../Algorithms"));

%% Create Params
%-------------------------------------------------------------------------%
Params = load("ParamsAll").ParamsAll.v4;
Params.nTx = 2;
Params.nFFT = 512;
Params = AWR1243_ArrayDimensions(Params,false);
Params.rangeAxis = generateRangeAxis(Params,Params.nFFT);

%% Saved Data
%-------------------------------------------------------------------------%
%      Steps
%   1. Configure radar in mmWave Studio or with GUI
%   2. Trigger Frame (No of Frames = Params.nFrame)
Params.scanName = "realTimeData_Raw_0";
Params.nFrame = 2048;
dataSaved = DCA1000_dataRead_custom(Params);

%% Look at the k Plot
%-------------------------------------------------------------------------%
k3D = permute(dataSaved,[2,1,3]);

figure
plot(Params.k,abs(abs(k3D(:,:))))
title("Saved Data k Plot")

%% Look at the Range Plot
%-------------------------------------------------------------------------%
range3D = fft(permute(dataSaved,[2,1,3]),Params.nFFT)/Params.nFFT;

figure
plot(Params.rangeAxis,abs(range3D(:,:)))
title("Saved Data Range Plot")






%% Functions
%-------------------------------------------------------------------------%

function rawData3D = DCA1000_dataRead_custom(Params)
%% Declare Optional Parameters
%-------------------------------------------------------------------------%

%% Read from Bin File
%-------------------------------------------------------------------------%
fileID = fopen(Params.scanName + ".bin",'r');
rawData3D = fread(fileID,'uint16','l');
fclose(fileID);
rawData3D = gpuArray(single(rawData3D)) - 2^15;
%% Reshape Row Data and Calculate Complex Row Data
%-------------------------------------------------------------------------%
rawData3D = reshape(rawData3D,2*Params.nRx,[]);
rawData3D = complex(rawData3D([1,3,5,7],:),rawData3D([2,4,6,8],:));

%% Reshape Row Data Accordingly
%-------------------------------------------------------------------------%
try
    rawData3D = reshape(rawData3D,Params.nRx,Params.adcSample,Params.nTx,Params.nFrame);
catch
    warning("Something is wrong with the number of captures!")
    return;
end

%% Create Virtual Array
%-------------------------------------------------------------------------%
% rawData3D = s(y,k,indFrame)
rawData3D = reshape(permute(rawData3D,[1,3,2,4]),Params.nRx*Params.nTx,Params.adcSample,Params.nFrame);
end