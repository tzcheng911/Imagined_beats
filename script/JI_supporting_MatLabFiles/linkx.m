function linkx(figs)
%linkx link x axes of figures
%
%  linkx        choose figures, hit enter when done
%  linkx(figs)  link figs
%
% 4/13/2020 JRI

% note, works on gca for each figure

%build up list of figures by selecting them
if nargin < 1
    %TODO
end

ax = [];
for fig = figs
    ax(end+1) = get(fig,'CurrentAxes');
end

linkaxes(ax,'x')
