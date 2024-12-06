%CVBASE06BasketballGetFramesHiRes - Load images from 2 videos from the High Quality basketball set.
%
%    [A,B,T] = CVBASE06BasketballGetFramesHiRes (FRAMENUM) will load single
%    frame from each of the basketball video streams from the High Quality
%    basketball set. At 25 frames per second, the maximum frame number is 3000. 
%    3-D arrays A and B contain truecolor RGB data. T contains time (seconds) 
%    at which frames were captured (from framerate and FRAMENUM. Requires 
%    CVBASE06BASKETBALLINIT to be run before first attempt to acess frames is made.

%    (C) Janez Pers, 2003-2006
%
function [A,B,T] = CVBASE06BasketballGetFramesHiRes (framenum);

global CVBASE06Path;
global CVBASE06Cache;

fs = filesep;

movA = CVBASE06VideoRead([CVBASE06Path,fs,'basketball',fs,'HiResBasketballA.avi'],framenum);
movB = CVBASE06VideoRead([CVBASE06Path,fs,'basketball',fs,'HiResBasketballB.avi'],framenum);

A = movA.cdata;
B = movB.cdata;

T = framenum/CVBASE06Cache.basketball.FPS;
