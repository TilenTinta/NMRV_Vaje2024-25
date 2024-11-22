%% Naloga 0: Namestitev Toolbox
clc;
close all;
clear;
run('vlfeat-0.9.21/toolbox/vl_setup')

%% ------ Naloga 2.2: Razpoznavanje objektov - HOG ------ %%
% Računanje deskriptorjev -> .mat
% Airplanes [800 slik]:
%  - Learn/Learn: 200 slik
%  - Learn/Tune: 200 slik
%  - Test: 400 slik
picturesDir_Airplanes = ".\Baza\airplanes\Slike\";                              % pot do slik
picturesAreaDir_Airplanes = ".\Baza\airplanes\Airplanes_Side_2\";               % pot do oznak slik
picturesName_Airplanes = dir(fullfile(picturesDir_Airplanes, '*.jpg'));         % pridobi seznam slik
picturesArea_Airplanes = dir(fullfile(picturesAreaDir_Airplanes, '*.mat'));     % pridobi seznam oznak slik

% Motorbikes [398 slik]:
%  - Learn/Learn: 200 slik
%  - Learn/Tune: 199 slik
%  - Test: 399 slik
picturesDir_Motorbikes = ".\Baza\Motorbikes\Slike\";                            % pot do slik
picturesAreaDir_Motorbikes = ".\Baza\Motorbikes\Motorbikes_16\";                % pot do oznak slik
picturesName_Motorbikes = dir(fullfile(picturesDir_Motorbikes, '*.jpg'));       % pridobi seznam slik
picturesArea_Motorbikes = dir(fullfile(picturesAreaDir_Motorbikes, '*.mat'));   % pridobi seznam oznak slik

d_Airplanes = cell(length(picturesArea_Airplanes), 1);
d_Motorbikes = cell(length(picturesArea_Motorbikes), 1);

% Povprečna velikost - Letala
visina_Letala = 0;
sirina_Letala = 0;
for i = 1 : length(picturesName_Airplanes)
    imgAreaPath = fullfile(picturesArea_Airplanes(i).folder, picturesArea_Airplanes(i).name);
    imgArea = load(imgAreaPath,"box_coord");
    sirina_Letala = sirina_Letala + (imgArea.box_coord(4) - imgArea.box_coord(3));
    visina_Letala = visina_Letala + (imgArea.box_coord(2) - imgArea.box_coord(1));
end
sirina_Letala = round(sirina_Letala / length(picturesName_Airplanes));
visina_Letala = round(visina_Letala / length(picturesName_Airplanes));

% Povprečna velikost - Motorji
visina_Moto = 0;
sirina_Moto = 0;
for i = 1 : length(picturesName_Motorbikes)
    imgAreaPath = fullfile(picturesArea_Motorbikes(i).folder, picturesArea_Motorbikes(i).name);
    imgArea = load(imgAreaPath,"box_coord");
    sirina_Moto = sirina_Moto + (imgArea.box_coord(4) - imgArea.box_coord(3));
    visina_Moto = visina_Moto + (imgArea.box_coord(2) - imgArea.box_coord(1));
end
sirina_Moto = round(sirina_Moto / length(picturesName_Motorbikes));
visina_Moto = round(visina_Moto / length(picturesName_Motorbikes));

% Povprečna višina in širina obrezanega območja slike
sirina_avg = round((sirina_Letala + sirina_Moto) / 2);
visina_avg = round((visina_Letala + visina_Moto) / 2);

velikost = [visina_avg, sirina_avg];

% Algoritem

% Iskanje števila optimalnega cell siza
roji_range = [4,6,8,12,16];
best_n = 0;
acc_num = 0;

