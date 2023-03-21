%the name of saving.
%% 1. Setting
clear all
rand_method='permutation';%選擇統計方法要哪一個就會執行哪一個 %for rand selection , 'selection'; for rand permutation choose 'permutation';for comparing with 0, choose 'zero'.
Rn=300;%Randomization times.
test='nonparametric';%Hypothesis test:'parametric' or'nonparametric'

S.num_participant=17; %sub人數
S.method='logR'; %做一個轉換，不然超出上下屆
S.num_phase_bins=50; %切成幾個bin
S.theta_freq=6; 
S.desired_freq=20:80;
S.cmp='gray';
S.alpha=0.01;

S.theta_s=[num2str(S.theta_freq),'Hz'];
%% 2. Read data
[files_ph files]=read_data('E:\vstm\evstm6eeg\convert_to_spm\ph_amp\T\6Hz\data','mpph*.mat','no'); %Refer to function read_data

%% 3.Randomization for  data.
D=spm_eeg_load(files(1,:));
subj=size(files(:,1),1);
ch=D.nchannels;
freq=D.nfrequencies;
ph=D.nsamples;

Observed_data=zeros(subj,ch,freq,ph); %Preallocatae space for data.先製造零矩陣準備放置

switch test
    case 'parametric'
        disp('You choose parametric method!')%disp用於呈現矩陣或是文字表示選擇哪個就會出現哪串文字
    case 'nonparametric'
        t_test=zeros(Rn,ch,freq,ph); %Preallocate space for the result of t_test.
        result_p=zeros(ch,freq,ph); %The resulting p-value.
        result_H=zeros(ch,freq,ph); %The result of hypothesis test.
        disp('You choose nonparametric method!')
    otherwise
        disp('Something wrong with your hypothesis test setting.')
end
for n=1:subj
    D=spm_eeg_load(files(n,:));
    Observed_data(n,:,:,:)=mean(D(:,:,:,:)*0.5,4); %Averaging all conditions and make up the all load contdition.spm轉power*0.5（,4）trial
end

