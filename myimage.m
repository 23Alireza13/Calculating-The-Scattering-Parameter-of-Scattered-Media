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
    properties (Access=private)
        
    end
    methods (Access=protected)
        function filtered_result = data_filter_sgolay(obj,data) %A filter for data
            polyOrder = 9;  
            frameSize = 201; 
            filtered_result = sgolayfilt(data, polyOrder, frameSize);
        end 
        function result = derivator_gradient(obj,data) %A derivator which would be used to find peaks and valleys
            diff_data = gradient(data);
            result = obj.data_filter_sgolay(diff_data);
        end
        function [sorted_valleys, valley_indices ,valley_locs, valley_widths]=valleys_finder(obj, data, MinPeakProminence)
            % Find valleys of the differentiation to detect Gaussian
            [valleys, valley_locs, valley_widths] = findpeaks(-data, ...
                'MinPeakProminence', MinPeakProminence, 'WidthReference', 'halfheight');
            valleys = -valleys; % Convert back to positive values
            % Sort peaks and valleys to find the two largest in each set
            [sorted_valleys, valley_indices] = sort(valleys, 'descend');
        end
        function [sorted_pks, peak_indices, peak_widths, peak_locs]=peak_finder(obj, data, MinPeakProminence)
            %Find peaks of the differentiation to detect Gaussian
            [pks, peak_locs, peak_widths] = findpeaks(data, 'MinPeakProminence', ...
                MinPeakProminence, 'WidthReference', 'halfheight'); 
            % Sort peaks and valleys to find the two largest in each set
            [sorted_pks, peak_indices] = sort(pks, 'descend');
        end
        function peak_valley_contrast_FWHM_reporter(obj,orig_data, data, top_two_peaks, top_two_peak_locs, top_two_peak_widths, ...
                top_two_valleys, top_two_valley_locs, top_two_valley_widths)
            % Display FWHM information and calculate contrast for peaks and valleys
            fprintf('Top Peaks, FWHM, and Contrast:\n');
            peak_contrasts = zeros(1, length(top_two_peaks));
            for i = 1:length(top_two_peaks)
                half_max_start = max(1, round(top_two_peak_locs(i) - top_two_peak_widths(i) / 2));
                half_max_end = min(length(data), round(top_two_peak_locs(i) + top_two_peak_widths(i) / 2));
        
                start_value = data(half_max_start);
                end_value = data(half_max_end);
                contrast = abs(start_value - end_value);
                peak_contrasts(i) = contrast;
        
                fprintf('Peak at x = %.2f with height = %.2f, FWHM = %.2f\n', ...
                    top_two_peak_locs(i), top_two_peaks(i), top_two_peak_widths(i));
                fprintf('  FWHM start at (x, y) = (%.2f, %.2f)\n', half_max_start, start_value);
                fprintf('  FWHM end at (x, y) = (%.2f, %.2f)\n', half_max_end, end_value);
                fprintf('  Contrast = %.2f\n\n', contrast);
            end
        
            fprintf('Top Valleys, FWHM, and Contrast:\n');
            valley_contrasts = zeros(1, length(top_two_valleys));
            for i = 1:length(top_two_valleys)
                half_min_start = max(1, round(top_two_valley_locs(i) - top_two_valley_widths(i) / 2));
                half_min_end = min(length(orig_data), round(top_two_valley_locs(i) + top_two_valley_widths(i) / 2));
        
                start_value = orig_data(half_min_start);
                end_value = orig_data(half_min_end);
                contrast = abs(start_value - end_value);
                valley_contrasts(i) = contrast;
        
                fprintf('Valley at x = %.2f with depth = %.2f, FWHM = %.2f\n', ...
                    top_two_valley_locs(i), top_two_valleys(i), top_two_valley_widths(i));
                fprintf('  FWHM start at (x, y) = (%.2f, %.2f)\n', half_min_start, start_value);
                fprintf('  FWHM end at (x, y) = (%.2f, %.2f)\n', half_min_end, end_value);
                fprintf('  Contrast = %.2f\n\n', contrast);
            end
        end
    end
    methods
        %construct of the class
        function obj = myimage(image)
            obj.raw_unint=imread(image);
            obj.raw_double=double(obj.raw_unint);
        end
        %show where the sample is
        function obj = sampler_display(obj,a,b)
            %put a line on the original picture
            obj.sample_image = insertShape(obj.raw_unint, 'Line', ...
                [a(1),b(1), a(end),b(end)], 'Color', 'red', 'LineWidth', 5);
            %turn into double for plotting
            obj.sample_value = obj.raw_double(a,b);
            figure("Name","Intensity profile of the sample line")
            plot(obj.sample_value)
            figure("Name","Sample Line Place")
            imshow(obj.sample_image)
        end
        function intensity_analyser(obj)
            test = obj.raw_double(1, :);% Read the data
            filtered_test = obj.data_filter_sgolay(test);% Filtering to have smoother result
            filtered_diff = obj.derivator_gradient(filtered_test); % Find the differentiation to see where the downfall and uprise are         
            [sorted_pks, peak_indices, peak_widths, peak_locs]=obj.peak_finder(filtered_diff,0.3);
            [sorted_valleys, valley_indices ,valley_locs, valley_widths]=obj.valleys_finder(filtered_diff,0.3);
            % Extract the two largest positive and negative peaks
            disp(sorted_pks)
            disp(sorted_valleys)
            top_two_peaks = sorted_pks(1:min(2, end));
            top_two_peak_locs = peak_locs(peak_indices(1:min(2, end)));
            top_two_peak_widths = peak_widths(peak_indices(1:min(2, end)));
        
            top_two_valleys = sorted_valleys(1:min(2, end));
            top_two_valley_locs = valley_locs(valley_indices(1:min(2, end)));
            top_two_valley_widths = valley_widths(valley_indices(1:min(2, end)));
        
            % Display FWHM information and calculate contrast for peaks and valleys
            obj.peak_valley_contrast_FWHM_reporter(filtered_test, filtered_diff, top_two_peaks, top_two_peak_locs, top_two_peak_widths, ...
                top_two_valleys, top_two_valley_locs, top_two_valley_widths);
            %%
            % Plot the data, peaks, and FWHM widths
            figure;
            plot(filtered_diff, 'k'); hold on;
            plot(top_two_peak_locs, top_two_peaks, 'ro', 'MarkerSize', 8, 'DisplayName', 'Positive Peaks');
            plot(top_two_valley_locs, top_two_valleys, 'bo', 'MarkerSize', 8, 'DisplayName', 'Negative Peaks');
        
            % Mark FWHM on plot for visual reference
            for i = 1:length(top_two_peaks)
                half_max_start = max(1, round(top_two_peak_locs(i) - top_two_peak_widths(i) / 2));
                half_max_end = min(length(filtered_test), round(top_two_peak_locs(i) + top_two_peak_widths(i) / 2));
                line([half_max_start, half_max_end], [top_two_peaks(i) / 2, top_two_peaks(i) / 2], ...
                    'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'FWHM');
            end
        
            for i = 1:length(top_two_valleys)
                half_min_start = max(1, round(top_two_valley_locs(i) - top_two_valley_widths(i) / 2));
                half_min_end = min(length(filtered_test), round(top_two_valley_locs(i) + top_two_valley_widths(i) / 2));
                line([half_min_start, half_min_end], [top_two_valleys(i) / 2, top_two_valleys(i) / 2], ...
                    'Color', 'b', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'Valley FWHM');
            end
            legend;
            title('Detected Peaks, Valleys, and FWHM');
            xlabel('x');
            ylabel('Amplitude');
            hold off;
            %%
            % Plot the original filtered data with FWHM start and end points marked
            figure;
            plot(filtered_test, 'k', 'DisplayName', 'Filtered Data'); hold on;
            %%
            % Mark FWHM start and end points for peaks
            for i = 1:length(top_two_peaks)
                half_max_start = max(1, round(top_two_peak_locs(i) - top_two_peak_widths(i) / 2));
                half_max_end = min(length(filtered_test), round(top_two_peak_locs(i) + top_two_peak_widths(i) / 2));
        
                % Plot the start and end points for each peak's FWHM
                plot(half_max_start, filtered_test(half_max_start), 'ro', 'MarkerSize', 8, 'DisplayName', 'FWHM Start (Peak)');
                plot(half_max_end, filtered_test(half_max_end), 'rx', 'MarkerSize', 8, 'DisplayName', 'FWHM End (Peak)');
            end
            %%
            % Mark FWHM start and end points for valleys
            for i = 1:length(top_two_valleys)
                half_min_start = max(1, round(top_two_valley_locs(i) - top_two_valley_widths(i) / 2));
                half_min_end = min(length(filtered_test), round(top_two_valley_locs(i) + top_two_valley_widths(i) / 2));
            
                % Plot the start and end points for each valley's FWHM
                plot(half_min_start, filtered_test(half_min_start), 'bo', 'MarkerSize', 8, 'DisplayName', 'FWHM Start (Valley)');
                plot(half_min_end, filtered_test(half_min_end), 'bx', 'MarkerSize', 8, 'DisplayName', 'FWHM End (Valley)');
            end
        
            title('Filtered Data with FWHM Start and End Points');
            xlabel('x');
            ylabel('Amplitude');
            legend;
            hold off;
        end
    end
end
