clc
clear

cd MHW_events\NCfiles\

Files_info={};
data_info=dir('*.nc');
data_name={data_info.name};

for i=1:numel(data_name)-1

    Files_info{i,1}=data_name{i};
    dt=datetime(1970,1,1,0,0,0)+seconds(ncread(data_name{i},'time'));
    Files_info{i,2}=numel(dt);
    Files_info{i,3}=datestr(dt(1),'yyyy mmm dd');
    Files_info{i,4}=datestr(dt(end),'yyyy mmm dd');

end
header = {'file_name', 'event_duration', 'event_onset', 'event_end'};
output = [header; Files_info];

% Write to CSV
filename = 'BALMHW_data_info.csv';
writecell(output, filename);

