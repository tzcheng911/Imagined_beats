FCZs = zeros(length(ALLEEG),EEG.pnts);
for i = 1:length(ALLEEG)
    FCZs(i,:) = mean(mean(ALLEEG(i).data(25:30,:,:)),3);
end
figure;
plot(EEG.times,FCZs','LineWidth',2)
xlim([-300 400])
gridy([0])
gridx([0])

figure;
plot(EEG.times,mean(FCZs),'LineWidth',2)
xlim([-300 400])
gridy([0])
gridx([0])