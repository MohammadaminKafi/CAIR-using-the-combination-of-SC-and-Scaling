function [seam, energy, energy_ratio]=findVerticalSeam(energy_map, freedom_degree, verbose)
% Find the vertical seam with the minimum energy
% Input:
%   energy_map: the energy map of the image
%   freedom_degree: the freedom degree of the seam (0 for 4-connectivity, 1 for 8-connectivity and so on)
% Output:
%   seam: the vertical seam with the minimum energy

    [height, width] = size(energy_map);
    seam = zeros(1, height);

    % Create the cumulative energy map
    cumulative_energy_map = zeros(height, width);
    cumulative_energy_map(1, :) = energy_map(1, :);

    % Find the minimum energy path
    for i = 2:height
        for j = 1:width
            min_neighbour_energy = min(cumulative_energy_map(i-1, max(j-freedom_degree, 1):min(j+freedom_degree, width)));
            cumulative_energy_map(i, j) = energy_map(i, j) + min_neighbour_energy;
        end
    end

    % Find the minimum energy seam
    [energy, seam(height)] = min(cumulative_energy_map(height, :));
    energy_ratio = energy/max(cumulative_energy_map(height, :));
    for i = height-1:-1:1
        j = seam(i+1);
        [~, seam(i)] = min(cumulative_energy_map(i, max(j-freedom_degree, 1):min(j+freedom_degree, width)));
        seam(i) = seam(i) + max(j-freedom_degree, 1) - 1;
    end

    if verbose
        disp("Max map energy=" + max(energy_map(:)) + ", Min map energy=" + min(energy_map(:)) + ", Max seam energy=" + max(cumulative_energy_map(height, :)) + ", Seam energy=" + energy + ", Energy ratio=" + energy_ratio);
    end
end