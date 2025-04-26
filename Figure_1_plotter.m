clc
clear

load('area_mat.mat')
load('MHW_start_end.mat')
time=datetime(1982,1,2):days(1):datetime(2023,12,30);

cd MHW_events\
data_info=dir('*.mat');
data_name={data_info.name};

Int=[];
Area=[];
Dur=[];
cT=[];

for n=1:numel(data_name)

    load(data_name{n})

    event_days=time(MHW_start_end(n,1)):time(MHW_start_end(n,2));

    Dur(n)=numel(event_days);
    cT{n}=mean(event_days);

    for t=1:size(MHW_event,3)

        Event_map=squeeze(MHW_event(:,:,t));
        I(t)=nanmean(Event_map(:));
        Event_area=area_mat;
        Event_area(isnan(Event_map))=NaN;
        A(t)=nansum(Event_area(:));

    end
    Int(n)=mean(I);
    Area(n)=mean(A);

    n
    I=[];
    A=[];

end
    
cT=[cT{:}];

%%
figure('Units','normalized','OuterPosition',[0 0 1 1])

subplot(3,1,1)
stem(cT,Int,'filled','LineStyle','-.','LineWidth',1.5,'Color',[0.64 0  0])
ylim([-0.07 max(Int)+0.07])
ylabel('a) MHW_{Intensity} (kelvin)')
grid on
set(gca,'fontsize',22)
set(gca,'fontname','Times')
xtickangle(90)
xticks(datetime(1982,1,1):calmonths(12):datetime(2023,1,1))

subplot(3,1,2)
stem(cT,Dur,'filled','LineStyle','-.','LineWidth',1.5,'Color',[0 0.44 0])
ylim([-8 max(Dur)+8])
ylabel('b) MHW_{Duration} (days)')
grid on
set(gca,'fontsize',22)
set(gca,'fontname','Times')
xtickangle(90)
xticks(datetime(1982,1,1):calmonths(12):datetime(2023,1,1))

subplot(3,1,3)
stem(cT,Area,'filled','LineStyle','-.','LineWidth',1.5,'Color',[0.64 0.44 0])
ylim([-3500 max(Area)+3500])
ylabel('c) MHW_{Area} (km^2)')        
grid on
set(gca,'fontsize',22)
set(gca,'fontname','Times')
xtickangle(90)
xticks(datetime(1982,1,1):calmonths(12):datetime(2023,1,1))

print(gcf,'../Figure 1new.png','-dpng','-r512')