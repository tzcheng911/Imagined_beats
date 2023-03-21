%% for correlation RT
clear all
clc
cd 'D:\TH\analysis\EXP2\rt';
pwm_input_corr;
%%
for subject=1:size(input_rt,1);

load(input_rt(subject,:));
tfdata=spm_eeg_load(input_rt(subject,:));
%copytfdata(:,:,:,:)=tfdata(:,:,:,:);

%Retrieve RT from D
RT = zeros(1, length(D.trials));

for i=1:length(D.trials)
    Num(1,i) = D.trials(1,i).events;
    %Num(1,i)  = D.trials(1,i);
    %Num1 = Num.events;
    RT(i) = str2num(Num(1,i).value);  
end
RT=(RT)';

%correlation
for k=1:32
    for i=1:35
        for j=1:625
        power=squeeze(tfdata(k,i,j,:));
        tempcoef=corrcoef(RT,power);
        coef(k,i,j)=fisherz(tempcoef(1,2));
        end
    end
    disp(sprintf('SUB = %d , K = %d , I = %d , J= %d',subject,k,i,j));
end

extendcoef=zeros(32,35,625,length(D.trials));

for i=1:length(D.trials)
extendcoef(:,:,:,i)=coef;    
end

tfdata(:,:,:,:)=extendcoef(:,:,:,:);

end

%%  ¦r¦êÂà¬°¼Æ¦r
str = ['result' num2str(1)];

%% for correlation RT_ang
clear all
clc
cd 'D:\TH\EXP2\rt_ang';
pwm_input_corr;
%%
for subject=1:size(input_rt_ang,1);

load(input_rt_ang(subject,:));
tfdata=spm_eeg_load(input_rt_ang(subject,:));
%copytfdata(:,:,:,:)=tfdata(:,:,:,:);

%Retrieve RT from D
RT = zeros(1, length(D.trials));

for i=1:length(D.trials)
    Num(1,i) = D.trials(1,i).events;
    %Num(1,i)  = D.trials(1,i);
    %Num1 = Num.events;
    RT(i) = str2num(Num(1,i).value);  
end
RT=(RT)';

for k=1:32
    for i=1:35
        for j=1:625
        power=squeeze(tfdata(k,i,j,:));
        tempcoef=corrcoef(RT,power);
        coef(k,i,j)=fisherz(tempcoef(1,2));
        end
    end
     disp(sprintf('SUB = %d , K = %d , I = %d , J= %d',subject,k,i,j));
end

extendcoef=zeros(32,35,625,length(D.trials));

for i=1:length(D.trials)
extendcoef(:,:,:,i)=coef;    
end

tfdata(:,:,:,:)=extendcoef(:,:,:,:);

end

%% correlation coef average

pwm_input_corr

input_rt_ang=[ 
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s01_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s02_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s03_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s04_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s05_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s06_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s08_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s09_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s10_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s11_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s12_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s13_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s14_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s15_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s16_pwm_b'
    'D:\TH\corr\rt\LogR\rtf_rrdrspm8_s17_pwm_b'];

    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s01_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s02_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s03_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s04_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s05_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s06_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s08_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s09_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s10_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s11_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s12_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s13_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s14_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s15_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s16_pwm_b'
    'D:\TH\corr\rt\logg\rtf_rrdrspm8_s17_pwm_b'   
    
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s01_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s02_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s03_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s04_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s05_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s06_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s08_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s09_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s10_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s11_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s12_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s13_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s14_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s15_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s16_pwm_b'
    'D:\TH\corr\rt\diff\rtf_rrdrspm8_s17_pwm_b'

    'D:\TH\corr\rt\raww\tf_rrdrspm8_s01_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s02_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s03_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s04_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s05_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s06_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s08_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s09_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s10_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s11_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s12_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s13_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s14_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s15_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s16_pwm_b'
    'D:\TH\corr\rt\raww\tf_rrdrspm8_s17_pwm_b'
    ];
h = waitbar(128,'averaging power');
for isubject=1:128
    waitbar(isubject/128,h);
    
    S = [];
    S.D = input_rt_ang(isubject,:);
    S.circularise = 0;
    S.robust = false;
    D = spm_eeg_average_TF(S);
 
end

close(h);
clear all;