%%四種無母數的檢定方法
switch rand_method
    case 'zero'
        Surrogate_data=zeros(subj,ch,freq,ph); %假data，用來做統計
        if strcmp(test,'parametric')
            [H1 P1 CI1 STATS1]=ttest(Observed_data,Surrogate_data,S.alpha,[],1); %Compare with zero array.
            
            
            a=squeeze(H1(1,25,:,:));%去掉1的dimension 因為畫圖只能兩個dimension
            b=squeeze(H1(1,21,:,:));
            c=a&b; %Get the commonality of both channels.
            [success]=temp_draw_phase_freq(S.num_participant*c,S) %Draw the result.
            
        elseif strcmp(test,'nonparametric')
            Combined_data=cat(1,Observed_data,Surrogate_data); %cat是合併 Pool subjects and zeros. Then randomly sort them into two conditions.
            for n=1:Rn
                [Y sorting_ind]=sort(rand(1,34));%Sort the randomly generated vector to arrange trials. sorting_ind是排列後的順序
                Sorted_combined_data=Combined_data(sorting_ind,:,:,:); %Sort the data.
                Data1=Sorted_combined_data(1:subj,:,:,:); %First condition.混合完後分成前半跟後半兩組資料
                Data2=Sorted_combined_data(subj+1:end,:,:,:); %Second condition
                [Hn Pn CIn STATSn]=ttest(Data1,Data2,[],[],1);%做兩組資料的ttest
                t_test(n,:,:,:)=STATSn.tstat; %The t-value of the ttest.
            end
            sortied_t_test=sort(t_test,1); %Form the distribution.
            
            [H1 P1 CI1 STATS1]=ttest(Observed_data,Surrogate_data,[],[],1); %The Observed result.
            %Calculate the p-value point-by-point算磁頻圖上每個點的p-value.
            
            for i=1:ch
                for j=1:freq
                    for k=1:ph
                        ind=find(sortied_t_test(:,i,j,k)>STATS1.tstat(1,i,j,k),1);
                        if ~isempty(ind)
                            result_p(i,j,k)=(Rn-ind+1)/Rn;
                            result_H(i,j,k)=(result_p(i,j,k)<S.alpha);
                        else
                            
                            result_p(i,j,k)=0;
                            result_H(i,j,k)=1;
                        end
                    end
                end
            end
            
            a=squeeze(result_H(25,:,:));
            b=squeeze(result_H(21,:,:));
            c=a&b;
            [success]=temp_draw_phase_freq(S.num_participant*c,S)
        end
        
        
        
        
    case 'selection' %原本data隨便選，可重複
        Observed_data=permute(Observed_data,[3 4 1 2]); %Convenient for randomly shuffling.
        Surrogate_data=Observed_data;
        
        rand_ind=randi(freq*ph,[freq*ph,subj*Rn]);%Matrix with freq*phase-bins elements along the 1st dimension; subjects*Rn along the 2nd dimension.%2014-6-12
        
        %Weighting matrix like freq*ph*[0 1 2...;0 1 2....;...;...],so that can do
        %Rn times simulation each channel each time.
        weighting=0:subj*Rn-1; %Constructing the weighting matrix for the right order of permutation.%2014-6-12
        weighting=weighting(ones(1,freq*ph),:); %Construct the as many elements in the 1st dimension as samples in each phase-freq plot.%2014-6-12
        weighting=freq*ph*weighting; %Generating the right weighting values.%2014-6-12
        rand_ind=rand_ind+weighting; %Generating the correct random order.
        
        ch_sur=zeros(freq*ph,subj);%2014-6-12
        
        %2014-6-12
        
        for n=1:ch
            ch_ob=Observed_data(:,:,:,n);
            ch_ob=reshape(ch_ob,freq*ph,subj); %Each simulation
            ch_ob=repmat(ch_ob,[1 Rn]);%All simulation matrix
            ch_ob=ch_ob(rand_ind);%Random selection.
            for p=1:subj
                ch_sur(:,p)=mean(ch_ob(:,p:subj:end),2); %Average all simulation within each subject.
            end
            Surrogate_data(:,:,:,n)=reshape(ch_sur,[freq ph subj]);
        end
        
        Surrogate_data=permute(Surrogate_data,[3 4 1 2]); %Recover the dimension.
        Observed_data=permute(Observed_data,[3 4 1 2]);
        
        if strcmp(test,'parametric')
            [H1 P1 CI1 STATS1]=ttest(Observed_data,Surrogate_data,S.alpha,[],1);
            
            a=squeeze(H1(1,25,:,:));
            b=squeeze(H1(1,21,:,:));
            c=a&b;
            [success]=temp_draw_phase_freq(S.num_participant*c,S)
        elseif strcmp(test,'nonparametric')
            
            
            Combined_data=cat(1,Observed_data,Surrogate_data);
            
            %Refer to the method 'zero'.
            for n=1:Rn
                [Y sorting_ind]=sort(rand(1,34));
                Sorted_combined_data=Combined_data(sorting_ind,:,:,:);
                Data1=Sorted_combined_data(1:subj,:,:,:);
                Data2=Sorted_combined_data(subj+1:end,:,:,:);
                [Hn Pn CIn STATSn]=ttest(Data1,Data2,[],[],1);
                t_test(n,:,:,:)=STATSn.tstat;
            end
            
            [H1 P1 CI1 STATS1]=ttest(Observed_data,Surrogate_data,[],[],1);
            
            sortied_t_test=sort(t_test,1);
            
            for i=1:ch
                for j=1:freq
                    for k=1:ph
                        ind=find(sortied_t_test(:,i,j,k)>STATS1.tstat(1,i,j,k),1);
                        if ~isempty(ind)
                            result_p(i,j,k)=(Rn-ind+1)/Rn;
                            result_H(i,j,k)=(result_p(i,j,k)<S.alpha);
                        else
                            
                            result_p(i,j,k)=0;
                            result_H(i,j,k)=1;
                        end
                    end
                end
            end
            
            a=squeeze(result_H(25,:,:));
            b=squeeze(result_H(21,:,:));
            c=a&b;
            [success]=temp_draw_phase_freq(S.num_participant*c,S)
        end
        
    case 'permutation' %原本data隨便選但是不可重複選
