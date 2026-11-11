classdef myimage
    properties
        raw_unint %to store the original image
        raw_double %for the numerical analysis
        sample_image %show the sample image

        sample_value %double version (instead of "unint") of the sample
        intensity %intensity array of a sample in raw image
        contrast %lowest contrast of a sample in raw image
        bluriness %amount of bluriness of a sample in raw image      
    end
    methods (Access=protected)
        function intensity_plot(obj, filtered_data, filtered_diff_data, sorted_peaks, peak_locs, peak_FWHM, sorted_valleys, valley_locs, valley_FWHM)
            % Plot the data, peaks, and FWHM widths
            figure;
            plot(filtered_diff_data, 'k'); hold on;
            plot(peak_locs, sorted_peaks, 'ro', 'MarkerSize', 8, 'DisplayName', 'Positive Peaks');
            plot(valley_locs, sorted_valleys, 'bo', 'MarkerSize', 8, 'DisplayName', 'Negative Peaks');
        
            % Mark FWHM on plot for visual reference
            for i = 1:length(sorted_peaks)
                half_max_start = max(1, round(peak_locs(i) - peak_FWHM(i) / 2));
                half_max_end = min(length(filtered_data), round(peak_locs(i) + peak_FWHM(i) / 2));
                line([half_max_start, half_max_end], [sorted_peaks(i) / 2, sorted_peaks(i) / 2], ...
                    'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'FWHM');
            end
        
            for i = 1:length(sorted_valleys)
                half_min_start = max(1, round(valley_locs(i) - valley_FWHM(i) / 2));
                half_min_end = min(length(filtered_data), round(valley_locs(i) + valley_FWHM(i) / 2));
                line([half_min_start, half_min_end], [sorted_valleys(i) / 2, sorted_valleys(i) / 2], ...
                    'Color', 'b', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'Valley FWHM');
            end
            legend;
            title('Detected Peaks, Valleys, and FWHM');
            xlabel('x');
            ylabel('Amplitude');
            hold off;
            % Plot the original filtered data with FWHM start and end points marked
            figure;
            plot(filtered_data, 'k', 'DisplayName', 'Filtered Data'); hold on;
            % Mark FWHM start and end points for peaks
            for i = 1:length(sorted_peaks)
                half_max_start = max(1, round(peak_locs(i) - peak_FWHM(i) / 2));
                half_max_end = min(length(filtered_data), round(peak_locs(i) + peak_FWHM(i) / 2));
        
                % Plot the start and end points for each peak's FWHM
                plot(half_max_start, filtered_data(half_max_start), 'ro', 'MarkerSize', 8, 'DisplayName', 'FWHM Start (Peak)');
                plot(half_max_end, filtered_data(half_max_end), 'rx', 'MarkerSize', 8, 'DisplayName', 'FWHM End (Peak)');
            end
    
            % Mark FWHM start and end points for valleys
            for i = 1:length(sorted_valleys)
                half_min_start = max(1, round(valley_locs(i) - valley_FWHM(i) / 2));
                half_min_end = min(length(filtered_data), round(valley_locs(i) + valley_FWHM(i) / 2));
            
                % Plot the start and end points for each valley's FWHM
                plot(half_min_start, filtered_data(half_min_start), 'bo', 'MarkerSize', 8, 'DisplayName', 'FWHM Start (Valley)');
                plot(half_min_end, filtered_data(half_min_end), 'bx', 'MarkerSize', 8, 'DisplayName', 'FWHM End (Valley)');
            end
        
            title('Filtered Data with FWHM Start and End Points');
            xlabel('x');
            ylabel('Amplitude');
            legend;
            hold off;
        end
        function [sorted_extermum ,extermum_locs, extermum_FWHM] = extermumFinder(obj, data, orig_data , MinPeakProminence, extermum_type)
        %calculating the FWHM and the value of the extermum aand the
        %location of the extermum in the picture
        if extermum_type == "Valley"
            [extermum_value, extermum_locs, extermum_FWHM] = findpeaks(-data, ...
                'MinPeakProminence', MinPeakProminence, 'WidthReference', 'halfheight');
            extermum_value = -extermum_value; % Convert back to positive values
        elseif extermum_type == "Peak"
            [extermum_value, extermum_locs, extermum_FWHM] = findpeaks(data, ...
                'MinPeakProminence', MinPeakProminence, 'WidthReference', 'halfheight');
        end
        %sorting the values
        [sorted_extermum, extermum_indices] = sort(extermum_value, 'descend');
        extermum_locs = extermum_locs(extermum_indices);
        extermum_FWHM = extermum_FWHM(extermum_indices);
        %calculating the contrast
        extermum_contrast = obj.contrast_calculator(orig_data, sorted_extermum, extermum_locs, extermum_FWHM, extermum_type);
        end   
        function filtered_result = data_filter_gaussian(obj, orig_data, deviation) %A filter for data
            filtered_result = imgaussfilt(orig_data, deviation);
        end 
        function filtered_result = derivator_gradient(obj, data, deviation) %A derivator which would be used to find peaks and valleys
            diff_data = gradient(data);
            filtered_result = obj.data_filter_gaussian(diff_data, deviation);
        end
        function extermum_contrast = contrast_calculator(obj, orig_data, extermum_point, extermum_locs, extermum_FWHM,extermum_type)
            % Display FWHM information and calculate contrast for peaks and valleys
            peak_contrasts = zeros(1, length(extermum_point));
            for i = 1:length(extermum_point)
                half_max_start = max(1, round(extermum_locs(i) - extermum_FWHM(i) / 2));
                half_max_end = min(length(orig_data), round(extermum_locs(i) + extermum_FWHM(i) / 2));
        
                start_value = orig_data(half_max_start);
                end_value = orig_data(half_max_end);
                extermum_contrast = abs((start_value - end_value)/(start_value + end_value));
                peak_contrasts(i) = extermum_contrast;
                %displaying the result
                fprintf('%s at x = %.2f with height = %.2f, FWHM = %.2f\n', ...
                    extermum_type, extermum_locs(i), extermum_point(i), extermum_FWHM(i));
                fprintf('  FWHM start at (x, y) = (%.2f, %.2f)\n', half_max_start, start_value);
                fprintf('  FWHM end at (x, y) = (%.2f, %.2f)\n', half_max_end, end_value);
                fprintf('  Contrast = %.2f\n\n', extermum_contrast);
            end            
        end  
        function [sorted_peaks ,peak_locs, peak_FWHM, sorted_valleys ,valley_locs, valley_FWHM] = peaks_and_valleys_analyser(obj, filtered_diff_data, filtered_data, MinPeakProminence)
            [sorted_peaks ,peak_locs, peak_FWHM] = obj.extermumFinder(filtered_diff_data, filtered_data, MinPeakProminence, "Peak");
            [sorted_valleys ,valley_locs, valley_FWHM] = obj.extermumFinder(filtered_diff_data, filtered_data, MinPeakProminence, "Valley");
        end
    end
    methods (Access=public)
        function obj = myimage(image)
            obj.raw_unint=imread(image);
            obj.raw_double=double(obj.raw_unint);
        end        
        %show the intensity profile of the picture
        function intensity_analyser(obj)
            orig_data = obj.raw_double(1, :);% Read the data
            gaussian_filter_deviation = 30;
            filtered_data = obj.data_filter_gaussian(orig_data, gaussian_filter_deviation);% Filtering to have smoother result
            filtered_diff_data = obj.derivator_gradient(filtered_data, gaussian_filter_deviation); % Find the differentiation to see where the downfall and uprise are         
            %find peaks and valleys of the derivation of the data
            MinPeakProminence = 0.3;
            [sorted_peaks ,peak_locs, peak_FWHM, sorted_valleys ,valley_locs, valley_FWHM] = peaks_and_valleys_analyser(obj, filtered_diff_data, filtered_data, MinPeakProminence);
            obj.intensity_plot(filtered_data, filtered_diff_data, sorted_peaks, peak_locs, peak_FWHM, sorted_valleys, valley_locs, valley_FWHM)
        end
        function edge_detection(obj)
            % Load the grayscale image
            img = obj.raw_unint;
            if size(img, 3) == 3
                img = rgb2gray(img); % Convert to grayscale if it's not already
            end
            
            % Display the original image
            figure;
            imshow(img);
            title('Original Grayscale Image');
            
            % Step 1: Apply Gaussian smoothing to reduce noise
            smoothed_img = imgaussfilt(img, 2); % Adjust the second parameter for more/less smoothing
            smoothed_img = obj.data_filter_gaussian(obj.raw_double);
            % Step 2: Perform Canny edge detection
            edges = edge(smoothed_img, 'Canny');
            
            % Step 3: Create an RGB version of the grayscale image for overlaying
            edges_overlay = repmat(img, 1, 1, 3); % Convert grayscale image to RGB by replicating channels
            
            % Step 4: Overlay edges in white
            edges_overlay(:,:,1) = edges_overlay(:,:,1) + uint8(edges) * 220; % Adjust intensity for red channel
            edges_overlay(:,:,2) = edges_overlay(:,:,2) + uint8(edges) * 220; % Adjust intensity for green channel
            edges_overlay(:,:,3) = edges_overlay(:,:,3) + uint8(edges) * 220; % Adjust intensity for blue channel
            
            % Display the overlay image
            figure;
            imshow(edges_overlay);
            title('Overlay of Edges on Original Image');

        end
    end
end
