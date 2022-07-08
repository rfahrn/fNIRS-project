%% PSD


fs = 10; % samples per second in Hitachi fNIRS system

% Open .nirs file for LEFT channels
disp('Open .nirs file for LEFT channels (probe 1)')
[datafile2, pathname_data2] = uigetfile('.nirs','Open .nirs file for LEFT channels (probe 1)');
load([pathname_data2 '/',datafile2],'-mat');


for i=1:size(procResult.dc,3)
    HBO_left(:,i)=procResult.dc(:,1,i).*10^6;  % Convert to Mol*mm
end

figure
for i = 1:size(HBO_left,2) % Channels
    
    % Power Spectral Density Analysis
    
    D = size(HBO_left,1); %Samples
     
    [pxx,f] = pwelch(HBO_left(:,i),100*fs,[],[],fs); % PSD
    
    subplot(3,8,i)
    plot(f,20*log10(pxx),'r')
   
    ylim([ min(20*log10(pxx))-0.05 max(20*log10(pxx))+0.05])
    xlim([f(1) 2])
    xlabel('Frequency (Hz)')
    ylabel('PSD (dB/Hz)')
    title(['Ch. ' num2str(i) ' PSD'])
end

% Open .nirs file for RIGHT channels
disp('Open .nirs file for RIGHT channels (probe 2)')
[datafile3, pathname_data3] = uigetfile('.nirs','Open .nirs file for RIGHT channels (probe 2)');
load([pathname_data3 '/',datafile3],'-mat');


for i=1:size(procResult.dc,3)
    HBO_right(:,i)=procResult.dc(:,1,i).*10^6;  % Convert to Mol*mm
end

figure
for i = 1:size(HBO_right,2) % Channels
    
    % Power Spectral Density Analysis
    
    D = size(HBO_right,1); %Samples
     
    [pxx,f] = pwelch(HBO_right(:,i),100*fs,[],[],fs); % PSD
    
    subplot(3,8,i)
    plot(f,20*log10(pxx),'r')
   
    ylim([ min(20*log10(pxx))-0.05 max(20*log10(pxx))+0.05])
    xlim([f(1) 2])
    xlabel('Frequency (Hz)')
    ylabel('PSD (dB/Hz)')
    title(['Ch. ' num2str(i) ' PSD'])
end

