%CVBASE06HandballGetPos - Get coordinates for any of the players.
%
%    [X,Y,XA,YA,XB,YB,VALIDCAM] = CVBASE06HandballGetPos (PLAYERNUM) will extract 
%    positions (trajectories) for the player PLAYERNUM. X, Y, XA, YA, XB
%    and YB are vectors of 15000 elements. (1 element per frame).
%    A and Y are the coordinates in court coordinate system. XA, YA are the
%    coordinates in the image coordinate system of camera A, and XB, YB are the
%    coordinates in the image coordinate system of camera B. VALIDCAM contains
%    information whether camera A or B has been used to track a player at 
%    particular frame. VALIDCAM value of 0 denotes camera A and 1 denotes
%    camera B.
%
%    NOTE: Dataset does not contain player coordinates in the coordinates
%    of camera C!
%
%    Requires CVBASE06HANDBALLINIT to be run before first attempt to acess data is made.

%    (C) Janez Pers, 2003-2006
%
function [X,Y,XA,YA,XB,YB, VALIDCAM] = CVBASE06HandballGetPos (playernum);

global CVBASE06Path;
global CVBASE06Cache;

X = CVBASE06Cache.handball.positions{playernum}.x;
Y = CVBASE06Cache.handball.positions{playernum}.y;
XA = CVBASE06Cache.handball.positions{playernum}.xa;
YA = CVBASE06Cache.handball.positions{playernum}.ya;
XB = CVBASE06Cache.handball.positions{playernum}.xb;
YB = CVBASE06Cache.handball.positions{playernum}.yb;
VALIDCAM = CVBASE06Cache.handball.positions{playernum}.validcamera;

