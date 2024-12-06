%CVBASE06SquashShowTrajectories - Show trajectories of a player.
%
%    CVBASE06SquashShowTrajecties (SETNUM, PLAYERNUM) will show court-coordinate
%    system trajectories over a image of squash court.
%    Without the second argument, it will show trajectories for both players in
%    different colors.
%    Requires CVBASE06SQUASHINIT to be run before first attempt to acess frames is made.

%    (C) Janez Pers, 2003-2006
%
function CVBASE06SquashShowTrajectories (setnum, playernum);
global CVBASE06Cache;
global CVBASE06Path;


fs = filesep;
IM = imread([CVBASE06Path,fs,'squash',fs,'court.png']);
s = size(IM);
imshow(IM);
axis xy;
hold on;
axis ([0,s(2),0,s(1)]);

if nargin<2,
    for i=1:2,
        [X,Y] = CVBASE06SquashGetPos(setnum, i);
        drwplayer(i,X,Y);
    end;    
else
    [X,Y] = CVBASE06SquashGetPos(setnum, playernum);
    drwplayer(playernum,X,Y);
end;



function drwplayer(num,X,Y)
c = gtcolor(num);
plot(X*70,Y*70,c);


function A = gtcolor(num)
    if(num==1),
        A = '-b';
    elseif (num==2),
        A = '-g';
    elseif (num==3),
        A = '-r';
    elseif (num==4),
        A = '-c';
    elseif (num==5),
        A = '-m';
    elseif (num==6),
        A = '-y';
    elseif (num==7),
        A = '-k';
    end;
        
    
        