%CVBASE06SquashGetPos - Get coordinates for any of the players.
%
%    [X,Y,XC,YC] = CVBASE06SquashGetPos (SETNUM, PLAYERNUM) will extract 
%    positions (trajectories) for the player PLAYERNUM (possible values: 1 or 2) 
%    in the set SETNUM (possible values: 1 or 2). X, Y, XC and YC
%    vectors, their length is equal to the number of valid frames (1 element 
%    per frame). 
%
%    NOTE: Squash videos can extend past the end of the available position data -
%    those frames should be discarded.
%
%    X and Y are the coordinates in court coordinate system. XC and YC are the
%    coordinates in the image (camera) coordinate system
%
%    Requires CVBASE06SQUASHINIT to be run before first attempt to acess data is made.

%    (C) Janez Pers, 2003-2006
%
function [X,Y,XC,YC] = CVBASE06SquashGetPos (setnum,playernum);

global CVBASE06Path;
global CVBASE06Cache;

if (setnum==1)
    setused = CVBASE06Cache.squash.set1;
end;
if (setnum==2)
    setused = CVBASE06Cache.squash.set2;
end;

if (playernum==1)
    setused = setused.positions.player1;
end;
if (playernum==2)
    setused = setused.positions.player2;
end;


X = setused.X;
Y = setused.Y;
XC = setused.XC;
YC = setused.YC;