for n = roji_range

    for i = 1 : length(picturesName_Airplanes)
        image = imread(fullfile(picturesName_Airplanes(i).folder, picturesName_Airplanes(i).name));
        imgAreaPath = fullfile(picturesArea_Airplanes(i).folder, picturesArea_Airplanes(i).name);
        imgArea = load(imgAreaPath,"box_coord");
        cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
        %imshow(cropped_img);
        rescaledImage = imresize(cropped_img, velikost);
        
        % Dodano ker ga ena siva slika matra
        if size(cropped_img, 3) == 3
            image_conv = single(rgb2gray(rescaledImage));
        else
            image_conv = single(rescaledImage);
        end
        hog_d = vl_hog(image_conv, n);
        % HOG: gradient računan na celi sliki v x in y smeri, smeri
        % gradientov so grupirane v bine (odvisno od nastavitev, default 9), bloki se
        % normalizirajo da je neobčutlivo na osvetlitev
        d_Airplanes{i} = hog_d;

        % Prikaz HOG-a na slikah %
        % hogImage = vl_hog('render', hog_d);
        % hogImageResized = imresize(hogImage, size(image_conv(:,:,1))); % Predelava HOG-a da paše na sliko
        % overlayImage = imfuse(image_conv, hogImageResized, 'blend'); % Dodaj original sliko
        % figure;
        % imshow(overlayImage);
        % title('Original Image with HOG Overlay');


    end
    %save('hog_Airplanes.mat', 'd_Airplanes');
    
    for i = 1 : length(picturesName_Motorbikes)
        image = imread(fullfile(picturesName_Motorbikes(i).folder, picturesName_Motorbikes(i).name));
        imgAreaPath = fullfile(picturesArea_Motorbikes(i).folder, picturesArea_Motorbikes(i).name);
        imgArea = load(imgAreaPath,"box_coord");
        cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
        %imshow(cropped_img);
        rescaledImage = imresize(cropped_img, velikost);
        
        % Dodano ker ga ena siva slika matra
        if size(cropped_img, 3) == 3
            image_conv = single(rgb2gray(rescaledImage));
        else
            image_conv = single(rescaledImage);
        end
        
        hog_d = vl_hog(image_conv, n);
        d_Motorbikes{i} = hog_d;
    end
    %save('hog_Motorbikes.mat', 'd_Motorbikes');
    
    descPlanes = d_Airplanes;
    descMotorbikes = d_Motorbikes;
    
    % Deli v train in test
    % Planes
    numPlanes = length(descPlanes);
    descPlanesTrain_h = descPlanes(1:floor(numPlanes / 2))';
    descPlanesTest = descPlanes((floor(numPlanes / 2) + 1):end)';
    
    % Motorbikes
    numMotorbikes = length(descMotorbikes);
    descMotorbikesTrain_h = descMotorbikes(1:floor(numMotorbikes / 2))';
    descMotorbikesTest = descMotorbikes((floor(numMotorbikes / 2) + 1):end)';
    
    % Teli train
    % Planes
    numPlanes = length(descPlanesTrain_h);
    descPlanesTrain = descPlanesTrain_h(1:floor(numPlanes / 2));
    descPlanesValid = descPlanesTrain_h((floor(numPlanes / 2) + 1):end);
    
    % Motorbikes
    numMotorbikes = length(descMotorbikesTrain_h);
    descMotorbikesTrain = descMotorbikesTrain_h(1:floor(numMotorbikes / 2));
    descMotorbikesValid = descMotorbikesTrain_h((floor(numMotorbikes / 2) + 1):end);
    
    % Združevanje letal in motorjev ter predelamo obliko zapisa
    descTrainAll = [descPlanesTrain descMotorbikesTrain];   
    descValidAll = [descPlanesValid descMotorbikesValid];    
    descTestAll = [descPlanesTest descMotorbikesTest];

    TPR = 0; 
    FPR = 0;

    % Histogrami za validacijske podatke
    for i = 1:numel(descValidAll)
        
        % Preverjanje kakovosti trenutnega št. cell siza
        min_d = Inf;
        min_img_ID = 0;
    
        for j = 1:size(descTrainAll,2)
            train_desc = descTrainAll{1,j};
            val_desc = descValidAll{1,i};
            d = sqrt(sum((val_desc - train_desc).^2,'all'));
            if d < min_d
                min_d = d;
                min_img_ID = j;
            end
        end
    
        if (min_img_ID <= 200) && (i <= 200) % Letala
            TPR = TPR + 1;
        elseif (min_img_ID > 200) && (i > 200) % Motorji
            TPR = TPR + 1;
        else
            FPR = FPR + 1;
        end
    end

    if (TPR / size(descValidAll, 2)) > acc_num
        acc_num = TPR / size(descValidAll, 2);
        best_n = n;
    end

    fprintf("///////////////////////////////////\n");
    fprintf("Število celic: %d [Best celice: %d]\n", n, best_n);
    fprintf("TPR: %.2f\n", TPR / size(descValidAll, 2));
    fprintf("FPR: %.2f\n", FPR / size(descValidAll, 2));
    fprintf("///////////////////////////////////\n");
    
end

fprintf("Najboljše število celic: %d\n", best_n);


% % --- Validacija testne množice --- % %
TPR = 0; 
FPR = 0;

for i = 1 : length(picturesName_Airplanes)
    image = imread(fullfile(picturesName_Airplanes(i).folder, picturesName_Airplanes(i).name));
    imgAreaPath = fullfile(picturesArea_Airplanes(i).folder, picturesArea_Airplanes(i).name);
    imgArea = load(imgAreaPath,"box_coord");
    cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
    %imshow(cropped_img);
    rescaledImage = imresize(cropped_img, velikost);
    
    % Dodano ker ga ena siva slika matra
    if size(cropped_img, 3) == 3
        image_conv = single(rgb2gray(rescaledImage));
    else
        image_conv = single(rescaledImage);
    end
    hog_d = vl_hog(image_conv, best_n);
    d_Airplanes{i} = hog_d;
