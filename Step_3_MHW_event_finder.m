clc
clear

load('mhw_ts.mat')

events_mean_series=squeeze(nanmean(nanmean(mhw_ts)));

%%
distances=find(isnan(events_mean_series));
events_tx=find(~isnan(events_mean_series));

MHW_start_end=[];
s=1;

for i=2:length(events_tx)

    if events_tx(i) - events_tx(i-1) > 1  
        MHW_start_end = [MHW_start_end; events_tx(s), events_tx(i-1)];
        s = i;  
    end
end

MHW_start_end = [MHW_start_end; events_tx(s), events_tx(length(events_tx))];
save('MHW_start_end.mat','MHW_start_end','-v7.3')

load('sst_lon.mat')
load('sst_lat.mat')
load('not_nan_idx.mat')



%%
mkdir('MHW_events')

for m=1:size(MHW_start_end,1)

    t1=MHW_start_end(m,1);
    t2=MHW_start_end(m,2);

    MHW_event_reshaped=mhw_ts(:,:,t1:t2);

    for d=1:size(MHW_event_reshaped,3)

        MHW_d=squeeze(MHW_event_reshaped(:,:,d));
        MHW_d=MHW_d(:);
        MHW_1D=nan(numel(sst_lon)*numel(sst_lat),1);
        MHW_1D(not_nan_idx)=MHW_d;

        MHW_event(:,:,d)=reshape(MHW_1D,numel(sst_lon),numel(sst_lat));

    end

    if m<10
        file_name1=['MHW_events/MHW_event_00',num2str(m),'.mat']
    elseif m>=10 && m<100 
        file_name1=['MHW_events/MHW_event_0',num2str(m),'.mat']
    else
        file_name1=['MHW_events/MHW_event_',num2str(m),'.mat']
    end

    save(file_name1,'MHW_event','-v7.3')
    MHW_event=[];

end




