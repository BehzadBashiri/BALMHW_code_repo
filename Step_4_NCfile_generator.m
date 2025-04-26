clc
clear

load('sst_lon.mat')
load('sst_lat.mat')
load('mask_2D.mat')

R=6400000; % Earth radius

area_mat=nan(numel(sst_lon),numel(sst_lat));

for i=1:numel(sst_lon)
    for j=1:numel(sst_lat)
        if ~isnan(mask_2D(i,j))
            dx=mean(diff(sst_lon)) * (R * cosd(sst_lat(j)) * pi/180); %0.02 in degree is the difference between each grid poing along each axis 
            dy=mean(diff(sst_lat)) * (R * pi/180);
            area_mat(i,j)=dx.*dy./1000000; %convert to km^2
        end
    end
end

save('area_mat.mat','area_mat','-v7.3')
%%
load('MHW_start_end.mat')
mhw_time=datetime(1982,1,2,12,0,0):days(1):datetime(2023,12,30,12,0,0);

longitude=sst_lon;
latitude=sst_lat;


cd MHW_events\
mat_data_file_info=dir('*.mat');
mat_data_name={mat_data_file_info.name};
mkdir('NCfiles')

%%
for f=1:numel(mat_data_name)

    load(mat_data_name{f})
    num = regexp(mat_data_name{f}, '\d+', 'match'); % Extract the number as a cell array
    num = str2double(num{1}); % Convert to double
    disp(num);

    dt=mhw_time(MHW_start_end(num,1):MHW_start_end(num,2));

    % Convert to double (seconds since 1970-01-01 00:00:00)
    time = posixtime(dt);

    MHW_int_maps=MHW_event;
    MHW_area_maps=area_mat.*ones(size(MHW_int_maps));
    MHW_area_maps(isnan(MHW_int_maps))=0;

    MHW_int_maps=single(MHW_int_maps);

    MHW_area_ts=[];
    MHW_int_ts=[];

    for t=1:length(dt)

        I=squeeze(MHW_int_maps(:,:,t));
        A=squeeze(MHW_area_maps(:,:,t));

        MHW_int_ts(1,t)=nanmean(I(:));
        MHW_area_ts(1,t)=sum(A(:));

    end

% Define NetCDF file name
                   % Define NetCDF file name
    ncFileName = sprintf('NCfiles/BALMHW_event_%03d.nc', num); % Ensures proper 3-digit formatting

    % Create the NetCDF file in NETCDF4 format
    ncid = netcdf.create(ncFileName, 'NETCDF4');

    MHW_int_ts=single(MHW_int_ts);
    MHW_area_ts=single(MHW_area_ts);

    %% Define Dimensions
    timeDimID  = netcdf.defDim(ncid, 'time', numel(time)); % Fixed-length time dimension
    latDimID   = netcdf.defDim(ncid, 'latitude', numel(latitude));
    lonDimID   = netcdf.defDim(ncid, 'longitude', numel(longitude));

    %% Define Variables

    % Time variable
    timeVarID = netcdf.defVar(ncid, 'time', 'double', timeDimID);
    netcdf.putAtt(ncid, timeVarID, 'standard_name', 'MHW Event Dates (Daily Resolution)');
    netcdf.putAtt(ncid, timeVarID, 'long_name', 'Time');
    netcdf.putAtt(ncid, timeVarID, 'units', 'seconds since 1970-01-01 00:00:00');
    netcdf.putAtt(ncid, timeVarID, 'calendar', 'gregorian');
    netcdf.putAtt(ncid, timeVarID, 'axis', 'T');

    % Latitude variable
    latVarID = netcdf.defVar(ncid, 'latitude', 'float', latDimID);
    netcdf.putAtt(ncid, latVarID, 'standard_name', 'latitude');
    netcdf.putAtt(ncid, latVarID, 'long_name', 'Latitude');
    netcdf.putAtt(ncid, latVarID, 'units', 'degrees_north');
    netcdf.putAtt(ncid, latVarID, 'axis', 'Y');

    % Longitude variable
    lonVarID = netcdf.defVar(ncid, 'longitude', 'float', lonDimID);
    netcdf.putAtt(ncid, lonVarID, 'standard_name', 'longitude');
    netcdf.putAtt(ncid, lonVarID, 'long_name', 'Longitude');
    netcdf.putAtt(ncid, lonVarID, 'units', 'degrees_east');
    netcdf.putAtt(ncid, lonVarID, 'axis', 'X');

    % MHW_int_maps variable (3D matrix)
    mhwVarID = netcdf.defVar(ncid, 'MHW_int_maps', 'float', [lonDimID, latDimID, timeDimID]);
    netcdf.putAtt(ncid, mhwVarID, 'units', 'kelvin');
    netcdf.putAtt(ncid, mhwVarID, '_FillValue', single(NaN));
    netcdf.putAtt(ncid, mhwVarID, 'standard_name', 'daily maps of MHW intensity during an event');
    netcdf.putAtt(ncid, mhwVarID, 'long_name', 'A 3D numeric matrix (lon, lat, MHW duration) containing daily MHW intensity');

    % MHW affected area time series
    areaVarID = netcdf.defVar(ncid, 'MHW_area_ts', 'float', timeDimID);
    netcdf.putAtt(ncid, areaVarID, 'units', 'km^2');
    netcdf.putAtt(ncid, areaVarID, '_FillValue', single(NaN));
    netcdf.putAtt(ncid, areaVarID, 'standard_name', 'daily MHW affected area');
    netcdf.putAtt(ncid, areaVarID, 'long_name', 'Daily time series of affected area (km²) during MHW event');

    % MHW mean intensity time series
    meanIntVarID = netcdf.defVar(ncid, 'MHW_int_ts', 'float', timeDimID);
    netcdf.putAtt(ncid, meanIntVarID, 'units', 'kelvin');
    netcdf.putAtt(ncid, meanIntVarID, '_FillValue', single(NaN));
    netcdf.putAtt(ncid, meanIntVarID, 'standard_name', 'daily mean MHW intensity');
    netcdf.putAtt(ncid, meanIntVarID, 'long_name', 'Daily time series of mean MHW intensity');

    % Define Global Attributes
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'title', 'Baltic Sea MHW analysis');
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'institution', 'Department of Marine Systems, TalTech, Estonia');
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'reference SST data product', 'https://doi.org/10.48670/moi-00156');
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'further details', 'Bashiri, B., Barzandeh, A., Männik, A., & Raudsepp, U. (2024). Variability of marine heatwaves’ characteristics and assessment of their potential drivers in the Baltic Sea over the last 42 years. Scientific Reports, 14(1), 22419.');
    % End definition mode
    netcdf.endDef(ncid);

    %% Write Data
    netcdf.putVar(ncid, timeVarID, time);
    netcdf.putVar(ncid, latVarID, latitude);
    netcdf.putVar(ncid, lonVarID, longitude);
    netcdf.putVar(ncid, mhwVarID, MHW_int_maps);
    netcdf.putVar(ncid, areaVarID, MHW_area_ts);
    netcdf.putVar(ncid, meanIntVarID, MHW_int_ts);

    %% Close the NetCDF file
    netcdf.close(ncid);

    disp(['NetCDF file "' ncFileName '" created successfully.']);
   % ncdisp(ncFileName);
end
