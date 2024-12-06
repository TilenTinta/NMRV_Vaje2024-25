%CVBASE06SquashGetPhasesEx - Get phase annotations for squash in ext. form
%
%    ACT = CVBASE06SquashGetPhasesEx(SETNUM) will return phase (rally or
%    passive phase annotations in vector ACT.
%
%    NOTE: The elements of the resulting vector correspond to the
%    video frames in video streams and to elements of player position
%    vectors.
%
%    For interpretation of annotations, see the file Squash/PhasesDictionary.txt 
%    or use the function CVBASE06SquashPhasesDict.
%
%    Requires CVBASE06SQUASHINIT to be run before first attempt 
%    to acess the data is made.

%    (C) Janez Pers, 2003-2006
%

function [TIME, FRAME, ACT] = CVBASE06SquashGetPhasesEx(setnum);

global CVBASE06Path;
global CVBASE06Cache;

if (setnum==1)
    setused = CVBASE06Cache.squash.set1;
end;
if (setnum==2)
    setused = CVBASE06Cache.squash.set2;
end;


ACT = setused.annotations.phases;
FRAME = setused.frames;
TIME = setused.seconds;

