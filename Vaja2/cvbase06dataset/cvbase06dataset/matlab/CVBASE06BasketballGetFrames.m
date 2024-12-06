%CVBASE06BasketballGetFrames - Load images from 2 videos from the standard quality basketball set.
%
%    [A,B,T] = CVBASE06BasketballGetFrames (FRAMENUM) will load single
%    frame from each of the basketball video streams from the standard
%    quality basketball set. At 25 frames per second, the maximum frame number is 7500. 
%    3-D arrays A and B contain truecolor RGB data. T contains time (seconds) 
%    at which frames were captured (from framerate and FRAMENUM. Requires 
%    CVBASE06BASKETBALLINIT to be run before first attempt to acess frames is made.

%    (C) Janez Pers, 2003-2006
%
function [A,B,T] = CVBASE06BasketballGetFrames (framenum);

global CVBASE06Path;
global CVBASE06Cache;

fs = filesep;

movA = CVBASE06VideoRead([CVBASE06Path,fs,'basketball',fs,'basketballA.avi'],framenum);
movB = CVBASE06VideoRead([CVBASE06Path,fs,'basketball',fs,'basketballB.avi'],framenum);

A = movA.cdata;
B = movB.cdata;

T = framenum/CVBASE06Cache.basketball.FPS;
