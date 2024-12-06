%CVBASE06HandballPlayerDict - Translate player activity annotations into descriptions.
%
%    [SHORTDESC, LONGDESC] = CVBASE06HandballPlayerDict (ACT) will return
%    short and long description of annotated player activity, supplied
%    as (scalar!) ACT.
%
%    Requires CVBASE06HANDBALLINIT to be run before first attempt 
%    to acess the data is made.

%    (C) Janez Pers, 2003-2006
%
function [SHORTDESC,LONGDESC] = CVBASE06HandballHandballPlayerDict (ACT);

global CVBASE06Path;
global CVBASE06Cache;

ACT = round(ACT);
anum = CVBASE06Cache.handball.annotations.player.dictionary{ACT,1};
num = str2num(anum);
if (~(num==ACT)),
    error('Crosscheck failed - error in dictionary? Contact dataset authors.');
end;
    
s = CVBASE06Cache.handball.annotations.player.dictionary{ACT,2};
l = CVBASE06Cache.handball.annotations.player.dictionary{ACT,3};

SHORTDESC = s;
LONGDESC = l;
