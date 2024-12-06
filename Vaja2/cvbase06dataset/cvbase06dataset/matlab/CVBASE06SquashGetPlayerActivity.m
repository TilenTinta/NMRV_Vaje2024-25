%CVBASE06SquashGetPlayerActivity - Get squash player activity annotations.
%
%    [TIME, FRAME, STYPE, SOUTCOME, SFB, SX, SY] = CVBASE06SquashGetPlayerActivity 
%    (SETNUM, PLAYERNUM) will return individual player activity annotations
%    (strokes). 
%
%    Vector STYPE will contain stroke type. Decode it using
%    function CVBASE06SquashShotTypesDict or the corresponding dictionary
%    Squash/ShotTypeDictionary.txt.
%
%    Vector SOUTCOME will contain stroke outcome. Decode it using
%    function CVBASE06SquashShotOutcomeDict or the corresponding dictionary
%    Squash/ShotOutcomeDictionary.txt.
%
%    Vector SFB will contain type of stroke (forehand or backhand). Decode it using
%    function CVBASE06SquashFBDict or the corresponding dictionary
%    Squash/ForehandBackhandDictionary.txt.
%
%    Vectors SX and SY will contain image coordinates of the ball at the time
%    the shot was observed. Do not mix this with the coordinates of the
%    player at the same time!
%   
%    Corresponding time (seconds) and frame when the activity was annotated
%    is contained in the vectors TIME and FRAME.
%
%    NOTE: The resulting vectors of this function are far shorter than
%    when retrieving player trajectories, since they contain only the times
%    when certain activity was observed. One cannot retrieve player
%    activity by addressing STYPE(currentframe)!
%
%    Requires CVBASE06SQUASHINIT to be run before first attempt 
%    to acess the data is made.

%    (C) Janez Pers, 2003-2006
%
function[TIME, FRAME, STYPE, SOUTCOME, SFB, SX, SY] = CVBASE06SquashGetPlayerActivity (setnum, playernum);

global CVBASE06Path;
global CVBASE06Cache;

if (setnum==1)
    setused = CVBASE06Cache.squash.set1;
end;
if (setnum==2)
    setused = CVBASE06Cache.squash.set2;
end;

TIME = setused.annotations.shots.seconds(setused.annotations.shots.shotplayer==playernum);
FRAME = setused.annotations.shots.frame(setused.annotations.shots.shotplayer==playernum);
STYPE = setused.annotations.shots.shottype(setused.annotations.shots.shotplayer==playernum);
SOUTCOME = setused.annotations.shots.shotoutcome(setused.annotations.shots.shotplayer==playernum);
SFB = setused.annotations.shots.forehandbackhand(setused.annotations.shots.shotplayer==playernum);
SX = setused.annotations.shots.shotX(setused.annotations.shots.shotplayer==playernum);
SY = setused.annotations.shots.shotY(setused.annotations.shots.shotplayer==playernum);