%CVBASE06SquashPhasesDict - Translate squash play phase annotations into descriptions.
%
%    [SHORTDESC, LONGDESC] = CVBASE06SquashPhasesDict (PHASE) will return
%    short and long description of phase annotation, supplied
%    as (scalar!) ACT.
%
%    Requires CVBASE06SQUASHINIT to be run before first attempt 
%    to acess the data is made.

%    (C) Janez Pers, 2003-2006
%
function [SHORTDESC,LONGDESC] = CVBASE06SquashPhasesDict (ACT);

global CVBASE06Path;
global CVBASE06Cache;

ACT = round(ACT);
anum = CVBASE06Cache.squash.dictionary.phases{ACT,1};
num = str2num(anum);
if (~(num==ACT)),
    error('Crosscheck failed - error in dictionary? Contact dataset authors.');
end;
    
s = CVBASE06Cache.squash.dictionary.phases{ACT,2};
l = CVBASE06Cache.squash.dictionary.phases{ACT,3};

SHORTDESC = s;
LONGDESC = l;

