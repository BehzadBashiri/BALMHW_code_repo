clc
clear
%% requirements
addpath m_map\
addpath m_mhw1.0-master\

load SST_reshaped.mat

%% defining the time-intervals 

time=datenum(1982,1,1):datenum(2023,12,31);
cli_start=datenum(1992,1,1);
cli_end=datenum(2002,12,31);
sst_start=datenum(1982,1,1);
sst_end=datenum(2023,12,31);
mhw_start=datenum(1982,1,2);
mhw_end=datenum(2023,12,30);

[MHW,mclim,m90,mhw_ts]=detectc(SST_reshaped,time,cli_start,cli_end,mhw_start,mhw_end);


save('MHW.mat', 'MHW', '-v7.3');
save('mclim.mat', 'mclim', '-v7.3');
save('m90.mat', 'm90', '-v7.3');
save('mhw_ts.mat', 'mhw_ts', '-v7.3');

