function [seams, energy, energy_ratio] = findConnectedVerticalSeams(energy_map, freedom_degree, seam_width, verbose)
% Find the vertical seam with given width with the minimum energy
% Input:
%   energy_map: the energy map of the image
%   freedom_degree: the freedom degree of the seam (0 for 4-connectivity, 1 for 8-connectivity and so on)
%   seam_width: half of the width of the seam to find
%   verbose: whether to display the energy of the seam
% Output:
%   seams: the central pixel's index of the vertical seam with the minimum energy

    [height, width] = size(energy_map);
    seams = zeros(1, height);

    % Create the cumulative energy map
    cumulative_energy_map = zeros(height, width-(2*seam_width));
    for i = seam_width+1:width-seam_width
        cumulative_energy_map(1, i-seam_width) = sum(energy_map(1, i-seam_width:i+seam_width));
    end

    % Find the minimum energy path
    for i = 2:height
        for j = seam_width+1:width-seam_width
            cumulative_energy_map_index = j - seam_width;
            min_neighbour_energy = min(cumulative_energy_map(i-1, max(cumulative_energy_map_index-freedom_degree, 1):min(cumulative_energy_map_index+freedom_degree, width-(2*seam_width))));
            cumulative_energy_map(i, cumulative_energy_map_index) = sum(energy_map(i, j-seam_width:j+seam_width)) + min_neighbour_energy;
        end
    end

    % Find the minimum energy seam
    [energy, seams(height)] = min(cumulative_energy_map(height, :));
    energy_ratio = energy/max(cumulative_energy_map(height, :));
    for i = height-1:-1:1
        j = seams(i+1);
        [~, seams(i)] = min(cumulative_energy_map(i, max(j-freedom_degree, 1):min(j+freedom_degree, width-(2*seam_width))));
        seams(i) = seams(i) + max(j-freedom_degree, 1) - 1;
    end
    seams = seams + seam_width;

    if verbose
        disp("Max map energy=" + max(energy_map(:)) + ", Min map energy=" + min(energy_map(:)) + ", Max seam energy=" + max(cumulative_energy_map(height, :)) + ", Seam energy=" + energy + ", Energy ratio=" + energy_ratio);
    end
end
    