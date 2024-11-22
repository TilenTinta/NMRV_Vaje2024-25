%% Naloga 0: Namestitev Toolbox
clc;
close all;
clear;
run('vlfeat-0.9.21/toolbox/vl_setup')

%% ------ Naloga 2.1: Razpoznavanje objektov - test only ------ %%
% Dataset: Airplanes & Motorbikes
close all;
img = ".\Baza\airplanes\Slike\image_0118.jpg";
area = ".\Baza\airplanes\Airplanes_Side_2\annotation_0118.mat";
areaSelect = "box_coord";
image = imread(img);
picArea = load(area,areaSelect);

figure;
show_annotation(img, area);

figure;
cropped_img = imcrop(image, [picArea.box_coord(3), picArea.box_coord(1), (picArea.box_coord(4)-picArea.box_coord(3)),(picArea.box_coord(2)-picArea.box_coord(1))]); 
imshow(cropped_img);
image_conv = single(rgb2gray(image));
imshow(image_conv);

%save('filename.mat', 'var1', 'var2');  % This saves `var1` and `var2` to the file

%% ------ Naloga 2.1: Razpoznavanje objektov - bag of words ------ %%
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

% Naloži slike letal, obdelaj s sift-om in shrani
for i = 1 : length(picturesName_Airplanes)
    image = imread(fullfile(picturesName_Airplanes(i).folder, picturesName_Airplanes(i).name));
    imgAreaPath = fullfile(picturesArea_Airplanes(i).folder, picturesArea_Airplanes(i).name);
    imgArea = load(imgAreaPath,"box_coord");
    cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
    %imshow(cropped_img);
    image_conv = single(rgb2gray(cropped_img));
    [f, d] = vl_sift(image_conv);
    d_Airplanes{i} = d;
end

save('sift_Airplanes.mat', 'd_Airplanes'); % 'f_Airplanes'

% Naloži slike motorjev, obdelaj s sift-om in shrani
for i = 1 : length(picturesName_Motorbikes)
    image = imread(fullfile(picturesName_Motorbikes(i).folder, picturesName_Motorbikes(i).name));
    imgAreaPath = fullfile(picturesArea_Motorbikes(i).folder, picturesArea_Motorbikes(i).name);
    imgArea = load(imgAreaPath,"box_coord");
    cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
    %imshow(cropped_img);
    
    % Dodano ker ga ena siva slika matra
    if size(cropped_img, 3) == 3
        image_conv = single(rgb2gray(cropped_img));
    else
        image_conv = single(cropped_img);
    end

    [f, d] = vl_sift(image_conv);
    d_Motorbikes{i} = d;
end

save('sift_Motorbikes.mat', 'd_Motorbikes'); % 'f_Motorbikes'

%% Algoritem
descPlanesFile = ".\sift_Airplanes.mat";
descMotorbikesFile = ".\sift_Motorbikes.mat";

% Load descriptors
descPlanes = load(descPlanesFile, "d_Airplanes");
descPlanes = descPlanes.d_Airplanes; % če ne dobiš 1x1 strukt
descMotorbikes = load(descMotorbikesFile, "d_Motorbikes");
descMotorbikes = descMotorbikes.d_Motorbikes; % če ne dobiš 1x1 strukt

% Deli v train in test
% Planes
numPlanes = length(descPlanes);
descPlanesTrain_h = descPlanes(1:floor(numPlanes / 2))';
descPlanesTest = descPlanes((floor(numPlanes / 2) + 1):end)';

% Motorbikes
numMotorbikes = length(descMotorbikes);
descMotorbikesTrain_h = descMotorbikes(1:floor(numMotorbikes / 2))';
descMotorbikesTest = descMotorbikes((floor(numMotorbikes / 2) + 1):end)';

% Deli train
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


