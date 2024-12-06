%CVBASE06BasketballInit - Initialize matlab interface to basketball subset of CVBAS 2006 dataset.
%
%    CVBASE06BasketballInit (PATH) will set up basic environment for use of
%    the basketball dataset. Executing "clear" command will delete the data, 
%    and this function will have to be called again.
%    All the relevant data is stored in the global structure called CVBASE2006Cache.
%    If you declare it yourself in your own workspace, you can access it directly.

%    (C) Janez Pers, 2003-2006
%
function CVBASE06BasketballInit (pth);

global CVBASE06Path;
global CVBASE06Cache;


% Basically the only thing that is really needed is path, since we don't
% have any trajectories or annotations
CVBASE06Path = pth;

basketball.FPS = 25;
CVBASE06Cache.basketball = basketball;