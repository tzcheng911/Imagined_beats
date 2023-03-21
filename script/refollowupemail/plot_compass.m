function plot_compass(c_pow, max_pow, color, rescolor)
% plot_compass  Plot a simple scaled compass
%
%   plot_compass(c_pow, [max_pow, color, resultant_color])
%
%       c_pow   is complex vector
%       max_pow is radial scale maxiumum (default: max of abs(c_pow))
%       color   colorspec
%       resultant_color (optional) if specified also plots resultant in this color
%
%   JRI 4/22/03

if ~nargin,
    help plot_compass
    return
end

if nargin < 2 || isempty(max_pow),
    max_pow = max(abs(c_pow));
end
if nargin < 3,
    color = 'b';
end

%plot invisible standard vector to fix radial size
h = compass(max_pow*exp(i*pi/4),'w');
set(h,'linewidth',.01)
hold on
%plot vectors
compass(c_pow,color);

if nargin > 3,
    %plot resultant
    res = mean(c_pow);
    h=compass(res,rescolor);
    set(h,'linewidth',2.5);
    title(sprintf('res=%.2f, %.1f deg',abs(res),angle(res)*180/pi),'fontsize',9)
end
