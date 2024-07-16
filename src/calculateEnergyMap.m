function [energy_map]=calculateEnergyMap(image, depth_map, salient_map, removed_seams_map)
    % coefficients
    depth_coef = 2.5;
    saliency_coef = 1.5;
    removed_seams_map_coef = 0.3;
    gradient_x_coef = 6;
    gradient_y_coef = 2.5;
    alpha_x = 0.2; % threshold for gradients in x direction
    alpha_y = 0.4; % threshold for gradients in y direction

    % get the size of the image
    [height, width, ~] = size(image);
    energy_map = zeros(height, width);

    % convert the image to grayscale
    gray_image = rgb2gray(image);

    % calculate gradients
    [gx, gy] = imgradientxy(gray_image, "sobel"); % gradient in x direction serves a more important role in vertical seam carving
    % normalize the gradients
    gx = abs(gx);
    gx = (gx - min(gx(:))) / (max(gx(:)) - min(gx(:)));
    gy = abs(gy);
    gy = (gy - min(gy(:))) / (max(gy(:)) - min(gy(:)));
    % set values less than alpha to 0
    gx(gx < alpha_x) = 0;
    gy(gy < alpha_y) = 0;
    
    % calculate the energy map
    for i = 1:height
        for j = 1:width
            % calculate the energy of the pixel
            energy_map(i, j) = depth_coef * depth_map(i, j) + saliency_coef * salient_map(i, j) + removed_seams_map_coef * removed_seams_map(i, j) + gradient_x_coef * gx(i, j) + gradient_y_coef * gy(i, j);
        end
    end
end