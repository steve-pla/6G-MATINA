function PL_itu_dB = ITU_P1812_5_pl(d, f, hTBS, hVessel, d0, maritimeLoss, seaAttenuation)
    % ITU-R P.1812-5 Total Path Loss Model
    % Inputs:
    %   d              - Distance between the terrestrial base station (TBS) and vessel (meters)
    %   f              - Frequency in Hz
    %   hTBS           - Height of the terrestrial base station (meters)
    %   hVessel        - Height of the vessel antenna (meters)
    %   d0             - Reference distance in meters (typically 1 km = 1000 meters)
    %   maritimeLoss   - Maritime environment loss in dB
    %   seaAttenuation - Sea attenuation loss in dB
    %
    % Output:
    %   Lb_d           - Total path loss in dB at distance d

    % Constants
    c = 3e8; % Speed of light in m/s
    % Reference Path Loss (Lb0) at d0
    Lb0 = 20 * log10((4 * pi * f * d0) / c);
    % Free-Space Path Loss (Lbs) at distance d
    Lbs = 20 * log10((4 * pi * f * d) / c);
    % Height Correction Factor (Aht)
    Aht = height_correction_factor(d, hTBS, hVessel);
    % Maritime Path Loss (Lbm)
    Lbm = maritimeLoss; % Provided as input (environment-specific)
    % Sea Attenuation Loss (Lbsa)
    Lbsa = seaAttenuation; % Provided as input (environment-specific)
    % Total Path Loss
    PL_itu_dB = max(Lb0, Lbs + Aht) + Lbm + Lbsa;
end

function Aht = height_correction_factor(d, hTBS, hVessel)
    % Height Correction Factor Aht Calculation
    % Inputs:
    %   d      - Distance between TBS and vessel (meters)
    %   hTBS   - Height of terrestrial base station (meters)
    %   hVessel - Height of vessel antenna (meters)
    % Output:
    %   Aht    - Height correction factor (dB)

    % Empirical formula for height correction factor
    % Example formula - may be replaced with model-specific parameters
    if d < 1000
        Aht = 20 * log10(hTBS / hVessel) + 0.5 * log10(d); % Including distance factor
    else
        Aht = 10 * log10(hTBS / hVessel) + 0.7 * log10(d); % for larger distances
    end
end
