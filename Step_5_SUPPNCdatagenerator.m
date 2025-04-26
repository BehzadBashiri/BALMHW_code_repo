clc
clear

load('sst_lon.mat')
load('sst_lat.mat')
load('area_mat.mat')
load('mclim.mat')
load('m90.mat')
load('not_nan_idx.mat')

mclim_reshaped=mclim;
m90_reshaped=m90;

mclim=[];
m90=[];

for d=1:size(mclim_reshaped,3)

        mclim_d=squeeze(mclim_reshaped(:,:,d));
        mclim_d=mclim_d(:);
        mclim_1D=nan(numel(sst_lon)*numel(sst_lat),1);
        mclim_1D(not_nan_idx)=mclim_d;
        mclim(:,:,d)=reshape(mclim_1D,numel(sst_lon),numel(sst_lat));

        m90_d=squeeze(m90_reshaped(:,:,d));
        m90_d=m90_d(:);
        m90_1D=nan(numel(sst_lon)*numel(sst_lat),1);
        m90_1D(not_nan_idx)=m90_d;
        m90(:,:,d)=reshape(m90_1D,numel(sst_lon),numel(sst_lat));

    end


longitude=sst_lon;
latitude=sst_lat;
dt=1:366;

% Convert to double (seconds since 1970-01-01 00:00:00)
% Define NetCDF file name
                   % Define NetCDF file name
    ncFileName = 'MHW_events/NCfiles/BALMHW_supp.nc'; % Ensures proper 3-digit formatting

    % Create the NetCDF file in NETCDF4 format
    ncid = netcdf.create(ncFileName, 'NETCDF4');

    mclim=single(mclim);
    m90=single(m90);

    %% Define Dimensions
    timeDimID  = netcdf.defDim(ncid, 'time', numel(dt)); % Fixed-length time dimension
    latDimID   = netcdf.defDim(ncid, 'latitude', numel(latitude));
    lonDimID   = netcdf.defDim(ncid, 'longitude', numel(longitude));

  %% Define Variables

% Time variable (Julian day of year: 1–366)
timeVarID = netcdf.defVar(ncid, 'time', 'double', timeDimID);
netcdf.putAtt(ncid, timeVarID, 'standard_name', 'time');
netcdf.putAtt(ncid, timeVarID, 'long_name', 'Julian day of year');
netcdf.putAtt(ncid, timeVarID, 'units', ...
    '1: January 1st, 2: January 2nd, ..., 60: February 29th, ..., 366: December 31st');
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

% Climatology variable (mclim)
climVarID = netcdf.defVar(ncid, 'mclim', 'float', [lonDimID, latDimID, timeDimID]);
netcdf.putAtt(ncid, climVarID, 'units', 'kelvin');
netcdf.putAtt(ncid, climVarID, '_FillValue', single(NaN));
netcdf.putAtt(ncid, climVarID, 'standard_name', 'daily climatology');
netcdf.putAtt(ncid, climVarID, 'long_name', ...
    '3D matrix (lon, lat, Julian day) containing daily SST climatologies (1992–2002) for each grid point.');

% MHW threshold variable (m90)
m90VarID = netcdf.defVar(ncid, 'm90', 'float', [lonDimID, latDimID, timeDimID]);
netcdf.putAtt(ncid, m90VarID, 'units', 'kelvin');
netcdf.putAtt(ncid, m90VarID, '_FillValue', single(NaN));
netcdf.putAtt(ncid, m90VarID, 'standard_name', 'daily 90th percentile threshold');
netcdf.putAtt(ncid, m90VarID, 'long_name', ...
    '3D matrix (lon, lat, Julian day) containing the 90th percentile SST thresholds for MHW detection (1992–2002).');

% Grid cell area variable 
balareaVarID = netcdf.defVar(ncid, 'BALarea', 'float', [lonDimID, latDimID]);
netcdf.putAtt(ncid, balareaVarID, 'units', 'km^2');
netcdf.putAtt(ncid, balareaVarID, '_FillValue', single(NaN));
netcdf.putAtt(ncid, balareaVarID, 'standard_name', 'cell_area');
netcdf.putAtt(ncid, balareaVarID, 'long_name', ...
    '2D matrix (lon, lat) indicating the physical area of each grid cell in km^2.');

%% Define Global Attributes
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'title', 'Supplementary material for Baltic Sea MHW analysis');
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'institution', 'Department of Marine Systems, TalTech, Estonia');
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'reference SST data product', 'https://doi.org/10.48670/moi-00156');
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'further details', 'Bashiri, B., Barzandeh, A., Männik, A., & Raudsepp, U. (2024). Variability of marine heatwaves’ characteristics and assessment of their potential drivers in the Baltic Sea over the last 42 years. Scientific Reports, 14(1), 22419.');


% End definition mode
netcdf.endDef(ncid);


    %% Write Data
    netcdf.putVar(ncid, timeVarID, dt);
    netcdf.putVar(ncid, latVarID, latitude);
    netcdf.putVar(ncid, lonVarID, longitude);
    netcdf.putVar(ncid, climVarID, mclim);
    netcdf.putVar(ncid, m90VarID, m90);
    netcdf.putVar(ncid, balareaVarID, area_mat);

    %% Close the NetCDF file
    netcdf.close(ncid);

        ncdisp(ncFileName)

























 




