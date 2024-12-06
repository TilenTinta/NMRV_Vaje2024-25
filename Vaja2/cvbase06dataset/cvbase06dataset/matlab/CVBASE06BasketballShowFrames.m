% CVBASE06BasketballShowFrames - Show 2 frames from the standard quality basketball set.
%
%    CVBASE06BasketballShowFrames (FRAMENUM) will load single frame
%    from each of the standard quality basketball  video streams and display them on screen. 
%    Requires CVBASE06BASKETBALLINIT to be run before first attempt to acess frames is made.

%    (C) Janez Pers, 2003-2006
%
function CVBASE06BasketballShowFrames (framenum);

global CVBASE06Path;
global CVBASE06Cache;

[A,B,T] = CVBASE06BasketballGetFrames(framenum);

subplot (1,2,1);
imshow(A);
subplot (1,2,2);
imshow(B);

