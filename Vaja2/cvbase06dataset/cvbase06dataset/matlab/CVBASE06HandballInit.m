%CVBASE06HandballInit - Initialize matlab interface to handball subset of CVBAS 2006 dataset.
%
%    CVBASE06HandballInit (PATH) will load the annotations and trajectories
%    for handball subset, given the path to the root directory in which
%    CVBASE 2006 dataset has been unpacked. Since annotations and trajectories are
%    loaded at once, you need a decent amount of RAM. Executing "clear" command
%    will delete loaded data, and this function will have to be called again.
%    All the relevant data is stored in the global structure called CVBASE2006Cache.
%    If you declare it yourself in your own workspace, you can access it directly.

%    (C) Janez Pers, 2003-2006
%
function CVBASE06HandballInit (pth);

global CVBASE06Path;
global CVBASE06Cache;

CVBASE06Path = pth;
fs = filesep;

% We have 10 minutes of video for handball, 3 video streams.
FPS = 25;
NumberOfFrames = 10*60*FPS;
NumberOfPlayers = 7;

%Load trajectories
rawtraj = dlmread([CVBASE06Path,fs,'handball',fs,'positions.txt'],'\t',[2,0,NumberOfFrames+1,50]);
s = size(rawtraj);
seconds = rawtraj(:,2);
frames = rawtraj(:,1);

%Load player names
plnames = textread([CVBASE06Path,fs,'handball',fs,'PlayerList.txt'], '%s', 'delimiter','\t'); 
plnames = reshape(plnames,[2, NumberOfPlayers+1]);

for i=1:NumberOfPlayers,
    positions{i}.playernumber = plnames{1,i+1};    
    positions{i}.playername = plnames{2,i+1};    
    positions{i}.x = rawtraj(:,2+1+(i-1)*7);
    positions{i}.y = rawtraj(:,2+2+(i-1)*7);
    positions{i}.xa = rawtraj(:,2+3+(i-1)*7);
    positions{i}.ya = rawtraj(:,2+4+(i-1)*7);
    positions{i}.xb = rawtraj(:,2+5+(i-1)*7);    
    positions{i}.yb = rawtraj(:,2+6+(i-1)*7);    
    positions{i}.validcamera = rawtraj(:,2+7+(i-1)*7);
end;

%Load annotations
TeamAnnotations = textread([CVBASE06Path,fs,'handball',fs,'TeamActivity.txt'], '%s', 'delimiter','\t'); 
s = size(TeamAnnotations);
TeamAnnotations = reshape(TeamAnnotations, [3, s(1)/3]);
TeamAnnotations = transpose(TeamAnnotations);
s = size(TeamAnnotations);
TeamAnnotations = TeamAnnotations(2:s(1),:);

PlayerAnnotations = textread([CVBASE06Path,fs,'handball',fs,'PlayerActivity.txt'], '%s', 'delimiter','\t'); 
s = size(PlayerAnnotations);
PlayerAnnotations = reshape(PlayerAnnotations, [3, s(1)/3]);
PlayerAnnotations = transpose(PlayerAnnotations);
s = size(PlayerAnnotations);
PlayerAnnotations = PlayerAnnotations(2:s(1),:);

%Load annotation dictionaries
TeamDictionary = textread([CVBASE06Path,fs,'handball',fs,'TeamActivityDictionary.txt'], '%s', 'delimiter','\t'); 
s = size(TeamDictionary);
TeamDictionary = reshape(TeamDictionary, [3, s(1)/3]);
TeamDictionary = transpose(TeamDictionary);
s = size(TeamDictionary);
TeamDictionary = TeamDictionary(2:s(1),:);
PlayerDictionary = textread([CVBASE06Path,fs,'handball',fs,'PlayerActivityDictionary.txt'], '%s', 'delimiter','\t'); 
s = size(PlayerDictionary);
PlayerDictionary = reshape(PlayerDictionary, [3, s(1)/3]);
PlayerDictionary = transpose(PlayerDictionary);
s = size(PlayerDictionary);
PlayerDictionary = PlayerDictionary(2:s(1),:);

%Decode annotations according to dictionaries
s = size(TeamAnnotations);
ta = zeros(s(1),s(2));
for i=1:s(1),
    ta(i,1) = str2num(TeamAnnotations{i,1});
    ta(i,2) = str2num(TeamAnnotations{i,2});
end;

ta(:,3) = TranslateThroughDict(TeamDictionary, TeamAnnotations(:,3));

s = size(PlayerAnnotations);
tp = zeros(s(1),s(2));
for i=1:s(1),
    tp(i,1) = str2num(PlayerAnnotations{i,1});
    tp(i,2) = str2num(PlayerAnnotations{i,2});
end;

tp(:,3) = TranslateThroughDict(PlayerDictionary, PlayerAnnotations(:,3));

timestart=ta(:,1);
timeend=ta(:,2);
activity=ta(:,3);
annotations.team.dictionary=TeamDictionary;

framestart = timestart*FPS;
frameend = timeend*FPS;

%add last line to cover whole time axis
framestart = [framestart; frameend(length(frameend))];
frameend = [frameend; NumberOfFrames];

timestart = framestart/FPS;
timeend = frameend/FPS;

annotations.team.timestart = timestart;
annotations.team.timeend = timeend;
annotations.team.activity = activity;

% expand team annotations
actexpanded = [];
frameexpanded = [];
for i=1:length(framestart)-1,
    actlen = frameend(i)-framestart(i);
    act = repmat(activity(i), [actlen,1]);
    actexpanded = [actexpanded; act];
    frameexpanded = [frameexpanded; (framestart(i):framestart(i+1)-1)'];
end;
timeexpanded = frameexpanded/FPS;

annotations.team.expanded.frames = frameexpanded;
annotations.team.expanded.time = timeexpanded;
annotations.team.expanded.activity = actexpanded;

annotations.player.time=tp(:,1);
annotations.player.playernum=tp(:,2);
annotations.player.activity=tp(:,3);
annotations.player.dictionary=PlayerDictionary;

handball.FPS = 25;
handball.NumberOfFrames = 10*60*FPS;
handball.NumberOfPlayers = 7;
handball.positions = positions;
handball.annotations = annotations;

CVBASE06Cache.handball = handball;




%-----------------------
function newcolumn = TranslateThroughDict (dict, column)

lc = length(column);
ld = size(dict);
newcolumn = zeros(size(column));
for n1=1:lc,
    el = column{n1};
    translated = 0;
    for n2=1:ld,
        if strcmp(el,dict{n2,2}),
            translated = str2num(dict{n2,1});
        end;
    end;
    newcolumn(n1) = translated;
end;
