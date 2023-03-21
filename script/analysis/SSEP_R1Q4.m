%% new SSEP analysis for R1Q4
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/SSEP/AM4b/rSSEP_aIC_AM4b_no0pad_5s_N20.mat')
load('/Volumes/TOSHIBA/Research/Imagined_beats/real_exp/results/Main_task/SSEP/AM4b/rSSEP_mIC_AM4b_no0pad_5s_N20.mat')

%% substracting binary 1.2 Hz - ternary 1.2 Hz; ternary 0.8 Hz - binary 0.8 Hz
% Prediction: no effect in BL, effects in PM, IM, TAP
bmeterf = find(freq == 1.2); 
tmeterf = find(freq == 0.8);

% aIC
Hz1_2 = squeeze(rSSEP_aIC(:,1,:,bmeterf) - rSSEP_aIC(:,2,:,bmeterf));
Hz0_8 = squeeze(rSSEP_aIC(:,2,:,tmeterf) - rSSEP_aIC(:,1,:,tmeterf));

% mIC
Hz1_2 = squeeze(rSSEP_mIC(:,1,:,bmeterf) - rSSEP_mIC(:,2,:,bmeterf));
Hz0_8 = squeeze(rSSEP_mIC(:,2,:,tmeterf) - rSSEP_mIC(:,1,:,tmeterf));

%% stats
[h,p,~,stats] = ttest(Hz1_2)
[h,p,~,stats] = ttest(Hz0_8)
