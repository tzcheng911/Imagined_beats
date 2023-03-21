NumSamples = 200;
GUI_MODE = 'nogui';
VERBOSITY_LEVEL = 2;


% obtain the bootstrap distributions for each condition
for cnd=1:length(EEG)
    EEG(cnd) = pop_stat_surrogateGen(EEG(cnd),GUI_MODE, ...
        'modelingApproach', EEG(cnd).CAT.configs.est_fitMVAR, ...
        'connectivityModeling',EEG(cnd).CAT.configs.est_mvarConnectivity, ...
        'mode',{'Bootstrap' 'nperms' NumSamples 'saveTrialIdx' true}, ...
        'autosave',[], ...
        'verb',VERBOSITY_LEVEL);
end