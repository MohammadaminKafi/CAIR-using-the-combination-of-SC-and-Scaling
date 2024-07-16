# Content-Aware Image Retargeting Using the Combination of Seam Carving and Scaling

This project implements a content-aware image retargeting algorithm using a combination of seam carving and scaling techniques. The algorithm adjusts the size of an image while preserving important content by using an energy map that combines depth, saliency, and gradient information.

## Files and Directories

### Main File
- **main.m**: The main script to run the algorithm. Modify this file to set the input image, saliency map, depth map, and desired output width. Additionally, configure logging options and flags for displaying intermediate results.

### Functions (in `src` directory)
- **calculateEnergyMap.m**: Generates the energy map by combining saliency, depth, and gradient maps.
- **findVerticalSeam.m**: Identifies the optimal vertical seam based on the energy map.
- **removeVerticalSeam.m**: Removes the specified vertical seam from the image.
- **findConnectedVerticalSeams.m**: Finds a wide seam by combining consecutive vertical seams.
- **resizeUsingConnectedSeam.m**: Resizes the image along the identified wide seam using bicubic interpolation.

## Usage

1. **Setup Paths**:
   - Set the file paths for the input image, saliency map, and depth map in `main.m` on lines 23 to 25.
   - Specify the desired width for the retargeted image on line 30.

2. **Configure Flags**:
   - **verbose**: Enables logging of values in the terminal.
   - **showSeam**: Displays the seam removal process in each iteration.
   - **showOutputImages**: Logs the final output images.
   - **saveRetargeted**: Saves the retargeted image to disk.

## Algorithm Workflow

1. **Energy Map Calculation**:
   - Combines saliency, depth, and gradient maps using predefined coefficients.
   - Gradients are computed using the Sobel filter and normalized.

2. **Optimal Seam Identification**:
   - Finds the vertical seam with the lowest energy.
   - Returns the seam, its energy, and the energy ratio.

3. **Seam Removal**:
   - Removes seams with energy below a threshold.

4. **Connected Seams Identification**:
   - Identifies wide seams when seam energies are closely clustered.

5. **Image Resizing**:
   - Resizes the image along the identified wide seam using bicubic interpolation.

## Example Results

Below are some examples of original images and their resized versions using the content-aware image retargeting algorithm.

### Example 1
**Original Image:**
![Original Image 1](./src/Samples_dataset/Baby/Baby.png)

**Resized Image:**
![Resized Image 1](./src/Samples_dataset/Baby/Baby_retargeted.png)

### Example 2
**Original Image:**
![Original Image 2](./src/Samples_dataset/Dolls/Dolls.png)

**Resized Image:**
![Resized Image 2](./src/Samples_dataset/Dolls/Dolls_retargeted.png)

### Example 3
**Original Image:**
![Original Image 3](./src/Samples_dataset/Snowman/Snowman.png)

**Resized Image:**
![Resized Image 3](./src/Samples_dataset/Snowman/Snowman_retargeted.png)

## Notes

- The algorithm iteratively processes the image until the resizing condition is met.
- In each iteration, the algorithm either removes the optimal seam if it is deemed insignificant or resizes a seam of width 2N+1 to a width of 2N using bicubic interpolation.
- Output images are stored in the same directory as the original images.