% Iskanje števila rojev 
roji_range = 10:15;
best_n = 0;
acc_num = 0;
for n = roji_range

    TPR = 0; 
    FPR = 0;
    %idx  
    [~, centroids] = kmeans(double(cell2mat(descTrainAll))', n, 'Replicates', 5, 'MaxIter', 1000); % Roji na osnovi train podatkov

    % Histogrami za učne podatke
    train_histograms = cell(1, numel(descTrainAll));
    
    for i = 1:numel(descTrainAll)
        des = double(descTrainAll{i});
        clusterDesc = zeros(1, size(des, 2));
        %histogram = zeros(1, n);
        for j = 1:size(des, 2)
            distances = sqrt(sum((centroids' - des(:, j)).^2, 1)); % Evklidska razdalja
            [~, centroid_min] = min(distances);
            clusterDesc(j) = centroid_min;

            % Graf %
            % bar(distances);
            % xlabel('Centroin No.');
            % ylabel('Evklidska razdalja');
            % title('Razdalja vzorca do centra');
        end
        % histogram = histcounts(clusterDesc, 1:n+1);
        % train_histograms{i} = histogram / sum(histogram);
        train_histograms{i} = histcounts(clusterDesc, 1:n+1);

        % Histogram %
        % bar(train_histograms{i});
        % xlabel('Roji');
        % ylabel('Pripadnost');
        % title('Histogram rojev');

    end

    % Histogrami za validacijske podatke
    for i = 1:numel(descValidAll)
        des = double(descValidAll{i});
        clusterDesc = zeros(1, size(des, 2));
        %histogram = zeros(1, n);
        for j = 1:size(des, 2)
            distances = sqrt(sum((centroids' - des(:, j)).^2, 1)); % Evklidska razdalja
            [~, centroid_min] = min(distances);
            clusterDesc(j) = centroid_min;
        end
        % histogram = histcounts(clusterDesc, 1:n+1);
        % val_histogram = histogram / sum(histogram);
        val_histogram = histcounts(clusterDesc, 1:n+1);

        % Preverjanje kakovosti trenutnega št. rojev
        min_d = Inf;
        min_img_ID = 0;
    
        for j = 1:size(train_histograms,2)
            train_hist = train_histograms{1,j};
            d = bhattacharyya(val_histogram, train_hist);
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
            FPR = FPR + 1; % Napačne
        end
    end

    if (TPR / size(descValidAll, 2)) > acc_num
        acc_num = TPR / size(descValidAll, 2);
        best_n = n;
    end

    fprintf("///////////////////////////////////\n");
    fprintf("Število Rojev: %d [Best roj: %d]\n", n, best_n);
    fprintf("TPR: %.2f\n", TPR / size(descValidAll, 2));
    fprintf("FPR: %.2f\n", FPR / size(descValidAll, 2));
    fprintf("///////////////////////////////////\n");
    
end

fprintf("Najboljše število rojev: %d\n", best_n);


% % --- Validacija testne množice --- % %
TPR = 0; 
FPR = 0;
  
[idx, centroids] = kmeans(double(cell2mat(descTrainAll))', best_n, 'Replicates', 5, 'MaxIter', 1000); % Roji na osnovi train podatkov

% Histogrami za učne podatke
train_histograms = cell(1, numel(descTrainAll));

for i = 1:numel(descTrainAll)
    des = double(descTrainAll{i});
    clusterDesc = zeros(1, size(des, 2));
    %histogram = zeros(1, best_n);
    for j = 1:size(des, 2)
        distances = sqrt(sum((centroids' - des(:, j)).^2, 1)); % Evklidska razdalja
        [~, centroid_min] = min(distances);
        clusterDesc(j) = centroid_min;
    end
    % histogram = histcounts(clusterDesc, 1:n+1);
    % train_histograms{i} = histogram / max(histogram);
    train_histograms{i} = histcounts(clusterDesc, 1:n+1);
end

% Histogrami za testne podatke
for i = 1:numel(descTestAll)
    des = double(descTestAll{i});
    clusterDesc = zeros(1, size(des, 2));
    %histogram = zeros(1, best_n);
    for j = 1:size(des, 2)
        distances = sqrt(sum((centroids' - des(:, j)).^2, 1)); % Evklidska razdalja
        [~, centroid_min] = min(distances);
        clusterDesc(j) = centroid_min;
    end
    % histogram = histcounts(clusterDesc, 1:n+1);
    % test_histogram = histogram / sum(histogram);
    test_histogram = histcounts(clusterDesc, 1:n+1);


    % Preverjanje kakovosti razpoznavanja
    min_d = Inf;
    min_img_ID = 0;

    for j = 1:size(train_histograms,2)
        train_hist = train_histograms{1,j};
        d = bhattacharyya(test_histogram, train_hist);
        if d < min_d
            min_d = d;
            min_img_ID = j;
        end
    end

    if (min_img_ID <= 200) && (i <= 400) % Letala
        TPR = TPR + 1;

        % Prikaz slike s sift deskriptorji (ni najboljše ampak nimam original lokacij zato računam nove)
        % image = imread(fullfile(picturesName_Airplanes(i).folder, picturesName_Airplanes(i).name));
        % imgAreaPath = fullfile(picturesArea_Airplanes(i).folder, picturesArea_Airplanes(i).name);
        % imgArea = load(imgAreaPath,"box_coord");
        % cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
        % imshow(cropped_img);
        % if size(cropped_img, 3) == 3
        %     image_conv = single(rgb2gray(cropped_img));
        % else
        %     image_conv = single(cropped_img);
        % end
        % [f, d] = vl_sift(image_conv);
        % hold on;
        % perm = randperm(size(f,2));
        % sel = perm(1:50);
        % h1 = vl_plotframe(f(:,sel));
        % h2 = vl_plotframe(f(:,sel));
        % set(h1,'color','k','linewidth',3);
        % set(h2,'color','y','linewidth',2);
        % h3 = vl_plotsiftdescriptor(d(:,sel),f(:,sel));
        % set(h3,'color','g');
        % hold off;

    elseif (min_img_ID > 200) && (i > 400) % Motorji
        TPR = TPR + 1;
    
        % Prikaz slike s sift deskriptorji (ni najboljše ampak nimam original lokacij zato računam nove)
        % image = imread(fullfile(picturesName_Motorbikes(i).folder, picturesName_Motorbikes(i).name));
        % imgAreaPath = fullfile(picturesArea_Motorbikes(i).folder, picturesArea_Motorbikes(i).name);
        % imgArea = load(imgAreaPath,"box_coord");
        % cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
        % imshow(cropped_img);
        % if size(cropped_img, 3) == 3
        %     image_conv = single(rgb2gray(cropped_img));
        % else
        %     image_conv = single(cropped_img);
        % end
        % [f, d] = vl_sift(image_conv);
        % hold on;
        % perm = randperm(size(f,2));
        % sel = perm(1:50);
        % h1 = vl_plotframe(f(:,sel));
        % h2 = vl_plotframe(f(:,sel));
        % set(h1,'color','k','linewidth',3);
        % set(h2,'color','y','linewidth',2);
        % h3 = vl_plotsiftdescriptor(d(:,sel),f(:,sel));
        % set(h3,'color','g');
        % hold off;

    else
        FPR = FPR + 1;

        % Prikaz slike s sift deskriptorji (ni najboljše ampak nimam original lokacij zato računam nove)
        % if i <= 200
        %     image = imread(fullfile(picturesName_Airplanes(i).folder, picturesName_Airplanes(i).name));
        %     imgAreaPath = fullfile(picturesArea_Airplanes(i).folder, picturesArea_Airplanes(i).name);
        % else
        %     image = imread(fullfile(picturesName_Motorbikes(i).folder, picturesName_Motorbikes(i).name));
        %     imgAreaPath = fullfile(picturesArea_Motorbikes(i).folder, picturesArea_Motorbikes(i).name);
        % end
        %     imgArea = load(imgAreaPath,"box_coord");
        %     cropped_img = imcrop(image, [imgArea.box_coord(3), imgArea.box_coord(1), (imgArea.box_coord(4) - imgArea.box_coord(3)), (imgArea.box_coord(2) - imgArea.box_coord(1))]); 
        %     imshow(cropped_img);
        %     if size(cropped_img, 3) == 3
        %         image_conv = single(rgb2gray(cropped_img));
        %     else
        %         image_conv = single(cropped_img);
        %     end
        %     [f, d] = vl_sift(image_conv);
        %     hold on;
        %     perm = randperm(size(f,2));
        %     sel = perm(1:50);
        %     h1 = vl_plotframe(f(:,sel));
        %     h2 = vl_plotframe(f(:,sel));
        %     set(h1,'color','k','linewidth',3);
        %     set(h2,'color','y','linewidth',2);
        %     h3 = vl_plotsiftdescriptor(d(:,sel),f(:,sel));
        %     set(h3,'color','g');
        %     hold off;
    end
end

fprintf("///////////////////////////////////\n");
fprintf("Rezultat na testni množici pri %d rojih:\n", best_n);
fprintf("TPR: %.3f\n", double(TPR / size(descTestAll, 2)));
fprintf("FPR: %.3f\n", double(FPR / size(descTestAll, 2)));
fprintf("///////////////////////////////////\n");
