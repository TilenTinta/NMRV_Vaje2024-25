%CVBASE06HandballGetTeamActivity - Get team activity annotations.
%
%    [TIMESTART, TIMEEND, FRAMESTART, FRAMEEND, ACT] = CVBASE06HandballGetTeamActivity will return
%    group (team) activity annotations in vector ACT, and the 
%    corresponding times (seconds) and frames when the activity was started
%    and ended are returned in first four vectors.
%
%    NOTE: The resulting vectors of this function are far shorter than
%    when retrieving player trajectories, since they contain only the times
%    when certain activity was observed. One cannot retrieve player
%    activity by addressing ACT(currentframe)! For this purpose use
%    the function CVBASE06HandballGetTeamActivityExp.
%
%    NOTE2: The major difference between player and team activity
%    annotations is the fact that player activities are usually short term
%    and have been annotated as single moment (e.g. player passes a ball).
%    On the other hand, team activities have been annotated as intervals,
%    when the team is performing certain kind of activity (e.g. offense).
%    These intervals follow each other (the team is always "active").
%    Therefore, an expanded format of team activities is possible to
%    generate, but the expanded format of player activities does not have
%    much sense (it would be very sparse).
%
%    For interpretation of annotations, see the file
%    Handball/TeamActivityDictionary.txt or use the function
%    CVBASE06HandballTeampDict.
%    Requires CVBASE06HANDBALLINIT to be run before first attempt 
%    to acess the data is made.

%    (C) Janez Pers, 2003-2006
%
function [TIMESTART, TIMEEND, FRAMESTART, FRAMEEND, ACT] = CVBASE06HandballGetTeamActivity;

global CVBASE06Path;
global CVBASE06Cache;

ac = CVBASE06Cache.handball.annotations.team.activity;
t1 = CVBASE06Cache.handball.annotations.team.timestart;
t2 = CVBASE06Cache.handball.annotations.team.timeend;
f1 = round(t1*CVBASE06Cache.handball.FPS);
f2 = round(t2*CVBASE06Cache.handball.FPS);

TIMESTART = t1;
TIMEEND = t2;
FRAMESTART = f1;
FRAMEEND = f2;
ACT = ac;
