%% Vaja 2.1 - teorija %%
close all;
clear;
clc;
addpath("cvbase06dataset\cvbase06dataset\matlab\")
addpath("cvbase06dataset\cvbase06dataset\handball\")

%% Vaja 2.2 - priprava podatkov %%

CVBASE06HandballInit('cvbase06dataset'); % init pozicij

% Pridobi trajektorije
num_players = 7; 
trajectories = cell(1, num_players);

for playerNum = 1:num_players
    [X, Y, ~, ~, ~, ~, ~] = CVBASE06HandballGetPos(playerNum); % zanima nas samo x in y (anonimizacija)
    trajectories{playerNum} = [X, Y]; % shrani
end

% Prikaži trajektorije - funkcija
CVBASE06HandballShowTrajectories();

% Prikaži trajektorije - plot
figure;
hold on;
title('Trajektorije igralcev - moj plot');
xlabel('X Kordinate (m)');
ylabel('Y Kordinate (m)');
grid on;

for playerNum = 1:num_players
    traj = trajectories{playerNum};
    plot(traj(:, 1), traj(:, 2), 'LineWidth', 0.5);
end

legend(arrayfun(@(x) sprintf('Igralec %d', x), 1:num_players, 'UniformOutput', false), 'Location', 'best');
hold off;

% Zlati standard / vrednosti direkt iz fila
golden_standard = trajectories;

%% Vaja 2.2 - pošumljanje podatkov %%

mu = [0,0]; % Mean (center v obeh oseh)
sigma = [0.1 0.05; 0.05 0.1]; % kavariančna matrika (1.1 in 2.2 sta "širini šuma", 1.2 in 2.1 pa korelacija)

R = chol(sigma); % dekompozicija Cholesky 

trajectories_noisy = cell(1, num_players); % Pošumljeni podatki

for playerNum = 1:num_players
    traj = trajectories{playerNum};
    %noise = repmat(mu, size(traj, 1), 1) + randn(size(traj,1),2) * R;
    noise = repmat(mu, size(traj, 1), 1) + (randn(size(traj, 1), 2) * R);
    trajectories_noisy{playerNum} = traj + noise;
end

% Nariši pošumnjenje trajektorije
figure;
hold on;
title('Trajektorije igralcev z Gaussovim šumom');
xlabel('X Kordinate (m)');
ylabel('Y Kordinate (m)');
grid on;

for playerNum = 1:num_players
    noisy_traj = trajectories_noisy{playerNum};
    plot(noisy_traj(:, 1), noisy_traj(:, 2), 'LineWidth', 0.5);
end

legend(arrayfun(@(x) sprintf('Igralec %d', x), 1:num_players, 'UniformOutput', false), 'Location', 'best');
hold off;




%%  Vaja 2.4 - Optimalno prirejanje %%

reconstructed_trajectories = cell(1, num_players);

% Pobere prve koordinate igralcev
for playerNum = 1:num_players
    reconstructed_trajectories{playerNum} = trajectories_noisy{playerNum}(1, :); % trajectories_noisy
end

% Hungarian algoritem
num_time_steps = size(golden_standard{1}, 1);

for t = 2:num_time_steps
    % Vzamem prejšnje koordinate igralcev - vsako iteracijo se spremenijo
    previous_positions = zeros(num_players, 2);
    for playerNum = 1:num_players
        previous_positions(playerNum, :) = reconstructed_trajectories{playerNum}(end, :);
    end

    % Trenutna pozicija ki ji bo določal
    noisy_positions = cell2mat(cellfun(@(x) x(t, :), trajectories_noisy, 'UniformOutput', false)');

    % Stroškovna matrika - evklidska razdalja
    cost_matrix = zeros(num_players);
    for i = 1:num_players
        for j = 1:num_players
            cost_matrix(i, j) = norm(previous_positions(i, :) - noisy_positions(j, :));
        end
    end

    % Hungarian algorithm po podani funkciji
    [assignment, ~] = munkres(cost_matrix);

    % Določi kam igralec spada
    for playerNum = 1:num_players
        assigned_index = assignment(playerNum); 
        reconstructed_trajectories{playerNum} = [reconstructed_trajectories{playerNum}; noisy_positions(assigned_index, :)];
    end
end

[~,~] = evaluate_tracking_error(golden_standard, reconstructed_trajectories, "Munkres");


%%  Vaja 2.5 - Kalmanov filter %%
% https://www.bzarg.com/p/how-a-kalman-filter-works-in-pictures/
% Parametri
dt = 1; % Time step
F = [1 0 dt 0; 0 1 0 dt; 0 0 1 0; 0 0 0 1]; % Vrednosti s katerimi se bo računalo px, py, vx, vy [predikcijska matrika] 
H = [1 0 0 0; 0 1 0 0];                     % Merjene vrednosti za izhod
Q = eye(4) * 0.01;                          % Kovariančna matrika šuma procesa - okno kjer je še lahko napoved (enotska matrika 4x4 * 0.01)
R = sigma;                                  % Matrika šuma podatkov/meritev - kovaranca verjetnosti
P = eye(4);                                 % Napake - na začetku so za vse iste (identiteta)

kalman_trajectories = cell(1, num_players);

for playerNum = 1:num_players
    % Začetne vrednosti [x, y, vx, vy], hitrosti so 0
    traj = reconstructed_trajectories{playerNum};
    x = [traj(1, 1); traj(1, 2); 0; 0];

    smoothed_traj = traj(1, :); 

    for t = 2:num_time_steps
        % Napoved
        x = F * x; % Napovedano stanje
        P = F * P * F' + Q; % Napoved napake

        % In other words, the new best estimate xk is a prediction F made from previous best estimate xk-1.
        % And the new uncertainty P is predicted F from the old uncertainty Pk-1, with some additional from the environment Q.

        % Meritev
        z = traj(t, :)';                        % Trenutna šumna meritev
        y = z - H * x;                          % H*x - predvidena meritev, y - nov gaus kombinacije meritve in napovedi
        S = H * P * H' + R;                     % vmesni račun, predikcija meritve (gaus)
        K = P * H' / S;                         % K - Kalman gain
        x = x + K * y;                          % posodobi najboljšo napoved
        P = (eye(4) - K * H) * P;               % posodobi napako

        % Shrani trenutno pozicijo
        smoothed_traj = [smoothed_traj; x(1:2)'];
    end

    % shrani pozicije za vsakega igralca
    kalman_trajectories{playerNum} = smoothed_traj;
end


[~,~] = evaluate_tracking_error(golden_standard, kalman_trajectories, "Kalman");


%% Funkcija: Vaja 2.3 - Računanje napake %%
function [mean_error, errors] = evaluate_tracking_error(golden_standard, calculated_positions, naslov)

    num_players = length(golden_standard);
    num_time_steps = size(golden_standard{1}, 1);
    errors = zeros(num_time_steps, 1);

    % Računanje napake za vsak korak
    for t = 1:num_time_steps
        error_sum = 0; 

        for playerNum = 1:num_players
            % Resnična in računana vrednost pozicije
            true_position = golden_standard{playerNum}(t, :);
            estimated_position = calculated_positions{playerNum}(t, :);

            % Evklidska razdalja
            error_sum = error_sum + norm(true_position - estimated_position);
        end
        % Povprečna napaka
        errors(t) = error_sum / num_players;
    end

    mean_error = mean(errors);

    % Plot napake
    figure;
    plot(1:num_time_steps, errors, 'LineWidth', 0.5);
    title(naslov);
    xlabel('Korak');
    ylabel('Povprečna evklidska razdalja');
    grid on;

    % Display overall mean error
    disp(['Celotna povprečna napaka: ', num2str(mean_error)]);
end
