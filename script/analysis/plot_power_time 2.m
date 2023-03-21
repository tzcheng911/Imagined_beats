load('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sifts/maflow.mat')
load('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sifts/amflow.mat')
load('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sifts/time_idx.mat')
%%
%beta = 
for n = 1:6
sub_mean_dBL(n,:) = mean(squeeze(maflow(n,1,8:12,:)),1);
end

for n = 1:6
sub_mean_dIM(n,:) = mean(squeeze(maflow(n,2,8:12,:)),1);
end

for n = 1:6
sub_mean_dSBL(n,:) = mean(squeeze(maflow(n,3,8:12,:)),1);
end

figure;
subplot(3,1,1);
plot (sub_mean_dBL')
hold on 
yl = ylim;
plot([time_idx(1) time_idx(1)],[yl(1) yl(2)],'k--')
plot([time_idx(3) time_idx(3)],[yl(1) yl(2)],'k--')
plot([time_idx(5) time_idx(5)],[yl(1) yl(2)],'k--')
plot([time_idx(7) time_idx(7)],[yl(1) yl(2)],'k--')
plot([time_idx(9) time_idx(9)],[yl(1) yl(2)],'k--')
plot([time_idx(11) time_idx(11)],[yl(1) yl(2)],'k--')
title('DupleBL')
legend('s01','s02','s03','s04','s05','s06')

subplot(3,1,2);
plot (sub_mean_dIM')
hold on 
yl = ylim;
plot([time_idx(1) time_idx(1)],[yl(1) yl(2)],'k--')
plot([time_idx(3) time_idx(3)],[yl(1) yl(2)],'k--')
plot([time_idx(5) time_idx(5)],[yl(1) yl(2)],'k--')
plot([time_idx(7) time_idx(7)],[yl(1) yl(2)],'k--')
plot([time_idx(9) time_idx(9)],[yl(1) yl(2)],'k--')
plot([time_idx(11) time_idx(11)],[yl(1) yl(2)],'k--')
title('DupleIM')
legend('s01','s02','s03','s04','s05','s06')

subplot(3,1,3);
plot (sub_mean_dSBL')
hold on 
yl = ylim;
plot([time_idx(1) time_idx(1)],[yl(1) yl(2)],'k--')
plot([time_idx(3) time_idx(3)],[yl(1) yl(2)],'k--')
plot([time_idx(5) time_idx(5)],[yl(1) yl(2)],'k--')
plot([time_idx(7) time_idx(7)],[yl(1) yl(2)],'k--')
plot([time_idx(9) time_idx(9)],[yl(1) yl(2)],'k--')
plot([time_idx(11) time_idx(11)],[yl(1) yl(2)],'k--')
title('DupleSBL')
legend('s01','s02','s03','s04','s05','s06')
