clc
clear

%% prepare an external land-sea mask file for SST data cleaning

mask_2D = squeeze(ncread('BAL-MFC_003_011_mask_bathy.nc', 'deptho'));
mask_2D(~isnan(mask_2D))=1;

mask_lon=ncread('BAL-MFC_003_011_mask_bathy.nc', 'longitude');
mask_lat=ncread('BAL-MFC_003_011_mask_bathy.nc', 'latitude');


%% read SST data and save as .mat
data_folder='SST_data/';
data_name_prefix='SST_BAL_';

SST_reshaped=[];
time_counter=1;
for y=1982:2023

    file_name=[data_folder,data_name_prefix,num2str(y),'.nc'];

    if y==1982
        sst_lon=ncread(file_name, 'longitude');
        sst_lat=ncread(file_name, 'latitude');

        mask_2D=interpn(mask_lon',mask_lat,mask_2D,sst_lon',sst_lat,'nearest');
        save('mask_2D.mat','mask_2D','-v7.3')

        not_nan_idx=find(~isnan(mask_2D(:)));
        save('not_nan_idx.mat','not_nan_idx','-v7.3')

        n = max(factor(numel(not_nan_idx)));
        m = numel(not_nan_idx) / n;

    end


    sst_info = ncinfo(file_name, 'analysed_sst');
    num_days = sst_info.Size(3);

    for d = 1:num_days
        sst_d = ncread(file_name, 'analysed_sst', [1,1,d], [Inf,Inf,1]);
        sst_d = sst_d(:);
        sst_d = sst_d(not_nan_idx);

        SST_reshaped(:,:,time_counter) = single(reshape(sst_d, n, m));
        time_counter = time_counter + 1;
    end

    disp(['Year processed: ', num2str(y)])


end

save('sst_lon.mat', 'sst_lon', '-v7.3')
save('sst_lat.mat', 'sst_lat', '-v7.3')
SST_reshaped=single(SST_reshaped);
save('SST_reshaped.mat', 'SST_reshaped', '-v7.3')
%%











