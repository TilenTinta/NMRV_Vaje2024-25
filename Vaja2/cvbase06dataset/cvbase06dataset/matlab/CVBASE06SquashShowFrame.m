%CVBASE06SquashShowFrame - Show framee from squash sets with player positions marked.
%
%    CVBASE06SquashShowFrame (SETNUM, FRAMENUM) will load single frame
%    from the dataset, specified by SETNUM and display it on screen. Player
%    positions are marked with circles.
%    Requires CVBASE06SQUASHINIT to be run before first attempt to acess frames is made.

%
%    (C) Janez Pers, 2003-2006
%
function CVBASE06SquashShowFrame (setnum, framenum);

global CVBASE06Path;
global CVBASE06Cache;
numplayers = 2;

A = CVBASE06SquashGetFrame(setnum, framenum);

imshow(A); 
hold on;
for playernum=1:numplayers,
    [X,Y,XC,YC] = CVBASE06SquashGetPos (setnum, playernum);
    if (playernum) == 1,
        plot(XC(framenum),YC(framenum),'bo');
    end;    
    if (playernum) == 2,
        plot(XC(framenum),YC(framenum),'go');
    end;
end;    

% Plot stroke position, if stroke was detected in this frame.

[time, frame, stype, soutcome, sfb, sx, sy] = CVBASE06SquashGetPlayerActivity (setnum,1);
idx = find(framenum==frame);
if (~isempty(idx))
    plot(sx(idx),sy(idx),'b^');
    [s1s,s1l] = CVBASE06SquashShotTypesDict(stype(idx));
    [s2s,s2l] = CVBASE06SquashShotOutcomeDict(soutcome(idx));    
    [s3s,s3l] = CVBASE06SquashFBDict(sfb(idx));        
    text(sx(idx),sy(idx)+10,s1l);
    text(sx(idx),sy(idx)+25,s2l);
    text(sx(idx),sy(idx)+40,s3l);    
end;
     
[time, frame, stype, soutcome, sfb, sx, sy] = CVBASE06SquashGetPlayerActivity (setnum,2);
idx = find(framenum==frame);
if (~isempty(idx))
    plot(sx(idx),sy(idx),'g^');
    [s1s,s1l] = CVBASE06SquashShotTypesDict(stype(idx));
    [s2s,s2l] = CVBASE06SquashShotOutcomeDict(soutcome(idx));    
    [s3s,s3l] = CVBASE06SquashFBDict(sfb(idx));        
    text(sx(idx),sy(idx)+10,s1l);
    text(sx(idx),sy(idx)+25,s2l);
    text(sx(idx),sy(idx)+40,s3l);    
end;
