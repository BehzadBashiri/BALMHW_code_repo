#!/bin/bash
mkdir SST_data
# Static parameters
DATASET_ID="DMI_BAL_SST_L4_REP_OBSERVATIONS_010_016"
VARIABLE="analysed_sst"
MIN_LON=9
MAX_LON=31
MIN_LAT=53.5
MAX_LAT=66

for YEAR in {1982..2023}; do
    echo "Processing year: $YEAR"

    START_DATE="${YEAR}-01-01T00:00:00"
    END_DATE="${YEAR}-12-31T00:00:00"

    # Run the subset command
    yes Y | copernicusmarine subset \
        --dataset-id $DATASET_ID \
        --variable $VARIABLE \
        --start-datetime $START_DATE \
        --end-datetime $END_DATE \
        --minimum-longitude $MIN_LON \
        --maximum-longitude $MAX_LON \
        --minimum-latitude $MIN_LAT \
        --maximum-latitude $MAX_LAT

    # Rename the most recent .nc file
    latest_file=$(ls -t *.nc | head -n1)
    mv "$latest_file" "SST_data/SST_BAL_${YEAR}.nc"
    echo "Saved as: SST_BAL_${YEAR}.nc"
done
