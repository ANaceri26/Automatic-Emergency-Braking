function f=aeb_plot_comparison(on,off)
f=figure('Name','AEB on versus off','Color','w','Position',[100 100 1100 650]);
tl=tiledlayout(f,2,2,'TileSpacing','compact');
title(tl,['AEB experiment: ' on.config.name],'FontSize',18);
nexttile; plot(on.time,on.gap,'LineWidth',1.8); hold on;
plot(off.time,off.gap,'--','LineWidth',1.8); yline(0,':r');
title('Bumper gap'); ylabel('m'); xlabel('Time (s)'); grid on; legend('AEB on','AEB off');
nexttile; plot(on.time,on.state(:,2)*3.6,'LineWidth',1.8); hold on;
plot(off.time,off.state(:,2)*3.6,'--','LineWidth',1.8);
plot(on.time,on.state(:,4)*3.6,':','LineWidth',1.8);
title('Vehicle speeds'); ylabel('km/h'); xlabel('Time (s)'); grid on; legend('AEB on','AEB off','Lead');
nexttile; plot(on.time,[on.control(:,1) on.state(:,5)],'LineWidth',1.6);
title('Brake response with AEB'); ylabel('m/s^2'); xlabel('Time (s)'); grid on; legend('Requested','Actual');
nexttile; axis off;
text(0,1,sprintf(['AEB ON\nCollision: %s\nMinimum gap: %.2f m\nImpact closing speed: %.1f km/h\n\n'...
 'AEB OFF\nCollision: %s\nMinimum gap: %.2f m\nImpact closing speed: %.1f km/h\n\n'...
 'Runs stop at first detected overlap.\nResults describe this simplified simulation only.'],...
 string(on.metrics.collision),on.metrics.minimumGap,on.metrics.impactSpeed*3.6,...
 string(off.metrics.collision),off.metrics.minimumGap,off.metrics.impactSpeed*3.6),...
 'VerticalAlignment','top','FontSize',11);
end
