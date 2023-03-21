function plot_vector_timeseries(c_pow, t_dsc, color, max_pow)
% plot_vector_timeseries    plot a series of vectors along a time axis
%
%  plot_vector_timeseries(vect, t, color, max_pow)
%
%       vect   is complex row vector (if matrix, chan x time)
%       t      time axis
%       max_pow is radial scale maxiumum (default: max of abs(c_pow))
%       color   colorspec
%
% JRI 2/11/03

if ~nargin,
    help plot_vector_timeseries
    return
end

[nchan, npts] = size(c_pow);
if any([nchan npts] == 1),
    c_pow = c_pow(:).';
    [nchan, npts] = size(c_pow);
end
if nargin < 2,
  t_dsc = 1:npts;
end
t_dsc = t_dsc(:)';

if nchan > 1,
    jisubplot(25,6,0,'landscape',[.2 .1],'fontsize',8)
end

if nargin < 3,
    color = 'b';
end

for iChan = 1:nchan,

    %c_pow = c_pow(:).';
    

    cc_pow = c_pow(iChan,:);

    if nargin < 4,
        max_pow = max(abs(cc_pow))*2.5;
    end

    if nchan > 1,
        nextplot('bycol')
    end

    [rmp, str, shortstr] = niceround(max_pow);
    h=quiver('v6',[-20 t_dsc], [0 zeros(size(t_dsc))], ...
        [-rmp real(cc_pow)], [0 imag(cc_pow)] );
    set(h,'color',color)
    axis equal
    hideAxisLabelsTicks('y')
    %plot_scalebar([5 -20 0 8], [0 rmp], {'', 'pT^2'})
    xspace = (max(t_dsc)-min(t_dsc)) / 10;
    xlim([min(t_dsc)-xspace max(t_dsc)+ xspace])
    gridy(0)
    xlabel('time (s)')
    if nchan > 1,
        ullabel(sprintf('%d',iChan),'small')
        axis off
    end
    drawnow

end %loop on channels
