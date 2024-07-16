function [image_removed_seam]=removeVerticalSeam(image, seam)
% Remove the vertical seam from the image
% Input:
%   image: the image
%   seam: the vertical seam to be removed
% Output:
%   image: the image with the seam removed

    [height, width, c] = size(image);
    image_removed_seam = zeros(height, width-1, c);

    for i = 1:height
        image_removed_seam(i, 1:seam(i)-1, :) = image(i, 1:seam(i)-1, :);
        image_removed_seam(i, seam(i):end, :) = image(i, seam(i)+1:end, :);
    end
end