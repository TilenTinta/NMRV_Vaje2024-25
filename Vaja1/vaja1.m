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
size = imref2d(size(picVideo)); % Nastavi velikost slike
% figure;
% imshow(slikaVideo)
% hold on;

% Izračun za prvi frame %
I = single(rgb2gray(picVideo)); % Pretvori v sivinsko v float

% f1(1,:) - x koordinata
% f1(2,:) - y koordinata
% f1(3,:) - scale/zoom
% f1(4,:) - orientacija (invariantnost na rotacijo)
% d1 - gradient (128bit)
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

endVideo = uint8(zeros(size.ImageSize(1),size.ImageSize(2),3,frameNo)); % array za shranjevanje videa
endVideo(:,:,:,1) = picVideo; % Shrani prvi frame

% Računanje za ostale frame
for i = 2 : frameNo-1

    frame = video(:,:,:,i); 
    Ii = single(rgb2gray(frame));
    [fi, di] = vl_sift(Ii) ;
    
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
    [tform, inlierIdx] = estimateGeometricTransform(points2, points1, 'similarity');

    % Transformacija
    tranFramei = imwarp(frame, tform, 'OutputView', size);
   
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

%% ------ Naloga 2.1: Razpoznavanje objektov - test only ------ %%
% Dataset: Airplanes & Motorbikes
close all;
image = imread(".\Baza\airplanes\Learn\Learn\image_0001.jpg");
picArea = load(".\Baza\airplanes\Airplanes_Side_2\annotation_0001.mat","box_coord");

figure;
show_annotation(".\Baza\airplanes\Learn\Learn\image_0001.jpg", ".\Baza\airplanes\Airplanes_Side_2\annotation_0001.mat");

figure;
cropped_img = imcrop(image, [picArea.box_coord(3), picArea.box_coord(1), (picArea.box_coord(4)-picArea.box_coord(3)),(picArea.box_coord(2)-picArea.box_coord(1))]); 
imshow(cropped_img);

%save('filename.mat', 'var1', 'var2');  % This saves `var1` and `var2` to the file

%% ------ Naloga 2.1: Razpoznavanje objektov - bag of words ------ %%
% Računanje deskriptorjev -> .mat
% Airplanes:
%  - Learn/Learn: 200 slik
%  - Learn/Tune: 200 slik
%  - Test: 400 slik
picturesDir_Airplanes = ".\Baza\airplanes\Slike\";                              % pot do slik
picturesAreaDir_Airplanes = ".\Baza\airplanes\Airplanes_Side_2\";               % pot do oznak slik
picturesName_Airplanes = dir(fullfile(picturesDir_Airplanes, '*.jpg'));         % pridobi seznam slik
picturesArea_Airplanes = dir(fullfile(picturesAreaDir_Airplanes, '*.mat'));     % pridobi seznam oznak slik

% Motorbikes:
%  - Learn/Learn: 200 slik
%  - Learn/Tune: 199 slik
%  - Test: 399 slik
picturesDir_Motorbikes = ".\Baza\Motorbikes\Slike\";                            % pot do slik
picturesAreaDir_Motorbikes = ".\Baza\Motorbikes\Motorbikes_16\";                % pot do oznak slik
picturesName_Motorbikes = dir(fullfile(picturesDir_Motorbikes, '*.jpg'));       % pridobi seznam slik
picturesArea_Motorbikes = dir(fullfile(picturesAreaDir_Motorbikes, '*.mat'));   % pridobi seznam oznak slik



image = imread(fullfile(picturesName_Airplanes(1).folder, picturesName_Airplanes(1).name));
imgArea = fullfile(picturesArea_Airplanes(1).folder, picturesArea_Airplanes(1).name);
cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
imshow(cropped_img);
image_conv = single(rgb2gray(image));
[f, d] = vl_sift(image_conv);



%% Algoritem



%% ------ Naloga 2.2: Razpoznavanje objektov - HOG ------ %%
% Računanje deskriptorjev -> .mat


%% Algoritem




%% ------ Naloga 2.3: Razpoznavanje objektov - kovariančni deskriptor ------ %%
% Računanje deskriptorjev -> .mat


%% Algoritem



