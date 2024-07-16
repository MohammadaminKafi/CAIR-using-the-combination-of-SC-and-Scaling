function [image_removed_seams]=resizeUsingConnectedSeam(image, seams, half_seam_width, remaining_seams_after_resizing)
% Resize the image using the connected seam method
% Input:
%   image: the image to be resized
%   seams: the central pixel's index of the vertical seam with the minimum energy
%   half_seam_width: half of the width of the seam to find  
%   remaining_seams_after_resizing: the number of seams that will remain after resizing
% Output:
%   image_removed_seam: the resized image

    [height, width, c] = size(image);

    image_removed_seams = zeros(height, width-(half_seam_width*2+1-remaining_seams_after_resizing), c);

    image_region_to_resize = zeros(height, half_seam_width*2 + 1, c);
    for i = 1:height
        image_region_to_resize(i, :, :) = image(i, seams(i)-half_seam_width:seams(i)+half_seam_width, :);
    end

    image_region_to_resize = imresize(image_region_to_resize, [height, remaining_seams_after_resizing], "bicubic");

    for i = 1:height
        image_removed_seams(i, :, :) = [image(i, 1:seams(i)-half_seam_width-1, :), image_region_to_resize(i, :, :), image(i, seams(i)+half_seam_width+1:end, :)];
    end
end