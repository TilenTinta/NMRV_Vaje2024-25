%CVBASE06VideoRead - Load frame from video CVBASE06 video file.
%
%    A = CVBASE06VideoRead (FILENAME, FRAMENUM) will load single
%    frame FRAMENUM from the specified video file FILENAME.
%
%    NOTE: This function is only a interface to the matlab's AVIREAD
%    function. All other function from this dataset are routed through
%    this one for the low level video acess.
%     
%    The purpose of such organization is that if you are unable to
%    use original DivX videos, you can convert them in whatever
%    form you like, and only modify this function (to use whatever you
%    want instead of AVIREAD to acess frames.) This may be necessary
%    on some types of UNIX, where matlab cannot read DivX encoded files.
%

%    (C) Janez Pers, 2003-2006
%
function A = CVBASE06VideoRead (filename, framenum);

A = aviread(filename, framenum);

