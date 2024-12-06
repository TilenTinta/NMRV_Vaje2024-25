%CVBASE06HandballGetFrames - Load images from 3 videos from handball set.
%
%    [A,B,C,T] = CVBASE06HandballGetFrames (FRAMENUM) will load single
%    frame from each of the handball video streams. At 25 frames per second, the
%    maximum frame number is 15000. 3-D arrays A,B, and C contain truecolor
%    RGB data. T contains time (seconds) at which frames were captured (from framerate and
%    FRAMENUM. Requires CVBASE06HANDBALLINIT to be run before first attempt to 
%    acess frames is made.

%    (C) Janez Pers, 2003-2006
%
function [A,B,C,T] = CVBASE06HandballGetFrames (framenum);

global CVBASE06Path;
global CVBASE06Cache;

fs = filesep;
movA = CVBASE06VideoRead([CVBASE06Path,fs,'handball',fs,'handballA.avi'],framenum);
movB = CVBASE06VideoRead([CVBASE06Path,fs,'handball',fs,'handballB.avi'],framenum);
movC = CVBASE06VideoRead([CVBASE06Path,fs,'handball',fs,'handballC.avi'],framenum);

A = movA.cdata;
B = movB.cdata;
C = movC.cdata;

T = framenum/CVBASE06Cache.handball.FPS;
