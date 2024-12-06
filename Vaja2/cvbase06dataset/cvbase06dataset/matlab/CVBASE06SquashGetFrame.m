%CVBASE06SquashGetFrame - Load image from a squash video.
%
%    [A,T] = CVBASE06SquashGetFrame (SETNUM, FRAMENUM) will load single
%    frame from the specified squash video stream. Video stream number is
%    specified in SETNUM, and can be 1 or 2. 3-D array A contains truecolor 
%    RGB data. T contains time (seconds) at which frame
%    was captured (from framerate and FRAMENUM. Requires CVBASE06SQUASHINIT 
%    to be run before first attempt to acess frames is made.

%    (C) Janez Pers, 2003-2006
%
function [A,T] = CVBASE06SquashGetFrames (setnum, framenum);

global CVBASE06Path;
global CVBASE06Cache;


setst = int2str(setnum);
fs = filesep;

filename = [CVBASE06Path,fs,'squash',fs,'squash',setst,'.avi'];

movA = CVBASE06VideoRead(filename,framenum);

A = movA.cdata;

if (setnum==1)
    setused = CVBASE06Cache.squash.set1;
end;
if (setnum==2)
    setused = CVBASE06Cache.squash.set2;
end;


T = framenum/setused.FPS;