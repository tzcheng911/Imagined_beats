clear all
clc
cd 'D:\TH\analysis\neuroscan\regression\rt_ang';
pwm_input_reg;
%%
for subject=1:size(input_corr_fisherz,1);
%load(input_corr_fisherz(subject,:));
corrdata=spm_eeg_load(input_corr_fisherz(subject,:));

fcorr=zeros(32,35,625);

for k=1:32
    for i=1:35
        for j=1:625
            corrdata(k,i,j,1)=fisherz(corrdata(k,i,j,1));
        end
    end
end    

disp(sprintf('SUB = %d , K = %d , I = %d , J= %d',subject,k,i,j));
end
