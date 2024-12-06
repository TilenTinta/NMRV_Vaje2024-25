%CVBASE06SquashShotOutcomeDict - Translate player shot outcome annotations into descriptions.
%
%    [SHORTDESC, LONGDESC] = CVBASE06SquashShotOutcomeDict (ACT) will return
%    short and long description of annotated shot outcome, supplied
%    as (scalar!) ACT.
%
%    Requires CVBASE06SQUASHINIT to be run before first attempt 
%    to acess the data is made.

%    (C) Janez Pers, 2003-2006
%
function [SHORTDESC,LONGDESC] = CVBASE06SquashShotOutcomeDict (ACT);

global CVBASE06Path;
global CVBASE06Cache;

ACT = round(ACT);
anum = CVBASE06Cache.squash.dictionary.shotoutcome{ACT,1};
num = str2num(anum);
if (~(num==ACT)),
    error('Crosscheck failed - error in dictionary? Contact dataset authors.');
end;
    
s = CVBASE06Cache.squash.dictionary.shotoutcome{ACT,2};
l = CVBASE06Cache.squash.dictionary.shotoutcome{ACT,3};

SHORTDESC = s;
LONGDESC = l;