end
%save('hog_Airplanes.mat', 'd_Airplanes');

for i = 1 : length(picturesName_Motorbikes)
    image = imread(fullfile(picturesName_Motorbikes(i).folder, picturesName_Motorbikes(i).name));
    imgAreaPath = fullfile(picturesArea_Motorbikes(i).folder, picturesArea_Motorbikes(i).name);
    imgArea = load(imgAreaPath,"box_coord");
    cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
    %imshow(cropped_img);
    rescaledImage = imresize(cropped_img, velikost);
    
    % Dodano ker ga ena siva slika matra
    if size(cropped_img, 3) == 3
        image_conv = single(rgb2gray(rescaledImage));
    else
        image_conv = single(rescaledImage);
    end
    
    hog_d = vl_hog(image_conv, best_n);
    d_Motorbikes{i} = hog_d;
end
%save('hog_Motorbikes.mat', 'd_Motorbikes');
    
descPlanes = d_Airplanes;
descMotorbikes = d_Motorbikes;

% Split into train and test sets
% Planes
numPlanes = length(descPlanes);
descPlanesTrain_h = descPlanes(1:floor(numPlanes / 2))';
descPlanesTest = descPlanes((floor(numPlanes / 2) + 1):end)';

% Motorbikes
numMotorbikes = length(descMotorbikes);
descMotorbikesTrain_h = descMotorbikes(1:floor(numMotorbikes / 2))';
descMotorbikesTest = descMotorbikes((floor(numMotorbikes / 2) + 1):end)';

% Split training set into training and calibration sets
% Planes
numPlanes = length(descPlanesTrain_h);
descPlanesTrain = descPlanesTrain_h(1:floor(numPlanes / 2));
descPlanesValid = descPlanesTrain_h((floor(numPlanes / 2) + 1):end);

% Motorbikes
numMotorbikes = length(descMotorbikesTrain_h);
descMotorbikesTrain = descMotorbikesTrain_h(1:floor(numMotorbikes / 2));
descMotorbikesValid = descMotorbikesTrain_h((floor(numMotorbikes / 2) + 1):end);

% Združevanje letal in motorjev ter predelamo obliko zapisa
descTrainAll = [descPlanesTrain descMotorbikesTrain];
descValidAll = [descPlanesValid descMotorbikesValid];
descTestAll = [descPlanesTest descMotorbikesTest];

% Preverjanje za testne podatke
for i = 1:numel(descTestAll)
    
    % Preverjanje kakovosti trenutnega št. cell siza
    min_d = Inf;
    min_img_ID = 0;

    for j = 1:size(descTrainAll,2)
        train_desc = descTrainAll{1,j};
        test_desc = descTestAll{1,i};
        d = sqrt(sum((test_desc - train_desc).^2,'all'));
        if d < min_d
            min_d = d;
            min_img_ID = j;
        end
    end


    if (min_img_ID <= 200) && (i <= 400) % Letala
        TPR = TPR + 1;
        % image = imread(fullfile(picturesName_Airplanes(i).folder, picturesName_Airplanes(i).name));
        % imgAreaPath = fullfile(picturesArea_Airplanes(i).folder, picturesArea_Airplanes(i).name);
        % imgArea = load(imgAreaPath,"box_coord");
        % cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
        % imshow(cropped_img);
    elseif (min_img_ID > 200) && (i > 400) % Motorji
        TPR = TPR + 1;
        % image = imread(fullfile(picturesName_Motorbikes(i).folder, picturesName_Motorbikes(i).name));
        % imgAreaPath = fullfile(picturesArea_Motorbikes(i).folder, picturesArea_Motorbikes(i).name);
        % imgArea = load(imgAreaPath,"box_coord");
        % cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
        % imshow(cropped_img);
    else
        FPR = FPR + 1;
        if i <= 200
            image = imread(fullfile(picturesName_Airplanes(i).folder, picturesName_Airplanes(i).name));
            imgAreaPath = fullfile(picturesArea_Airplanes(i).folder, picturesArea_Airplanes(i).name);
        else
            image = imread(fullfile(picturesName_Motorbikes(i).folder, picturesName_Motorbikes(i).name));
            imgAreaPath = fullfile(picturesArea_Motorbikes(i).folder, picturesArea_Motorbikes(i).name);
        end
            imgArea = load(imgAreaPath,"box_coord");
            cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
            imshow(cropped_img);
    end
end

fprintf("///////////////////////////////////\n");
fprintf("Rezultat na testni množici pri %d velikih celicah:\n", best_n);
fprintf("TPR: %.3f\n", double(TPR / size(descTestAll, 2)));
fprintf("FPR: %.3f\n", double(FPR / size(descTestAll, 2)));
fprintf("///////////////////////////////////\n");

