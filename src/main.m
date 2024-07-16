clc;
clear;
close all;

% global flags
verbose = true;
show_seam = true;
show_output_images = true;
save_retargeted = true;

% image path
dataset_path = "./Samples_dataset/";
images_path = ["Baby/", "Diana/", "Dolls/", "Snowman/"]; 
images = ["Baby", "Diana", "Dolls", "Snowman"]; 
images_depth_map = images + "_Dmap"; 
images_salient_map = images + "_Smap";
file_format = ".png";

% image index
image_idx = 3;

% Load the image
image = im2double(imread(dataset_path + images_path(image_idx) + images(image_idx) + file_format));
depth_map = im2double(imread(dataset_path + images_path(image_idx) + images_depth_map(image_idx) + file_format));
salient_map = im2double(imread(dataset_path + images_path(image_idx) + images_salient_map(image_idx) + file_format));

[height, width, ~] = size(image);

% desired retargeted image width
retargeted_image_width = width / 2;

% make a copy of the image
retargeted_image = image;
retargeted_depth_map = depth_map;
retargeted_salient_map = salient_map;

% preprocess the maps
retargeted_depth_map = medfilt2(retargeted_depth_map, [9, 9]);
retargeted_depth_map = (retargeted_depth_map - min(retargeted_depth_map(:))) / (max(retargeted_depth_map(:)) - min(retargeted_depth_map(:)));
retargeted_salient_map = medfilt2(retargeted_salient_map, [5, 5]);
retargeted_salient_map = (retargeted_salient_map - min(retargeted_salient_map(:))) / (max(retargeted_salient_map(:)) - min(retargeted_salient_map(:)));

seam_energy_ratio_threshold = 0.93;
half_seam_width = 10;
remaining_seams_after_resizing = 20;
resizing_factor = remaining_seams_after_resizing / (half_seam_width*2 + 1);

removed_seam_map = zeros(height, width);
resized_map = zeros(height, width);

removed_map_decay = 1 / 100;
resized_map_effect = 0.3;
resized_map_decay = 1 / 80;

while (size(retargeted_image, 2) > retargeted_image_width)
    % calculate the energy map
    energy_map = calculateEnergyMap(retargeted_image, retargeted_depth_map, retargeted_salient_map, removed_seam_map);

    % find the vertical seam with the minimum energy
    [seam, energy, energy_ratio] = findVerticalSeam(energy_map, 1, verbose);

    if energy_ratio < seam_energy_ratio_threshold
        
        % update the removed_seam_map
        for i = 1:size(removed_seam_map, 1)
            removed_seam_map(i, max(seam(i)-1,1):min(seam(i)+1, size(removed_seam_map, 2))) = removed_seam_map(i, max(seam(i)-1,1):min(seam(i)+1, size(removed_seam_map, 2))) + 1;
        end

        if show_seam
            copy_retargeted_image = retargeted_image;
            for i = 1:height
                copy_retargeted_image(i, seam(i), 1) = 1;
                copy_retargeted_image(i, seam(i), 2) = 0;
                copy_retargeted_image(i, seam(i), 3) = 0;
            end
            imshow(copy_retargeted_image);
        end

        % remove the vertical seam from the image
        retargeted_image = removeVerticalSeam(retargeted_image, seam);
        retargeted_depth_map = removeVerticalSeam(retargeted_depth_map, seam);
        retargeted_salient_map = removeVerticalSeam(retargeted_salient_map, seam);
        removed_seam_map = removeVerticalSeam(removed_seam_map, seam);
        resized_map = removeVerticalSeam(resized_map, seam);
    else
        % choose twice the half_seam_width with minimum energy and resize it
        [seams, energy, energy_ratio] = findConnectedVerticalSeams(energy_map + resized_map_effect * resized_map, 0, half_seam_width, verbose);

        % Update resized_map
        for i = 1:size(resized_map, 1)
            resized_map(i, seams(i)-half_seam_width:seams(i)+half_seam_width) = resized_map(i, seams(i)-half_seam_width:seams(i)+half_seam_width) + 1;
        end

        if show_seam
            copy_retargeted_image = retargeted_image;
            for i = 1:size(copy_retargeted_image, 1)
                for j = seams(i)-half_seam_width:seams(i)+half_seam_width
                    copy_retargeted_image(i, j, 1) = 1;
                    copy_retargeted_image(i, j, 2) = 0;
                    copy_retargeted_image(i, j, 3) = 0;
                end
            end
            imshow(copy_retargeted_image);
        end

        retargeted_image = resizeUsingConnectedSeam(retargeted_image, seams, half_seam_width, remaining_seams_after_resizing);
        retargeted_depth_map = resizeUsingConnectedSeam(retargeted_depth_map, seams, half_seam_width, remaining_seams_after_resizing);
        retargeted_salient_map = resizeUsingConnectedSeam(retargeted_salient_map, seams, half_seam_width, remaining_seams_after_resizing);
        removed_seam_map = resizeUsingConnectedSeam(removed_seam_map, seams, half_seam_width, remaining_seams_after_resizing);
        resized_map = resizeUsingConnectedSeam(resized_map, seams, half_seam_width, remaining_seams_after_resizing);
    end

    % decay the maps
    removed_seam_map = max(0, removed_seam_map - removed_map_decay);
    resized_map = max(0, resized_map - resized_map_decay);

    % iteration
    disp("Current width=" + size(retargeted_image, 2));
end

% postprocess the image

% display the images
if show_output_images
    subplot(3, 2, 1);
    imshow(image);
    title("Original image");

    subplot(3, 2, 2);
    imshow(retargeted_image);
    title("Retargeted image");

    subplot(3, 2, 3);
    imshow(depth_map);
    title("Original depth map");

    subplot(3, 2, 4);
    imshow(retargeted_depth_map);
    title("Retargeted depth map");

    subplot(3, 2, 5);
    imshow(salient_map);
    title("Original salient map");

    subplot(3, 2, 6);
    imshow(retargeted_salient_map);
    title("Retargeted salient map");
end

if save_retargeted
    imwrite(retargeted_image, dataset_path + images_path(image_idx) + images(image_idx) + "_retargeted" + file_format);
    disp("Retargeted image saved successfully");
end

