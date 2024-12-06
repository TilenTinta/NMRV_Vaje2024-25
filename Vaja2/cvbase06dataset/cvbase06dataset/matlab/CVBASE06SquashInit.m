%CVBASE06SquashInit - Initialize matlab interface to squash subset of CVBAS 2006 dataset.
%
%    CVBASE06SquashInit (PATH) will load the annotations and trajectories
%    for squash subset, given the path to the root directory in which
%    CVBASE 2006 dataset has been unpacked. Since annotations and trajectories are
%    loaded at once, you need a decent amount of RAM. Executing "clear" command
%    will delete loaded data, and this function will have to be called again.
%    All the relevant data is stored in the global structure called CVBASE2006Cache.
%    If you declare it yourself in your own workspace, you can access it directly.

%    (C) Janez Pers, 2003-2006
%
function CVBASE06SquashInit (pth);

global CVBASE06Path;
global CVBASE06Cache;

CVBASE06Path = pth;
fs = filesep;

squash.set1.FPS = 25;
squash.set1.NumberOfFrames = 13727;
squash.set1.NumberOfPlayers = 2;

squash.set2.FPS = 25;
squash.set2.NumberOfFrames = 15507;
squash.set2.NumberOfPlayers = 2;

%Load trajectories
rawtraj1 = dlmread([CVBASE06Path,fs,'squash',fs,'squash1positions.txt'],'\t',[2,0,squash.set1.NumberOfFrames+1,10]);
s = size(rawtraj1);
squash.set1.seconds = rawtraj1(:,2);
squash.set1.frames = rawtraj1(:,1);
squash.set1.positions.player1.X = rawtraj1(:,3);
squash.set1.positions.player1.Y = rawtraj1(:,4);
squash.set1.positions.player1.XC = rawtraj1(:,5);
squash.set1.positions.player1.YC = rawtraj1(:,6);
squash.set1.positions.player2.X = rawtraj1(:,7);
squash.set1.positions.player2.Y = rawtraj1(:,8);
squash.set1.positions.player2.XC = rawtraj1(:,9);
squash.set1.positions.player2.YC = rawtraj1(:,10);
squash.set1.annotations.phases = rawtraj1(:,11);

rawtraj2 = dlmread([CVBASE06Path,fs,'squash',fs,'squash2positions.txt'],'\t',[2,0,squash.set2.NumberOfFrames+1,10]);
s = size(rawtraj1);
squash.set2.seconds = rawtraj2(:,2);
squash.set2.frames = rawtraj2(:,1);
squash.set2.positions.player1.X = rawtraj2(:,3);
squash.set2.positions.player1.Y = rawtraj2(:,4);
squash.set2.positions.player1.XC = rawtraj2(:,5);
squash.set2.positions.player1.YC = rawtraj2(:,6);
squash.set2.positions.player2.X = rawtraj2(:,7);
squash.set2.positions.player2.Y = rawtraj2(:,8);
squash.set2.positions.player2.XC = rawtraj2(:,9);
squash.set2.positions.player2.YC = rawtraj2(:,10);
squash.set2.annotations.phases = rawtraj2(:,11);


%Load annotations
annotations1 = textread([CVBASE06Path,fs,'squash',fs,'Squash1PlayerActivity.txt'], '%s', 'delimiter','\t'); 
s = size(annotations1);
annotations1 = reshape(annotations1, [8, s(1)/8]);
annotations1 = transpose(annotations1);
s = size(annotations1);
annotations1 = annotations1(2:s(1),:);

annotations2 = textread([CVBASE06Path,fs,'squash',fs,'Squash2PlayerActivity.txt'], '%s', 'delimiter','\t'); 
s = size(annotations2);
annotations2 = reshape(annotations2, [8, s(1)/8]);
annotations2 = transpose(annotations2);
s = size(annotations2);
annotations2 = annotations2(2:s(1),:);


%Load annotation dictionaries
%Dictionary of phases
PhasesDictionary = textread([CVBASE06Path,fs,'squash',fs,'PhasesDictionary.txt'], '%s', 'delimiter','\t'); 
s = size(PhasesDictionary);
PhasesDictionary = reshape(PhasesDictionary, [3, s(1)/3]);
PhasesDictionary = transpose(PhasesDictionary);
s = size(PhasesDictionary);
PhasesDictionary = PhasesDictionary(2:s(1),:);

