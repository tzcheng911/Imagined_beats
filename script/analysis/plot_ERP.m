%% tap data 
% timpoto
figure; 
subplot(3,1,1);
pop_timtopo(ALLEEG(1), [-300.7812      300], [100 200], 'ERP data and scalp maps of localizer2_tap1_e');
subplot(3,1,2);
pop_timtopo(ALLEEG(2), [-300.7812      300], [100 200], 'ERP data and scalp maps of localizer3_tap1_e');
subplot(3,1,3);
pop_timtopo(ALLEEG(3), [-300.7812      300], [100 200], 'ERP data and scalp maps of localizer4_tap1_e');

% envtopo 
figure; 
subplot(3,1,1);
pop_envtopo(ALLEEG(1), [-300.7812      300] ,'limcontrib',[0 200],'compsplot',[7],'electrodes','off');
subplot(3,1,2);
pop_envtopo(ALLEEG(2), [-300.7812      300] ,'limcontrib',[0 200],'compsplot',[7],'electrodes','off');
subplot(3,1,3);
pop_envtopo(ALLEEG(3), [-300.7812      300] ,'limcontrib',[0 200],'compsplot',[7],'electrodes','off');

%% rd listen data 
% timpoto
figure; 
subplot(3,1,1);
pop_timtopo(ALLEEG(1), [-300.7812      300], [100 200], 'ERP data and scalp maps of localizer2_rd2_e');
subplot(3,1,2);
pop_timtopo(ALLEEG(3), [-300.7812      300], [100 200], 'ERP data and scalp maps of localizer3_rd2_e');
subplot(3,1,3);
pop_timtopo(ALLEEG(5), [-300.7812      300], [100 200], 'ERP data and scalp maps of localizer4_rd2_e');

figure; 
subplot(3,1,1);
pop_timtopo(ALLEEG(2), [-300.7812      300], [100 200], 'ERP data and scalp maps of localizer2_rd4_e');
subplot(3,1,2);
pop_timtopo(ALLEEG(4), [-300.7812      300], [100 200], 'ERP data and scalp maps of localizer3_rd4_e');
subplot(3,1,3);
pop_timtopo(ALLEEG(6), [-300.7812      300], [100 200], 'ERP data and scalp maps of localizer4_rd4_e');

% envtopo 
figure; 
subplot(3,1,1);
pop_envtopo(ALLEEG(1), [-300.7812      300] ,'limcontrib',[-100 200],'compsplot',[7],'electrodes','off');
subplot(3,1,2);
pop_envtopo(ALLEEG(3), [-300.7812      300] ,'limcontrib',[-100 200],'compsplot',[7],'electrodes','off');
subplot(3,1,3);
pop_envtopo(ALLEEG(5), [-300.7812      300] ,'limcontrib',[-100 200],'compsplot',[7],'electrodes','off');

figure; 
subplot(3,1,1);
pop_envtopo(ALLEEG(2), [-300.7812      300] ,'limcontrib',[-100 200],'compsplot',[7],'electrodes','off');
subplot(3,1,2);
pop_envtopo(ALLEEG(4), [-300.7812      300] ,'limcontrib',[-100 200],'compsplot',[7],'electrodes','off');
subplot(3,1,3);
pop_envtopo(ALLEEG(6), [-300.7812      300] ,'limcontrib',[-100 200],'compsplot',[7],'electrodes','off');

figure; 
pop_newtimef(ALLEEG(2), 0, 2, [-301  496], [3         0.5] , 'topovec', EEG.icawinv(:,2),...
    'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', ['IC 2'], 'baseline',[0],...
    'plotphase', 'off', 'padratio', 1, 'winsize', 77);

figure;
pop_newtimef(ALLEEG(6), 0, 6, [-301  496], [3         0.5] , 'topovec', EEG.icawinv(:,6),...
    'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', ['IC 6'], 'baseline',[0],...
    'plotphase', 'off', 'padratio', 1, 'winsize', 77);

