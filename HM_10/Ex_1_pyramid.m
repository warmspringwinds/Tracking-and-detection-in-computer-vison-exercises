img = rgb2gray(imread('office_3.jpg'));

template_top_left_x_y = [255, 330];
template_bottom_right_x_y = [303, 366];

template = img(template_top_left_x_y(2):template_bottom_right_x_y(2), template_top_left_x_y(1):template_bottom_right_x_y(1));
% imshow(template);

%% Grayscale image. Pyramid search.

tic

downsampled_img = imresize(img, 0.5);
downsampled_template = imresize(template, 0.5);
template_size = size(downsampled_template);

result = nlfilter(downsampled_img, template_size, @(patch) sum(sum( (downsampled_template - patch).^2 ) ));
min_value = min(result(:));
max_value = max(result(:));

% Normilize the picture so that the values are between 0 and 1 and invert
% it.

normalized_result = ones(size(result)) - ( result - min_value ) / ( max_value - min_value );
% imshow(normalized_result);

largest_element_value = max(max(normalized_result));
% Set threshold relative to max value.
[row, col] = ind2sub(size(normalized_result), find(normalized_result > (0.8*largest_element_value)));

toc

%%

% imshow(downsampled_img);
% hold on;
% plot(col, row, 'o');

% Coordinates of center pixels in a next bigger pyramid level.
% One pixel in a smaller level corresponds to multiple pixels in a bigger
% level, so some region centered at that pixels should be considered.
row_new_coords = (row - 1)*2 + 1;
col_new_coords = (col - 1)*2 + 1;

coords_batch_size = size(col, 1);
% Size of a border of a square region of a pixel to be considered.
pixel_boundary_size = 1;

boundary_span = -pixel_boundary_size:pixel_boundary_size;

width_of_square = pixel_boundary_size*2 + 1;
amount_of_elements_in_square = width_of_square^2;

coords = zeros(coords_batch_size*amount_of_elements_in_square, 2);

element_number_counter = 1;

for row_displacement = boundary_span
    for col_displacement = boundary_span
        
        row_displaced_coords = row_new_coords + row_displacement;
        col_displaced_coords = col_new_coords + col_displacement;
        
        starting_element = (element_number_counter-1)*coords_batch_size + 1;
        end_element = element_number_counter*coords_batch_size;
        
        coords(starting_element:end_element, :) = [row_displaced_coords col_displaced_coords];
        
        element_number_counter = element_number_counter + 1;
    end
end

row_coords = coords(:, 1);
col_coords = coords(:, 2);

valid_points = row_coords > 0 & row_coords <= size(img, 1);
valid_points = valid_points & (col_coords > 0 & col_coords);

indexes = find(valid_points);

coords = coords(valid_points, :);

% TODO: border treatement in case of overflow.

% imshow(img);
% hold on;
% plot(coords(:, 2), coords(:, 1), 'o');

results  = selected_nlfilter( img, coords, @(patch) sum(sum( ( double(template) - double(patch)).^2 )) , size(template), 'symmetric');

[value, pos] = min(results);

imshow(img);
hold on;
plot(coords(pos, 2), coords(pos, 1), 'o');