%         defaultStream = RandStream.getDefaultStream;
%         savedState = defaultStream.State;
        
        stream=RandStream('mt19937ar','seed',110129); 
        
        Observed_data=permute(Observed_data,[3 4 1 2]); %Convenient for randomized permutation
        Surrogate_data=Observed_data;
        
        rand_ind=rand(stream,freq*ph,subj*Rn);%Matrix with freq*phase-bins elements along the 1st dimension; subjects*Rn along the 2nd dimension.%2014-6-12
        [unnecessity rand_ind]=sort(rand_ind);%Generate the real permutation matrix. No any number will appear twice in each column, i.e. each simulation.
        clear unnecessity
        %20140616check
        
        %Weighting matrix like freq*ph*[0 1 2...;0 1 2....;...;...],so that can do
        %Rn times simulation each channel each time.
        weighting=0:subj*Rn-1; %Constructing the weighting matrix for the right order of permutation.%2014-6-12
        weighting=weighting(ones(1,freq*ph),:); %Construct the as many elements in the 1st dimension as samples in each phase-freq plot.%2014-6-12
        weighting=freq*ph*weighting; %Generating the right weighting values.%2014-6-12
        rand_ind=rand_ind+weighting; %Generating the correct random order.
        
        ch_sur=zeros(freq*ph,subj);%2014-6-12
        
        
        %2014-6-12
        for n=1:ch
            ch_ob=Observed_data(:,:,:,n);
            ch_ob=reshape(ch_ob,freq*ph,subj); %Each simulation
            ch_ob=repmat(ch_ob,[1 Rn]);%All simulation matrix
            ch_ob=ch_ob(rand_ind);
            for p=1:subj
                ch_sur(:,p)=mean(ch_ob(:,p:subj:end),2);
            end
            Surrogate_data(:,:,:,n)=reshape(ch_sur,[freq ph subj]);
        end
        
        
        Surrogate_data=permute(Surrogate_data,[3 4 1 2]);
        Observed_data=permute(Observed_data,[3 4 1 2]);
        
        if strcmp(test,'parametric')
            [H1 P1 CI1 STATS1]=ttest(Observed_data,Surrogate_data,S.alpha,[],1);
            
            a=squeeze(H1(1,21,:,:));
            b=squeeze(H1(1,25,:,:));
            c=a&b;
            [success]=temp_draw_phase_freq(S.num_participant*c,S)
        elseif strcmp(test,'nonparametric')
            
            
            Combined_data=cat(1,Observed_data,Surrogate_data);
            for n=1:Rn
                [Y sorting_ind]=sort(rand(1,34));
                Sorted_combined_data=Combined_data(sorting_ind,:,:,:);
                Data1=Sorted_combined_data(1:subj,:,:,:);
                Data2=Sorted_combined_data(subj+1:end,:,:,:);
                [Hn Pn CIn STATSn]=ttest(Data1,Data2,[],[],1);
                t_test(n,:,:,:)=STATSn.tstat;
            end
            
            [H1 P1 CI1 STATS1]=ttest(Observed_data,Surrogate_data,[],[],1);
            
            sortied_t_test=sort(t_test,1);
            
            for i=1:ch
                for j=1:freq
                    for k=1:ph
                        ind=find(sortied_t_test(:,i,j,k)>STATS1.tstat(1,i,j,k),1);
                        if ~isempty(ind)
                            result_p(i,j,k)=(Rn-ind+1)/Rn;
                            result_H(i,j,k)=(result_p(i,j,k)<S.alpha); %0.01 maybe better
                        else
                            
                            result_p(i,j,k)=0;
                            result_H(i,j,k)=1;
                        end
                    end
                end
            end
            
            a=squeeze(result_H(25,:,:));
            b=squeeze(result_H(21,:,:));
            c=a&b;
            [success]=temp_draw_phase_freq(S.num_participant*c,S)
        end
    case 'columnwise'
                
        stream=RandStream('mt19937ar','seed',110129); 
        
        Observed_data=permute(Observed_data,[4 3 1 2]); %Convenient for randomized permutation
        Surrogate_data=Observed_data;
        
        rand_ind=rand(stream,ph,subj*Rn);%Matrix with freq*phase-bins elements along the 1st dimension; subjects*Rn along the 2nd dimension.%2014-6-12
        [unnecessity rand_ind]=sort(rand_ind);%Generate the real permutation matrix. No any number will appear twice in each column, i.e. each simulation.
        clear unnecessity
        rand_ind=repmat(rand_ind,[freq 1]);

        
        %Weighting matrix like freq*ph*[0 1 2...;0 1 2....;...;...],so that can do
        %Rn times simulation each channel each time.
        weighting=0:freq*subj*Rn-1; %Constructing the weighting matrix for the right order of permutation.%2014-6-12
        weighting=weighting(ones(1,ph),:); %Construct the as many elements in the 1st dimension as samples in each phase-freq plot.%2014-6-12
        weighting=ph*weighting; %Generating the right weighting values.%2014-6-12
        weighting=reshape(weighting,[freq*ph,subj*Rn]);
        %Waiting
        rand_ind=rand_ind+weighting; %Generating the correct random order.
        %Wrong!
       
        ch_sur=zeros(freq*ph,subj);%2014-6-12
        
        
        %2014-6-12
        for n=1:ch
            ch_ob=Observed_data(:,:,:,n);
            ch_ob=reshape(ch_ob,freq*ph,subj); %Each simulation
            ch_ob=repmat(ch_ob,[1 Rn]);%All simulation matrix
            ch_ob=ch_ob(rand_ind);
            for p=1:subj
                ch_sur(:,p)=mean(ch_ob(:,p:subj:end),2);
            end
            Surrogate_data(:,:,:,n)=reshape(ch_sur,[ph freq subj]);
        end
        
        
        Surrogate_data=permute(Surrogate_data,[3 4 2 1]);
        Observed_data=permute(Observed_data,[3 4 2 1]);
        
        if strcmp(test,'parametric')
            [H1 P1 CI1 STATS1]=ttest(Observed_data,Surrogate_data,S.alpha,[],1);
            
            a=squeeze(H1(1,21,:,:));
            b=squeeze(H1(1,25,:,:));
            c=a&b;
            [success]=temp_draw_phase_freq(S.num_participant*c,S)
        elseif strcmp(test,'nonparametric')
            
            
            Combined_data=cat(1,Observed_data,Surrogate_data);
            for n=1:Rn
                [Y sorting_ind]=sort(rand(1,34));
                Sorted_combined_data=Combined_data(sorting_ind,:,:,:);
                Data1=Sorted_combined_data(1:subj,:,:,:);
                Data2=Sorted_combined_data(subj+1:end,:,:,:);
                [Hn Pn CIn STATSn]=ttest(Data1,Data2,[],[],1);
                t_test(n,:,:,:)=STATSn.tstat;
            end
            
            [H1 P1 CI1 STATS1]=ttest(Observed_data,Surrogate_data,[],[],1);
            
            sortied_t_test=sort(t_test,1);
            
            for i=1:ch
                for j=1:freq
                    for k=1:ph
                        ind=find(sortied_t_test(:,i,j,k)>STATS1.tstat(1,i,j,k),1);
                        if ~isempty(ind)
                            result_p(i,j,k)=(Rn-ind+1)/Rn;
                            result_H(i,j,k)=(result_p(i,j,k)<S.alpha); %0.01 maybe better
                        else
                            
                            result_p(i,j,k)=0;
                            result_H(i,j,k)=1;
                        end
                    end
                end
            end
            
            a=squeeze(result_H(25,:,:));
            b=squeeze(result_H(21,:,:));
            c=a&b;
            [success]=temp_draw_phase_freq(S.num_participant*c,S)
        end
    otherwise
        disp('Wrong randomization method!')
        
end
