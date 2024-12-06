%CVBASE06HandballGetPlayerActivity - Get player activity annotations.
%
%    [TIME, FRAME, ACT] = CVBASE06HandballGetPlayerActivity (PLAYERNUM) will return
%    individual player activity annotations in vector ACT, and the 
%    corresponding time (seconds) and frame when the activity was annotated in
%    vectors TIME and FRAME.
%
%    NOTE: The resulting vectors of this function are far shorter than
%    when retrieving player trajectories, since they contain only the times
%    when certain activity was observed. One cannot retrieve player
%    activity by addressing ACT(currentframe)!
%
%    For interpretation of annotations, see the file
%    Handball/PlayerActivityDictionary.txt or use the function
%    CVBASE06HandballPlayerDict.
%    Requires CVBASE06HANDBALLINIT to be run before first attempt 
%    to acess the data is made.

%    (C) Janez Pers, 2003-2006
%
function [TIME,FRAME,ACT] = CVBASE06HandballGetPlayerActivity (playernum);

global CVBASE06Path;
global CVBASE06Cache;

ac = CVBASE06Cache.handball.annotations.player.activity;
t = CVBASE06Cache.handball.annotations.player.time;
pnum = CVBASE06Cache.handball.annotations.player.playernum;

TIME = t(pnum==playernum);
ACT = ac(pnum==playernum);
FRAME = round(TIME*CVBASE06Cache.handball.FPS);
