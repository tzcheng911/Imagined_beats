function listStreams(S)
% simple list of XDF streams, call after load_xdf
% JRI

for i = 1:length(S)
    fprintf('%2d: %15s\t(%s)\t\t%d points\n',i, S{i}.info.name, S{i}.info.type, length(S{i}.time_stamps))
end