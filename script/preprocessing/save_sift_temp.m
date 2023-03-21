%%
filepath = '/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/sifts'; 
filename1 = strcat(ALLEEG(1).setname,'_sift')
filename2 = strcat(ALLEEG(2).setname,'_sift')
filename3 = strcat(ALLEEG(3).setname,'_sift')
filename4 = strcat(ALLEEG(4).setname,'_sift')
filename5 = strcat(ALLEEG(5).setname,'_sift')
filename6 = strcat(ALLEEG(6).setname,'_sift')

ALLEEG(1) = pop_saveset(ALLEEG(1),'filename',filename1,'filepath',filepath);
ALLEEG(2) = pop_saveset(ALLEEG(2),'filename',filename2,'filepath',filepath);
ALLEEG(3) = pop_saveset(ALLEEG(3),'filename',filename3,'filepath',filepath);
ALLEEG(4) = pop_saveset(ALLEEG(4),'filename',filename4,'filepath',filepath);
ALLEEG(5) = pop_saveset(ALLEEG(5),'filename',filename5,'filepath',filepath);
ALLEEG(6) = pop_saveset(ALLEEG(6),'filename',filename6,'filepath',filepath);
