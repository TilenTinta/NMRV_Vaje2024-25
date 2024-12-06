%CVBASE06HandballShowTrajectories - Show trajectories of particular player.
%
%    CVBASE06HandballShowTrajecties (PLAYERNUM) will show court-coordinate
%    system trajectories over a image of handball court.
%    Without argument, it will show trajectories for all of the players in
%    different colors.
%    Requires CVBASE06HANDBALLINIT to be run before first attempt to acess frames is made.

%    (C) Janez Pers, 2003-2006
%
function CVBASE06HandballShowTrajectories (playernum);
global CVBASE06Cache;
global CVBASE06Path;


fs = filesep;
IM = imread([CVBASE06Path,fs,'handball',fs,'court.png']);
imshow(IM);
axis xy;
hold on;
axis ([0,800,0,400]);

if nargin<1,
    for i=1:CVBASE06Cache.handball.NumberOfPlayers,
        drwplayer(i);
    end;
    
else
    drwplayer(playernum);
end;



function drwplayer(num)
c = gtcolor(num);
[X,Y] = CVBASE06HandballGetPos (num);
plot(X*20,Y*20,c);


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
        
    
        