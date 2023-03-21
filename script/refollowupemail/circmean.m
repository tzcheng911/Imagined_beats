function [theta, rbar, delta, cse, csd] = circmean( DATA )
% [THETA, RBAR, DELTA, CSE] = CIRCMEAN( DATA ) 
%
% Function returns the non-weighted circular mean (THETA) of all of
% the elements in the vector DATA (in radians). Optionally returns the mean
% resultant length (rbar) and circular dispersion (delta). Also:
%   circular standard error (cse, based on delta) and 
%   circular standard deviation (csd), using established formula of Mardia,
%   1972, quoted in Fisher, 1987.

%JRI added cse, csd

% Copyright (C) 2003  Daniel Rizzuto, PhD
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

if nargin == 0
  help circmean;
  return
end

DATA = DATA(:);
DATA(isnan(DATA)) = []; %remove NANs
N = length(DATA);

C = sum( cos(DATA) );
S = sum( sin(DATA) );

theta = atan(S/C);
if C < 0
  theta = theta + pi;
elseif S < 0
  theta = atan(S/C) + 2*pi;
end

if nargout >= 2
  rbar = sqrt( C^2 + S^2 )/N;
end
if nargout >= 3
  moment2 = 1/N * sum( cos( 2 * (DATA - theta) ) );
  delta = (1 - moment2)/(2 * rbar^2);
end

if nargout >=4,
    cse = sqrt(delta / N);
end

if nargout >=5,
    csd = sqrt(-2*log(rbar));
end
