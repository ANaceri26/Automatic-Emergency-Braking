function fig=aeb_lab
%AEB_LAB Small interactive desktop lab. No App Designer/toolboxes required.
root=fileparts(mfilename('fullpath'));
fig=figure('Name','AEB Lab | MATLAB R2024a','NumberTitle','off',...
 'Color',[0.96 0.97 0.99],'Position',[80 80 1160 740],'InvertHardcopy','off');
names={'Dry road','Wet road','Ice: physical limit','Long sensor delay',...
 'Sensor outage','Stopped vehicle','Safe following','Cruise + ACC'};
keys={'dry','wet','ice','delay','dropout','stationary','safe','acc'};
uicontrol(fig,'Style','text','String','AUTOMATIC EMERGENCY BRAKING LAB',...
 'Units','normalized','Position',[.035 .936 .65 .04],'FontSize',17,...
 'FontWeight','bold','HorizontalAlignment','left','BackgroundColor',fig.Color);
picker=uicontrol(fig,'Style','popupmenu','String',names,'Units','normalized',...
 'Position',[.035 .877 .21 .044],'Callback',@(~,~)runCase(false));
button('Run + animate',[.26 .877 .13 .045],@(~,~)runCase(true));
button('Compare AEB off',[.40 .877 .14 .045],@(~,~)compare);
button('Run all tests',[.55 .877 .115 .045],@(~,~)tests);
button('Export RoadRunner',[.68 .877 .15 .045],@(~,~)rrExport);
status=uicontrol(fig,'Style','text','String','','Units','normalized',...
 'Position',[.035 .818 .93 .042],'FontSize',11,'HorizontalAlignment','left',...
 'BackgroundColor',fig.Color);
road=axes(fig,'Position',[.07 .59 .88 .20]);
axSpeed=axes(fig,'Position',[.07 .33 .40 .20]);
axGap=axes(fig,'Position',[.56 .33 .39 .20]);
axBrake=axes(fig,'Position',[.07 .075 .40 .18]);
axTTC=axes(fig,'Position',[.56 .075 .39 .18]);
busy=false; result=[];
runCase(false);
    function button(label,pos,callback)
        uicontrol(fig,'Style','pushbutton','String',label,'Units','normalized',...
         'Position',pos,'Callback',callback,'FontSize',10);
    end
    function runCase(animate)
        if busy, return; end
        busy=true; clean=onCleanup(@release);
        c=aeb_config(keys{picker.Value}); result=aeb_simulate(c); r=result;
        cla(axSpeed); plot(axSpeed,r.time,r.state(:,2:2:4)*3.6,'LineWidth',1.5);
        decorate(axSpeed,'Speed','km/h'); legend(axSpeed,{'Your car','Lead car'},'Location','best');
        cla(axGap); plot(axGap,r.time,[r.gap r.control(:,5)],'LineWidth',1.4);
        hold(axGap,'on'); plot(axGap,r.time,r.control(:,4),'--','LineWidth',1.1); hold(axGap,'off');
        decorate(axGap,'Distance and braking threshold','m');
        legend(axGap,{'True gap','Estimated gap','Trigger gap'},'Location','best');
        cla(axBrake); plot(axBrake,r.time,[r.control(:,1) r.state(:,5)],'LineWidth',1.4);
        decorate(axBrake,'Requested and actual acceleration','m/s^2');
        legend(axBrake,{'Requested','Actual'},'Location','best');
        cla(axTTC); values=r.control(:,3); values(~isfinite(values))=NaN;
        plot(axTTC,r.time,values,'LineWidth',1.4); hold(axTTC,'on');
        yline(axTTC,c.ttcBrake,'--r','Brake threshold'); hold(axTTC,'off');
        decorate(axTTC,'Time to collision (constant-speed estimate)','s'); ylim(axTTC,[0 10]);
        verdict='NO COLLISION'; if r.metrics.collision, verdict='COLLISION'; end
        status.String=sprintf('%s | minimum gap %.2f m | impact closing speed %.1f km/h | compute %.3f s',...
         verdict,r.metrics.minimumGap,r.metrics.impactSpeed*3.6,r.computeSeconds);
        cla(road); hold(road,'on');
        road.Color=[.16 .19 .23]; road.YColor=[.25 .3 .35];
        ylim(road,[-4 4]); road.YTick=[]; xlabel(road,'Position along the road (m)');
        yline(road,-1.8,'w-'); yline(road,1.8,'w-');
        blue=[.12 .48 .90]; orange=[.95 .48 .12];
        e=rectangle(road,'Position',[0 -0.85 c.carLength 1.7],'FaceColor',blue,'EdgeColor','none','Curvature',.16);
        l=rectangle(road,'Position',[0 -0.85 c.carLength 1.7],'FaceColor',orange,'EdgeColor','none','Curvature',.16);
        label=text(road,0,2.65,'','Color',[.95 .97 1],'FontWeight','bold');
        hold(road,'off');
        frames=numel(r.time);
        if animate, frames=unique([1:5:numel(r.time),numel(r.time)]); end
        modeNames={'CRUISE / ACC','WARNING','EMERGENCY BRAKE','STOPPED','SENSOR FAULT'};
        for k=frames
            if ~isgraphics(fig), return; end
            xe=r.state(k,1); xl=r.state(k,3);
            e.Position=[xe-c.carLength/2 -0.85 c.carLength 1.7];
            l.Position=[xl-c.carLength/2 -0.85 c.carLength 1.7];
            xlim(road,[xe-15 xe+max(65,r.gap(k)+15)]);
            label.Position=[xe-12 2.65 0];
            label.String=sprintf('t = %.1f s   |   %s   |   gap %.1f m',r.time(k),modeNames{r.control(k,2)+1},r.gap(k));
            drawnow;
            if animate, pause(.035); end % Playback is deliberately faster than real time.
        end
        clear clean
    end
    function release, busy=false; end
    function compare
        if busy, return; end
        c=aeb_config(keys{picker.Value}); on=aeb_simulate(c);
        c.aebEnabled=false; off=aeb_simulate(c); aeb_plot_comparison(on,off);
    end
    function tests
        if busy, return; end
        status.String='Running numerical tests...'; drawnow;
        try, aeb_run_tests; status.String='Tests passed. Details are in the Command Window.';
        catch ex, status.String=['Test failed: ' ex.message]; rethrow(ex); end
    end
    function rrExport
        if busy || isempty(result), return; end
        folder=aeb_export_roadrunner(result);
        status.String=['RoadRunner replay exported: ' folder];
    end
end
function decorate(ax,heading,units)
title(ax,heading,'FontSize',10); ylabel(ax,units); xlabel(ax,'Time (s)'); grid(ax,'on');
end
