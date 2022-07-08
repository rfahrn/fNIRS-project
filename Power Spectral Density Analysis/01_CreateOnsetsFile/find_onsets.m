clear all
clc

% Make Conditions file
% Takes Hitachi csv file as input.

% Selects and reads in the data file.
[filen, pathn] = uigetfile('*.csv','Select the raw probe data file');
path_file_n = [pathn filen];
if filen(1) == 0 | pathn(1) == 0
    return;
end
fid = fopen(path_file_n);
disp('Loading data...');
while 1
    tline = fgetl(fid);

    if isempty(strfind(tline, 'Mode')) == 0
        rindex = find(tline == ',');
        tline(rindex) = ' ';
        text_array = tline(rindex(1)+1:end);
    end
    if isempty(strfind(tline, 'Wave[nm]')) == 0
        windex = find(tline == ',');
        tline(windex) = ' ';
        text_lambda = tline(windex(1)+1:end);
        wavelengths = str2num(text_lambda);
    end
    if isempty(strfind(tline, 'Sampling Period[s]')) == 0
        nindex = find(tline == ',');
        tline(nindex) = ' ';
        txt_fs = tline(nindex(1)+1:end);
        fs = 1./mean(str2num(txt_fs));
    end
    
    if isempty(strfind(tline, 'Data')) == 0
        tline = fgetl(fid);
        nch = length(strfind(tline, 'CH'));
        nindex = find(tline == ',');
        try
            col_mark = strfind(tline, 'Mark');
            col_mark = col_mark(1);
            col_mark = find(nindex == col_mark - 1) + 1;
        end
        try
            col_prescan = strfind(tline, 'PreScan');
            col_prescan = col_prescan(1);
            col_prescan = find(nindex == col_prescan - 1)+1;
        end
        while 1
            tline = fgetl(fid);
            if ischar(tline) == 0, break, end,
            nindex = find(tline == ',');
            tline_data = tline(nindex(1)+1:nindex(nch+1)-1);
            nindex_d = find(tline_data == ',');
            tline_data(nindex_d) = ' ';
            tline_data = str2num(tline_data);
            count = str2num(tline(1:nindex(1)-1));
            nirs_data.rawData(count, :) = tline_data;
            try
                vector_onset(count) = str2num(tline(nindex(col_mark-1)+1:nindex(col_mark)-1));
            end
            try
                baseline(count) = str2num(tline(nindex(col_prescan-1)+1:nindex(col_prescan)-1));
            end
        end
        break;
    end
end

offset = 'y';
disp('Removing closing trigger...');

markertimes = [find(vector_onset>0) find(vector_onset<0)];
markers = vector_onset(markertimes);
unique_markers = unique(markers);
aux = zeros(count, length(unique_markers));
for stimuli=1:length(unique_markers)
    if offset == 'y' || offset == 'Y'                                   % Version 3
        stim_on_off = find(vector_onset==(unique_markers(stimuli)));    % Version 3
        stim_markers = stim_on_off(1:2:length(stim_on_off)-1);          % Version 3
        aux(stim_markers,stimuli) = 1;                                  % Version 3
    else                                                                % Version 3
        stim_markers = find(vector_onset==(unique_markers(stimuli)));
        aux(stim_markers,stimuli) = 1;
    end                                                                 % Version 3
end

fs = 10;

%% Make condition file (onsets.mat)
% Task blocks
onsets=cell(1,6);
names=cell(1,6);
duration=cell(1,6);

names{1,1}='Condition1-TS';
names{1,2}='Condition2-TS-rot-TS';
names{1,3}='Condition3-TS-rot-Blesser';
names{1,4}='Condition4-TS-NV';
names{1,5}='Condition5-TS-NV-rot';

onsets{1,1}=find(aux(:,1)==1); % Condition 1
onsets{1,2}=find(aux(:,2)==1); % Condition 2
onsets{1,3}=find(aux(:,3)==1); % Condition 3
onsets{1,4}=find(aux(:,4)==1); % Condition 4
onsets{1,5}=find(aux(:,5)==1); % Condition 5

durations{1,1}=fix(21*fs).*ones(length(onsets{1,1}),1); % Duration condition 1
durations{1,2}=fix(21*fs).*ones(length(onsets{1,2}),1); % Duration condition 2
durations{1,3}=fix(21*fs).*ones(length(onsets{1,3}),1); % Duration condition 3
durations{1,4}=fix(21*fs).*ones(length(onsets{1,4}),1); % Duration condition 4
durations{1,5}=fix(21*fs).*ones(length(onsets{1,5}),1); % Duration condition 5

% Rest blocks (calculating period between two markers) 
AllOnsets=sort(cat(1,onsets{1,1},onsets{1,2},onsets{1,3},onsets{1,4},onsets{1,5}));
AllOnsets(:,2)=AllOnsets(:,1)+21*fs;
Rest(:,1)=[1;AllOnsets(:,2)+1]; % Onset

for i=1:size(AllOnsets,1)-1
    durrest(i)=AllOnsets(i+1,1)-AllOnsets(i,2);
end

Rest(:,2)=[AllOnsets(1,1)-1; durrest'; size(nirs_data.rawData,1)-AllOnsets(end,2)]; % Duration

onsets{1,6}=Rest(:,1);
durations{1,6}=Rest(:,2);
names{1,6}='Rest';

% Save informaton to mat file
save('onsets.mat','onsets','names','durations');

disp('The onsets file has been created!');




