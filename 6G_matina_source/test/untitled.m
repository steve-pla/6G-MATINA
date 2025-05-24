clc;
clear all;


% --- Scenario Parameters ---
Pt = 1;         % Transmit Power (both BS1 and BS2)
BW = 1e6;       % Bandwidth
N0 = 3.98e-21;  % Noise Power Spectral Density
d11 = 100;      % Distance BS1-UE1
d12 = 200;      % Distance BS1-UE2
d21 = 150;      % Distance BS2-UE1
d22 = 120;      % Distance BS2-UE2
n = 3;          % Path Loss Exponent
c = 3e8;        % Speed of light
f = 2.4e9;      % Frequency
wavelength = c/f;
NoisePower = N0*BW;

% --- Channel Gains (same for both scenarios)---
h11 = sqrt(Pt * (wavelength/(4*pi*d11))^n);
h12 = sqrt(Pt * (wavelength/(4*pi*d12))^n);
h21 = sqrt(Pt * (wavelength/(4*pi*d21))^n);
h22 = sqrt(Pt * (wavelength/(4*pi*d22))^n);

% --- Basic Scenario (Interference) ---
Pr11_basic = Pt * abs(h11)^2;  % Received Power at UE1 (due to BS1)
Pi21_basic = Pt * abs(h21)^2;  % Interference at UE1 (due to BS2)
Pr22_basic = Pt * abs(h22)^2;  % Received Power at UE2 (due to BS2)
Pi12_basic = Pt * abs(h12)^2;  % Interference at UE2 (due to BS1)

SNR_UE1_basic = Pr11_basic / (Pi21_basic + NoisePower);
SNR_UE2_basic = Pr22_basic / (Pi12_basic + NoisePower);

C_UE1_basic = BW * log2(1 + SNR_UE1_basic);
C_UE2_basic = BW * log2(1 + SNR_UE2_basic);

SNR_UE1_basic_dB = 10*log10(SNR_UE1_basic);
SNR_UE2_basic_dB = 10*log10(SNR_UE2_basic);
C_UE1_basic_Mbps = C_UE1_basic / 1e6;
C_UE2_basic_Mbps = C_UE2_basic / 1e6;

% --- MRC Beamforming Scenario ---
w1 = h11';        % MRC beamforming vector for BS1
w2 = h22';        % MRC beamforming vector for BS2
w1 = w1 / norm(w1); % Normalize
w2 = w2 / norm(w2); % Normalize

% Direct SINR Calculation (Corrected)
SINR_UE1_mrc = (Pt * abs(h11 * w1)^2) / (Pt * abs(h21 * w2)^2 + NoisePower);
SINR_UE2_mrc = (Pt * abs(h22 * w2)^2) / (Pt * abs(h12 * w1)^2 + NoisePower);


C_UE1_mrc = BW * log2(1 + SINR_UE1_mrc);
C_UE2_mrc = BW * log2(1 + SINR_UE2_mrc);

SNR_UE1_mrc_dB = 10*log10(SINR_UE1_mrc);
SNR_UE2_mrc_dB = 10*log10(SINR_UE2_mrc);
C_UE1_mrc_Mbps = C_UE1_mrc / 1e6;
C_UE2_mrc_Mbps = C_UE2_mrc / 1e6;

% ... (rest of the code - display and plotting)
% --- Display Results ---
disp('--- Basic Scenario (Interference) ---');
disp(['SNR UE1 (dB): ', num2str(SNR_UE1_basic_dB)]);
disp(['SNR UE2 (dB): ', num2str(SNR_UE2_basic_dB)]);
disp(['Capacity UE1 (Mbps): ', num2str(C_UE1_basic_Mbps)]);
disp(['Capacity UE2 (Mbps): ', num2str(C_UE2_basic_Mbps)]);

disp('--- MRC Beamforming Scenario ---');
disp(['SNR UE1 (dB): ', num2str(SNR_UE1_mrc_dB)]);
disp(['SNR UE2 (dB): ', num2str(SNR_UE2_mrc_dB)]);
disp(['Capacity UE1 (Mbps): ', num2str(C_UE1_mrc_Mbps)]);
disp(['Capacity UE2 (Mbps): ', num2str(C_UE2_mrc_Mbps)]);

% --- Plotting ---
% SNR Comparison
figure;
bar([SNR_UE1_basic_dB, SNR_UE2_basic_dB; SNR_UE1_mrc_dB, SNR_UE2_mrc_dB]);
ylabel('SNR (dB)');
title('SNR Comparison (Basic vs. MRC)');
set(gca, 'XTickLabel', {'UE1', 'UE2'});
legend('Basic', 'MRC');
grid on;

% Capacity Comparison
figure;
bar([C_UE1_basic_Mbps, C_UE2_basic_Mbps; C_UE1_mrc_Mbps, C_UE2_mrc_Mbps]); % Corrected
ylabel('Capacity (Mbps)');
title('Capacity Comparison (Basic vs. MRC)');
set(gca, 'XTickLabel', {'UE1', 'UE2'});
legend('Basic', 'MRC');
grid on;