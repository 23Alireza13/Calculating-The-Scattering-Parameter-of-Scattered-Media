# Changelog

All notable changes to this project are listed here, newest first.
Versions are git tags: see `git tag -n`.

## [Unreleased]

- Repository set up from four snapshots of the original branches
  (`main`, `morpho-oper`, `Threshold_Analysis`, `Threshold_Analysis_V2`).
- Added `.gitignore`, a README and this changelog; moved the Word notes to `docs/`.

## [0.3.0] - Threshold_Analysis_V2

**Added**
- `edge_detection(val, Name)`: `val` is the Gaussian sigma, `Name` is any
  method accepted by MATLAB's `edge` (e.g. `"Sobel"`, `"Canny"`).
- Row-by-row edge analysis: edges are summed per row, rows at or above the
  90th percentile are kept, and only those rows are overlaid on the image.
- `Image Processing.docx` (now `docs/Image_Processing_notes.docx`): notes on
  noise, filters, histograms, segmentation and thresholding.

**Fixed**
- `edge_detection` called `data_filter_gaussian` without its `deviation`
  argument in v0.2.0, and had a leftover first smoothing line whose result
  was overwritten. Now it smooths once, with `val`.

**Changed**
- `test.m` runs `edge_detection(1, "Sobel")` on `Sample50_IL7_040.bmp`.

**Note**: the README of this branch also listed "preprocessing with the
histogram and masks for better thresholds". That is not in this
version's `myimage.m`, only described in the notes. If that code exists
somewhere, add it as v0.3.1.

## [0.2.0] - Threshold_Analysis

**Changed**
- Savitzky-Golay filter (order 9, frame 201) replaced by a Gaussian filter
  (`imgaussfilt`, sigma 30).
- `peak_finder` and `valleys_finder` merged into `extermumFinder(..., "Peak" | "Valley")`.
- Contrast is now normalised, `|a-b| / (a+b)`, and calculated the same way
  for peaks and valleys. In v0.1.0 peaks used the derivative curve and
  valleys used the smoothed intensity.
- All peaks and valleys above the prominence limit are reported, not only the top two.
- Plotting moved into its own method, `intensity_plot`.

**Added**
- `edge_detection()`: Canny edges overlaid on the grayscale image.

**Removed**
- `sampler_display`, the Savitzky-Golay filter, the old reporter method and
  the empty private properties block.

**Known problem**: `edge_detection` fails because of the missing `deviation`
argument (fixed in 0.3.0).

## [0.1.0] - main (also `morpho-oper`)

First version.

- `myimage(file)`: load an image as `uint8` and `double`.
- `sampler_display(a, b)`: draw a sample line on the image and plot its profile.
- `intensity_analyser()`: take row 1 as a 1-D profile, smooth it, differentiate it,
  find peaks and valleys of the derivative (prominence 0.3), report the top
  two of each with FWHM and contrast, and plot them.

The `morpho-oper` branch was byte-for-byte identical to `main`, so it has no
commits of its own. The branch is kept here, pointing at this commit.

## Known issues (all versions)

- Valleys are sorted with `'descend'` on negative values, so the "top" valleys
  are the shallowest ones, not the deepest. Probably wants `'ascend'`.
- `intensity_analyser` always uses row 1 and fixed settings (sigma 30, prominence 0.3).
- The properties `intensity`, `contrast`, `bluriness`, `sample_image` and
  `sample_value` are declared but never filled in.
- Test images are not in the repository, so `test.m` will not run as is.
