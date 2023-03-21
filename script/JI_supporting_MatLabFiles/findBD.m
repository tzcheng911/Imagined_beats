function BD = findBD(date,age)
% findBD given a date and an age at that date, find the birthday
%
% used to workong pling kids birthdays
% JRI 2/11/15

tmp=datevec(datenum(date,'yyyymmdd'));
tmp(1) = tmp(1)-age;
BD = datestr(datenum(tmp),'mm/dd/yyyy');
