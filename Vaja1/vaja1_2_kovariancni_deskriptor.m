%% Naloga 0: Namestitev Toolbox
clc;
close all;
clear;
run('vlfeat-0.9.21/toolbox/vl_setup')

%% ------ Naloga 2.3: Razpoznavanje objektov - kovariančni deskriptor ------ %%
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

% Algoritem

% Iskanje kovariančnega deskriptorja
d_Airplanes = cell(length(picturesArea_Airplanes), 1);
d_Motorbikes = cell(length(picturesArea_Motorbikes), 1);

for i = 1 : length(picturesName_Airplanes)
    image = imread(fullfile(picturesName_Airplanes(i).folder, picturesName_Airplanes(i).name));
    imgAreaPath = fullfile(picturesArea_Airplanes(i).folder, picturesArea_Airplanes(i).name);
    imgArea = load(imgAreaPath,"box_coord");
    cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
    %imshow(cropped_img);

    % Iz Perš & Murovec kode
    I = single(cropped_img);

    % Matrike za odvajanje
    f1 = [-1 0 1];
    f2 = [-1 2 -1];
    
    % Konverzija slike v sivinsko (čene da error)
    if size(I, 3) == 3
        image_conv = single(rgb2gray(I));
    else
        image_conv = single(I);
    end
    
    % Računanje odvodov (same ti poda enako velikost matrike kot je slika)
    Ix = conv2(image_conv, f1, 'same');
    Iy = conv2(image_conv, f1', 'same');
    Ixx = conv2(image_conv, f2, 'same');
    Iyy = conv2(image_conv, f2', 'same');
    
    % Loči vsako barvo posebej in jih da v vektor
    if size(cropped_img, 3) == 3
        R = cropped_img(:, :, 1);
        G = cropped_img(:, :, 2);
        B = cropped_img(:, :, 3);
    else
        R = cropped_img;
        G = cropped_img;
        B = cropped_img;
    end
    
    R = double(R(:));
    G = double(G(:));
    B = double(B(:));
    If = [R,G,B];

    % Dimenzije slike
    [height, width, ~] = size(I);

    % Koordinate slike
    [X, Y] = meshgrid(1:width, 1:height);
    X = X(:);
    Y = Y(:);
    Ix = Ix(:);
    Iy = Iy(:);
    Ixx = Ixx(:);
    Iyy = Iyy(:);

    % Naredi F matriko
    F = [If, X, Y, Ix, Iy, Ixx, Iyy];

    % Konvoluciska matrika 
    C = cov(F);

    d_Airplanes{i} = C;
end


for i = 1 : length(picturesName_Motorbikes)
    image = imread(fullfile(picturesName_Motorbikes(i).folder, picturesName_Motorbikes(i).name));
    imgAreaPath = fullfile(picturesArea_Motorbikes(i).folder, picturesArea_Motorbikes(i).name);
    imgArea = load(imgAreaPath,"box_coord");
    cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
    %imshow(cropped_img);
    
    % Iz Perš & Murovec kode
    I = single(cropped_img);

    % Matrike za odvajanje
    f1 = [-1 0 1];
    f2 = [-1 2 -1];
    
    % Konverzija slike v sivinsko (čene da error)
    if size(I, 3) == 3
        image_conv = single(rgb2gray(I));
    else
        image_conv = single(I);
    end
    
    % Računanje odvodov (same ti poda enako velikost matrike kot je slika)
    Ix = conv2(image_conv, f1, 'same');
    Iy = conv2(image_conv, f1', 'same');
    Ixx = conv2(image_conv, f2, 'same');
    Iyy = conv2(image_conv, f2', 'same');
    
    % Loči vsako barvo posebej in jih da v en vektor
    if size(cropped_img, 3) == 3
        R = cropped_img(:, :, 1);
        G = cropped_img(:, :, 2);
        B = cropped_img(:, :, 3);
    else
        R = cropped_img;
        G = cropped_img;
        B = cropped_img;
    end
    
    R = double(R(:));
    G = double(G(:));
    B = double(B(:));
    If = [R,G,B];

    % Dimenzije slike
    [height, width, ~] = size(I);

    % Koordinate slike
    [X, Y] = meshgrid(1:width, 1:height);
    X = X(:);
    Y = Y(:);
    Ix = Ix(:);
    Iy = Iy(:);
    Ixx = Ixx(:);
    Iyy = Iyy(:);

    % Naredi F matriko
    F = [If, X, Y, Ix, Iy, Ixx, Iyy];

    % Konvoluciska matrika 
    C = cov(F);

    d_Motorbikes{i} = C;
end
    
descPlanes = d_Airplanes;
descMotorbikes = d_Motorbikes;

% Deljenje slik v množice
% Planes
numPlanes = length(descPlanes);
descPlanesTrain_h = descPlanes(1:floor(numPlanes / 2))';
descPlanesTest = descPlanes((floor(numPlanes / 2) + 1):end)';

% Motorbikes
numMotorbikes = length(descMotorbikes);
descMotorbikesTrain_h = descMotorbikes(1:floor(numMotorbikes / 2))';
descMotorbikesTest = descMotorbikes((floor(numMotorbikes / 2) + 1):end)';

% Planes
numPlanes = length(descPlanesTrain_h);
descPlanesTrain = descPlanesTrain_h(1:floor(numPlanes / 2));
descPlanesValid = descPlanesTrain_h((floor(numPlanes / 2) + 1):end);

% Motorbikes
numMotorbikes = length(descMotorbikesTrain_h);
descMotorbikesTrain = descMotorbikesTrain_h(1:floor(numMotorbikes / 2));
descMotorbikesValid = descMotorbikesTrain_h((floor(numMotorbikes / 2) + 1):end);

% Združevanje letal in motorjev
descTrainAll = [descPlanesTrain descMotorbikesTrain];
descValidAll = [descPlanesValid descMotorbikesValid];
descTestAll = [descPlanesTest descMotorbikesTest];

% --- Testna množica ---
TPR = 0; 
FPR = 0;

for i = 1:numel(descTestAll)
    
    % Preverjanje kakovosti
    min_d = Inf;
    min_img_ID = 0;

    for j = 1:size(descTrainAll,2)
        train_desc = descTrainAll{1,j};
        test_desc = descTestAll{1,i};
        d = sqrt(sum(log(eig(test_desc, train_desc)).^2)); % Iz Perš & Murovec kode
        if d < min_d
            min_d = d;
            min_img_ID = j;
        end
    end

    if (min_img_ID <= 200) && (i <= 400) % Letala
        TPR = TPR + 1;
    elseif (min_img_ID > 200) && (i > 400) % Motorji
        TPR = TPR + 1;
    else
        FPR = FPR + 1;
    end
end

fprintf("////////////////////////////////////////////////////\n");
fprintf("Rezultat na testni množici [Kovariančni deskriptor]:\n");
fprintf("TPR: %.3f\n", double(TPR / size(descTestAll, 2)));
fprintf("FPR: %.3f\n", double(FPR / size(descTestAll, 2)));
fprintf("////////////////////////////////////////////////////\n");


