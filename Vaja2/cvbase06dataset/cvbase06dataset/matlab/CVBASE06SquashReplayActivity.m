%CVBASE06SquashReplayActivity - Play a sequence of 11 frames before and after annotation.
%
%    CVBASE06SquashReplayActivity (SETNUM, PLAYERNUM, ACTIDX) will sequentially load 11 frames 
%    from the dataset at position defined by PLAYERNUM and ACTIDX and play them on sceen. Player
%    positions are marked with circles, and position of the ball at the
%    moment of annotation is marked by triangle, along with other annotation
%    data. ACTIDX is index into the vector of activities (ACTIDX=1 means first 
%    annotated activity for player PLAYERNUM, ACTIDX = 2 means second, etc.). Requires 
%    CVBASE06SQUASHINIT to be run before first attempt to acess frames is made.

%
%    (C) Janez Pers, 2003-2006
%
function CVBASE06SquashReplayActivity (setnum, playernum, actidx);

[time, frame, stype, soutcome, sfb, sx, sy] = CVBASE06SquashGetPlayerActivity(setnum, playernum);

for i=-5:5,
     CVBASE06SquashShowFrame (setnum, frame(actidx)+i);
     pause(0.1);
end;

% to prevent pilling of anntations (slows down the display)
close(gcf);
     
    