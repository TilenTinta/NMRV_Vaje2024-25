%CVBASE06HandballGetTeamActivityEx - Expanded form of team activity annots.
%
%    [TIME, FRAME, ACT] = CVBASE06HandballGetTeamActivityEx will return
%    group (team) activity annotations in expanded form. Annotations are
%    returned as vector ACT, the corresponding times (in seconds) for each
%    element of ACT is returned in vector TIME, and the corresponding
%    frames in vector FRAME. 
%
%    NOTE: The resulting vectors are of same size than the player 
%    position vectors, and the number of elements corresponds to the
%    number of video frames in video streams.
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
function [TIME, FRAME, ACT] = CVBASE06HandballGetTeamActivityEx;

global CVBASE06Path;
global CVBASE06Cache;

ACT = CVBASE06Cache.handball.annotations.team.expanded.activity;
FRAME = CVBASE06Cache.handball.annotations.team.expanded.frames;
TIME = CVBASE06Cache.handball.annotations.team.expanded.time;
