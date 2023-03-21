%% fft(sounds)
[y,fs] = audioread('/Users/tzu-hancheng/Google_Drive/Research/Imaginedbeat/20190118exp/duple.wav');
y = y(:,1);
[Y,f] = calc_fft(y,1/fs,60*fs);
figure;plot(f,2*abs(Y));
xlim([0 5])
gridx([1.2,2.4])

[y,fs] = audioread('/Users/tzu-hancheng/Google_Drive/Research/Imaginedbeat/20190118exp/triple.wav');
y = y(:,1);
[Y,f] = calc_fft(y,1/fs);
figure;plot(f,2*abs(Y));
xlim([0 5])
gridx([0.8,2.4])

%% fft(EEG) 
clear 
close all
%cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/tap_brain/rawEEG')
cd('/Volumes/TOSHIBA EXT/Research/Imagined_beats/real_exp/tap_brain/peakcontrast')

load('f');
load('Duple_mICs_EEG');
load('Triple_mICs_EEG');
load('Duple_aICs_EEG');
load('Triple_aICs_EEG');

Duple_mICs_EEG = Duple_mICs_EEG([1,2,4,5,6,7,9],:,:);
Triple_mICs_EEG = Triple_mICs_EEG([1,2,4,5,6,7,9],:,:);
Duple_aICs_EEG = Duple_aICs_EEG([1,2,4,5,6,7,9],:,:);
Triple_aICs_EEG = Triple_aICs_EEG([1,2,4,5,6,7,9],:,:);

%%
figure;plot(f,squeeze(mean(Duple_aICs_EEG,1))','LineWidth',2);
%title('Duple-aICs')
xlim([0.5 5])
ylim([0 2e-3])
set(gca,'FontSize',18)
gridx([0.8,1.2,1.6,2.4]);legend('Control','Physical Beat','Imagined Beat');

figure;plot(f,squeeze(mean(Duple_mICs_EEG,1))','LineWidth',2);
%title('Duple-mICs')
xlim([0.5 5])
ylim([0 2e-3])
set(gca,'FontSize',18)
gridx([0.8,1.2,1.6,2.4]);legend('Control','Physical Beat','Imagined Beat');

figure;plot(f,squeeze(mean(Triple_aICs_EEG,1))','LineWidth',2);
%title('Triple-aICs')
xlim([0.5 5])
ylim([0 2e-3])
set(gca,'FontSize',18)
gridx([0.8,1.2,1.6,2.4]);legend('Control','Physical Beat','Imagined Beat');

figure;plot(f,squeeze(mean(Triple_mICs_EEG,1))','LineWidth',2);
%title('Triple-mICs')
xlim([0.5 5])
ylim([0 2e-3])
set(gca,'FontSize',18)
gridx([0.8,1.2,1.6,2.4]);legend('Control','Physical Beat','Imagined Beat');

%% plot pvalue one sample ttest across time
Duple_mICs_EEG(Duple_mICs_EEG<0) = 0;
for ncond = 1:3
    for nt = 1:size(f,2)
        [H,p] = ttest(Duple_mICs_EEG(:,ncond,nt));
        pval(ncond,nt) = p;
    end
end
figure;plot(f,pval','LineWidth',2);title('p-value of Triple mICs EEG')
gridy([0.05]);gridx([0.8,1.2,1.6,2.4]);legend('BL','SBL','IM');

%%
df = input('df:','s');
df = str2num(df);
beat = input('beat:','s');
beat = str2num(beat);

ind1 = find(f == (beat-df));
ind2 = find(f == (beat+df));

for nsubj = 1:size(Duple_aICs_EEG,1)
    for ncond = 1:size(Duple_aICs_EEG,2)
        Duple_aICs_EEG_amp(nsubj,ncond) = max(Duple_aICs_EEG(nsubj,ncond,ind1:ind2));
    end
end

for nsubj = 1:size(Duple_aICs_EEG,1)
    for ncond = 1:size(Duple_aICs_EEG,2)
        Duple_mICs_EEG_amp(nsubj,ncond) = max(Duple_mICs_EEG(nsubj,ncond,ind1:ind2));
    end
end

for nsubj = 1:size(Duple_aICs_EEG,1)
    for ncond = 1:size(Duple_aICs_EEG,2)
        Triple_aICs_EEG_amp(nsubj,ncond) = max(Triple_aICs_EEG(nsubj,ncond,ind1:ind2));
    end
end

for nsubj = 1:size(Duple_aICs_EEG,1)
    for ncond = 1:size(Duple_aICs_EEG,2)
        Triple_mICs_EEG_amp(nsubj,ncond) = max(Triple_mICs_EEG(nsubj,ncond,ind1:ind2));
    end
end
maxpow = [Duple_aICs_EEG_amp,Duple_mICs_EEG_amp,Triple_aICs_EEG_amp,Triple_mICs_EEG_amp];

%% Some analysis: one sample ttest
for n = 1:16
    [H,P] = ttest(maxpow(:,n));
    pval(n) = P;
end

for ncond = 1:4
    for nf = 1:270
        [H,P] = ttest(squeeze(Duple_aICs_EEG(:,ncond,nf)));
        pval(ncond,nf) = P;
        if P<=0.05
           psig(ncond,nf,nt) = 1
        else 
           psig(ncond,nf) = 0 
        end
    end
end
figure;plot(f,pval')
gridy(0.05)
legend

