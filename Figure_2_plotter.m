clc
clear

filename='MHW_events\NCfiles\BALMHW_event_182.nc';
supp='MHW_events\NCfiles\BALMHW_supp.nc';
ncdisp(filename)
%%
lon=ncread(filename,'longitude');
lat=ncread(filename,'latitude');
BALarea=ncread(supp,'BALarea');

time=datetime(1970,1,1,0,0,0)+seconds(ncread(filename,'time'));
Event_map=ncread(filename,'MHW_int_maps');
I=ncread(filename,'MHW_int_ts');
A=ncread(filename,'MHW_area_ts');
%%
Event_map(isnan(Event_map))=0;
BALarea(~isnan(BALarea))=1;
Event_map=Event_map.*BALarea;

[maxValue, linearIndex] = max(Event_map(:)); % Find the maximum value and its linear index

% Convert the linear index to subscripts (i, j, k)
[i, j, k] = ind2sub(size(Event_map), linearIndex);

MHW_samps(:,:,1)=squeeze(Event_map(:,:,7));
MHW_samps(:,:,2)=squeeze(Event_map(:,:,284/2));
MHW_samps(:,:,3)=squeeze(Event_map(:,:,k));
MHW_samps(:,:,4)=squeeze(Event_map(:,:,end-7));

xp=linspace(0.04,0.71,4);
yp=0.5;
wp=0.22;
hp=0.47;

tp={['a) ',datestr(time(7),'yyyy mmm dd')];['b) ',datestr(time(284/2),'yyyy mmm dd')];['c) ',datestr(time(k),'yyyy mmm dd')];['d) ',datestr(time(end-7),'yyyy mmm dd')]};

 ytl={'55^{\circ}N';'57^{\circ}N';'59^{\circ}N';'61^{\circ}N';'63^{\circ}N';'65^{\circ}N'};
 xtl={'10^{\circ}E';'14^{\circ}E';'18^{\circ}E';'22^{\circ}E';'26^{\circ}E';'30^{\circ}E'};





figure('Units','normalized','OuterPosition',[0 0 1 1])

for p=1:4
    subplot(2,4,p)
        pcolor(lon,lat,MHW_samps(:,:,p)')
        shading flat
        borders('countries','k')
        %caxis([0 max(MHW_samps(:))])
        caxis([0 10])
        xticks(10:4:30)
        yticks(55:2:65)
        colormap('turbo')
        grid on
        set(gca,'Layer','top')
        set(gca,'LineWidth',2)
        title(tp{p})

        if p~=1

            yticklabels({' '})

        else
            yticklabels(ytl)
        end
        xticklabels(xtl)
        xtickangle(90)

        set(gca,'Position',[xp(p) yp wp hp])

        if p==4

            c=colorbar;
            c.Label.String='MHW_{intensity} (kelvin)';

            set(c,'Position',[xp(4)+wp+0.015 yp 0.005 hp])

            c.FontName='Times';
            c.FontSize=22;
            c.FontWeight='bold';

        end

        set(gca,'FontWeight','bold')
        set(gca,'FontSize',20)
        set(gca,'FontName','Times')
end



subplot(2,4,5)
set(gca,'Position',[xp(1) 0.06 xp(4)+wp-xp(1) 0.31])
% First set of data (left y-axis)
yyaxis left
plot(time, I, ':o', 'Color', [0.64 0  0], 'LineWidth', 1.8, ...
    'MarkerSize', 4, 'MarkerFaceColor', [0.64 0  0])
ylabel('MHW_{Intensity} (kelvin)')

ylim([0 6])
yticks(0:1.5:6)

ax = gca; % Get the current axes handle
ax.YColor =[0.64 0  0]; % Set the left y-axis color
ax.LineWidth = 3; % Make the y-axis line thicker


% Second set of data (right y-axis)
yyaxis right
plot(time, A, '--*', 'Color', [0.64 0.44  0], 'LineWidth', 1.4, ...
    'MarkerSize', 6, 'MarkerFaceColor', [0.64 0.44  0])
ax.YColor = [0.64 0.44  0]; % Set the right y-axis color
ax.LineWidth = 3; % Make the y-axis line thicker

% Common x-axis label
ylabel('MHW_{Area} (km^2)')
%Percentage Agreement of SOM Clustering on Predicted Data with Original SOM-Trained Clusters

ylim([0 4e5])
yticks(0:1e5:4e5)

% Title for the plot
% Optional grid and legend
grid on
%legend('', 'perc_acc', 'Location', 'best')

%xticks(1:gs)
%xlim([0 gs+1])

grid on

xlabel('Time (daily)')

set(gca,'fontsize',20)
set(gca,'fontname','times')
title('d) Temporal distribution of daily MHW_{Area} and mean MHW_{Intensity}');
print(gcf,'Figure 2new.png','-dpng','-r512')