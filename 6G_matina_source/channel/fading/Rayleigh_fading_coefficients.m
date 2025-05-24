function [h] = Rayleigh_fading_coefficients()
%RAYLEIGH_FADING_COEFFICIENTS Summary of this function goes here
h_real = randn(1, 1); % Real part 
h_imag = randn(1, 1); % Imaginary part
h = (h_real + 1i * h_imag) / sqrt(2);
end

