clear all;
clc;
    
spm('defaults', 'eeg');

source_directory = 'D:\dataset\for_GLM\random\raw';

subject_id = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24'};

ans2 = zeros(32, 35, 625, 24);
i = 0;
for sub_directory = subject_id
    
    disp(sub_directory{1});
    i = i + 1;

    % Set the file path.
    filename1 = ['tf_rdrspm8_s' sub_directory{1} '2_br_b'];
    newfile_name = [sub_directory{1} '_b_analysis2-rewrite'];
    if not(exist(fullfile(source_directory, [filename1 '.mat']), 'file')==2)
        disp(['The file ' sub_directory{1} ' is not found.']);
    end
%     S
    S.D = fullfile(source_directory, [filename1 '.mat']);
    S.newname = fullfile(source_directory, [newfile_name '.mat']);
    spm_eeg_copy(S);
    ft_data = spm_eeg_load(fullfile(source_directory, [newfile_name '.mat']));
    
    % Get all channels' labels.
    all_channellabels = chanlabels(ft_data);
    channels_count = size(all_channellabels, 2);
    
    % Get all frequencies' labels.
    all_frequencies = frequencies(ft_data);
    frequencies_count = size(all_frequencies, 2);
    
    % Get all behavioral value.
    behavior_value = cellfun(@str2num, reshape(extractfield(cell2mat(events(ft_data)), 'value'), size(events(ft_data), 2), 1));
    behavior_count = size(behavior_value, 2);
    
    % Get all difficulty conditions.
    difficulty_value = [];
    temp_difficulty_value = cellfun(@str2num,conditions(ft_data),'un',0)';
    difficulty_count = size(temp_difficulty_value, 1);
    for temp = 1:difficulty_count
        difficulty_value = [difficulty_value; temp_difficulty_value{temp,1}];
    end
    
    % Get total the number of time index.
    max_time_index = nsamples(ft_data);
    
    % Initialize the result's variable.
    ft_data_clone = ft_data;

    for c = 1:channels_count
        for f = 1:frequencies_count
            for t = 1:max_time_index
                disp(['Channel: ' int2str(c) ' - Frequency: ' int2str(f) ' - Time: ' int2str(t)]);
                power = squeeze(ft_data_clone(c, f, t, :));
                difficulty = squeeze(difficulty_value);
                ans = glmfit(zscore(difficulty), zscore(power), 'normal');
                ft_data(c, f, t, 1) = ans(2);
            end
        end
    end
    
    ans2(:,:,:,i) = ft_data(:, :, :, 1);
    
    disp('Done.');
end

filename1 = 'tf_rdrspm8_s012_br_b';
newfile_name = 'whole_b_analysis2-rewrite';
S.D = fullfile(source_directory, [filename1 '.mat']);
S.newname = fullfile(source_directory, [newfile_name '.mat']);
spm_eeg_copy(S);
ft_data = spm_eeg_load(fullfile(source_directory, [newfile_name '.mat']));
ft_data(:,:,:,1) = mean(ans2, 4);