%Dictionary of shot types
PlayerDictionary1 = textread([CVBASE06Path,fs,'squash',fs,'ShotTypeDictionary.txt'], '%s', 'delimiter','\t'); 
s = size(PlayerDictionary1);
PlayerDictionary1 = reshape(PlayerDictionary1, [3, s(1)/3]);
PlayerDictionary1 = transpose(PlayerDictionary1);
s = size(PlayerDictionary1);
PlayerDictionary1 = PlayerDictionary1(2:s(1),:);

%Dictionary of shot outcomes
PlayerDictionary2 = textread([CVBASE06Path,fs,'squash',fs,'ShotOutcomeDictionary.txt'], '%s', 'delimiter','\t'); 
s = size(PlayerDictionary2);
PlayerDictionary2 = reshape(PlayerDictionary2, [3, s(1)/3]);
PlayerDictionary2 = transpose(PlayerDictionary2);
s = size(PlayerDictionary2);
PlayerDictionary2 = PlayerDictionary2(2:s(1),:);

%Dictionary of forehand/backhand annotations
PlayerDictionary3 = textread([CVBASE06Path,fs,'squash',fs,'ForehandBackhandDictionary.txt'], '%s', 'delimiter','\t'); 
s = size(PlayerDictionary3);
PlayerDictionary3 = reshape(PlayerDictionary3, [3, s(1)/3]);
PlayerDictionary3 = transpose(PlayerDictionary3);
s = size(PlayerDictionary3);
PlayerDictionary3 = PlayerDictionary3(2:s(1),:);

%Decode annotations according to dictionaries
s = size(annotations1);
ta1 = zeros(s(1),s(2));
for i=1:s(1),
    ta1(i,1) = str2num(annotations1{i,1});
    ta1(i,2) = str2num(annotations1{i,2});
    ta1(i,3) = str2num(annotations1{i,3});    
    ta1(i,7) = str2num(annotations1{i,7});
    ta1(i,8) = str2num(annotations1{i,8});
end;
%Shot types
ta1(:,4) = TranslateThroughDict(PlayerDictionary1, annotations1(:,4));
%Shot outcomes
ta1(:,5) = TranslateThroughDict(PlayerDictionary2, annotations1(:,5));
%Forehand/backhand
ta1(:,6) = TranslateThroughDict(PlayerDictionary3, annotations1(:,6));

s = size(annotations2);
ta2 = zeros(s(1),s(2));
for i=1:s(1),
    ta2(i,1) = str2num(annotations2{i,1});
    ta2(i,2) = str2num(annotations2{i,2});
    ta2(i,3) = str2num(annotations2{i,3});    
    ta2(i,7) = str2num(annotations2{i,7});
    ta2(i,8) = str2num(annotations2{i,8});
end;
%Shot types
ta2(:,4) = TranslateThroughDict(PlayerDictionary1, annotations2(:,4));
%Shot outcomes
ta2(:,5) = TranslateThroughDict(PlayerDictionary2, annotations2(:,5));
%Forehand/backhand
ta2(:,6) = TranslateThroughDict(PlayerDictionary3, annotations2(:,6));

squash.set1.annotations.shots.frame = ta1(:,1);
squash.set1.annotations.shots.seconds = ta1(:,2);
squash.set1.annotations.shots.shotplayer = ta1(:,3);
squash.set1.annotations.shots.shottype = ta1(:,4);
squash.set1.annotations.shots.shotoutcome = ta1(:,5);
squash.set1.annotations.shots.forehandbackhand = ta1(:,6);
squash.set1.annotations.shots.shotX = ta1(:,7);
squash.set1.annotations.shots.shotY = ta1(:,8);

squash.set2.annotations.shots.frame = ta2(:,1);
squash.set2.annotations.shots.seconds = ta2(:,2);
squash.set2.annotations.shots.shotplayer = ta2(:,3);
squash.set2.annotations.shots.shottype = ta2(:,4);
squash.set2.annotations.shots.shotoutcome = ta2(:,5);
squash.set2.annotations.shots.forehandbackhand = ta2(:,6);
squash.set2.annotations.shots.shotX = ta2(:,7);
squash.set2.annotations.shots.shotY = ta2(:,8);

squash.dictionary.phases = PhasesDictionary;
squash.dictionary.shottypedict = PlayerDictionary1;
squash.dictionary.shotoutcome = PlayerDictionary2;
squash.dictionary.forehandbackhand = PlayerDictionary3;

CVBASE06Cache.squash = squash;


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
