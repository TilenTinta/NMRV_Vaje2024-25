%CVBASE06HandballShowFrames - Show 3 frames from handball set with player positions marked.
%
%    CVBASE06HandballShowFrames (FRAMENUM) will load single frame
%    from each of the handball video streams and display them on screen. Player
%    positions will be marked with circles and their names.
%    Blue circles denote that the other camera has been used for tracking a particular
%    player, and red circle denotes that current camera has been used.
%    Requires CVBASE06HANDBALLINIT to be run before first attempt to acess frames is made.
%
%    (C) Janez Pers, 2003-2006
%
function CVBASE06HandballShowFrames (framenum);

global CVBASE06Path;
global CVBASE06Cache;
numplayers = 7;

[A,B,C,T] = CVBASE06HandballGetFrames(framenum);

subplot (2,2,1);
imshow(A); 
hold on;
for playernum=1:numplayers,
    [X,Y,XA,YA,XB,YB, validcam] = CVBASE06HandballGetPos(playernum);
    if (validcam(framenum)) == 0,
        plot(XA(framenum),YA(framenum),'ro');
    else
        plot(XA(framenum),YA(framenum),'bo');
    end;
    pname = CVBASE06Cache.handball.positions{playernum}.playername;
    text(XA(framenum),YA(framenum),pname);
end;    

subplot (2,2,2);

imshow(B);
hold on;
for playernum=1:numplayers,
    [X,Y,XA,YA,XB,YB, validcam] = CVBASE06HandballGetPos(playernum);
    if (validcam(framenum)) == 1,
        plot(XB(framenum),YB(framenum),'ro');
    else
        plot(XB(framenum),YB(framenum),'bo');
    end;
    pname = CVBASE06Cache.handball.positions{playernum}.playername;
    text(XB(framenum),YB(framenum),pname);    
end;    

subplot (2,2,3);

imshow(C);

