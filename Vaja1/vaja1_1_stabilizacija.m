%% Naloga 0: Namestitev Toolbox
clc;
close all;
clear;
run('vlfeat-0.9.21/toolbox/vl_setup')

%% Naloga 1: Stabilizacija videa
clc;
close all;
clear;

videoShake = VideoReader("shaking.avi");
picVideo = read(videoShake, 1); % Prvi frame
video = read(videoShake,[2 inf]); % Ostali frami
frameNo = videoShake.NumFrames; % St. framov
picSize = imref2d(size(picVideo)); % Nastavi velikost slike
% figure;
% imshow(slikaVideo)
% hold on;

% Izračun za prvi frame %
I = single(rgb2gray(picVideo)); % Pretvori v sivinsko v float

% f1(1,:) - x koordinata
% f1(2,:) - y koordinata
% f1(3,:) - scale/zoom
% f1(4,:) - orientacija (invariantnost na rotacijo)
% d1 - gradient (128bit): 4x4 celice vsaka ima histogram z 8 bini o
% orientaciji gradienta, normalizirani (bolj robustno za spremembe osvetlitve)

% gausov filter blura , več layerjev, išče kaj je na veš layerjih, išče
% ostre spremembe (rob, vogal...). za določit išče 26 sosedov (8 na
% trenutnem layerju, 9 nad njim, 9 pod njim), zbriše jih glede na prag, z
% računanjem gradienta določi orientacijo, 
[f1,d1] = vl_sift(I); 

% perm = randperm(size(f1,2));
% sel = perm(1:50);
% h1 = vl_plotframe(f(:,sel));
% h2 = vl_plotframe(f(:,sel));
% set(h1,'color','k','linewidth',3);
% set(h2,'color','y','linewidth',2);
% h3 = vl_plotsiftdescriptor(d(:,sel),f(:,sel));
% set(h3,'color','g');
% hold off;

endVideo = uint8(zeros(picSize.ImageSize(1),picSize.ImageSize(2),3,frameNo)); % array za shranjevanje videa
endVideo(:,:,:,1) = picVideo; % Shrani prvi frame

% Računanje za ostale frame
for i = 2 : frameNo-1

    frame = video(:,:,:,i); 
    Ii = single(rgb2gray(frame));
    [fi, di] = vl_sift(Ii) ; % fi: x, y, scale, rotacija
    
    % matches - katera točka s slike 1 se vjema s katero na sliki 2
    % scores - cenilka podobnost med točkami
    [matches, scores] = vl_ubcmatch(d1, di); % measured by the L2 norm of the difference between them

    % koordinate točk ki spadajo skupaj, ' - transponirano
    points1 = f1(1:2, matches(1,:))';  
    points2 = fi(1:2, matches(2,:))'; 
    
    % Računanje transformacije
    % (premikajoče točke, fiksne točke, način iskanja)
    % tform - transformacijska matrika
    % inlinerIdx - točke ki ostanejo po ransac-u, outlinerji so izločeni
    [tform, inlierIdx] = estimateGeometricTransform(points2, points1, 'affine'); % Tone: Affine transformations include translation, rotation, scaling, and shearing, and they preserve lines and parallelism

    % Transformacija
    % frame - frame videa
    % tform - transformacija pridobljena zgorej
    % OutputView - da velikost slike ohrani
    % picSize - velikost slike
    tranFramei = imwarp(frame, tform, 'OutputView', picSize);
   
    % figure;
    % subplot(1, 2, 1); imshow(picVideo); title("Prvi");
    % subplot(1, 2, 2); imshow(tranFramei); title("Transformiran");
   
    endVideo(:,:,:,i) = tranFramei;
end

%implay(endVideo);

% Shrani sliko
v = VideoWriter("StabiliziranVideo.avi");
open(v);
for i = 1:frameNo
    frame = endVideo(:, :, :, i);
    writeVideo(v, frame);
end
close(v);