# Blurred Microscope Image

MATLAB code from an internship project at LPT on measuring how blurred
microscope images are. The idea is to find the sharp transitions (edges)
in an image, and to quantify how wide they are (FWHM) and how strong
the contrast across them is.

## Requirements

- MATLAB
- Signal Processing Toolbox (`findpeaks`, and `sgolayfilt` in v0.1.0)
- Image Processing Toolbox (`imgaussfilt`, `edge`, `rgb2gray`)
- Computer Vision Toolbox (`insertShape`, v0.1.0 only)

## Usage

```matlab
img = myimage("Sample50_IL7_040.bmp");

img.intensity_analyser();        % 1-D profile of row 1: peaks, valleys, FWHM, contrast
img.edge_detection(1, "Sobel");  % sigma = 1, Sobel edges, strongest rows overlaid
```

`test.m` contains the same example. The test images (`*.bmp`) are not
stored in this repository.

## Repository layout

```
myimage.m                        the myimage class (all analysis code)
test.m                           example run
docs/Image_Processing_notes.docx study notes: filters, histograms, segmentation, thresholding
CHANGELOG.md                     what changed in every version
```

## Versions

| Tag | What it is |
|---|---|
| `v0.1.0` | 1-D intensity profile of one row: Savitzky-Golay smoothing, derivative, peaks/valleys, FWHM, contrast |
| `v0.2.0` | Refactor: Gaussian filter, one `extermumFinder` for peaks and valleys, normalised contrast, first edge detection |
| `v0.3.0` | `edge_detection(sigma, method)` with row-by-row edge analysis, plus the study notes |

Details are in [CHANGELOG.md](CHANGELOG.md). To see exactly what changed
between two versions:

```bash
git diff v0.1.0 v0.2.0 -- myimage.m
git log --oneline --decorate
```

## Next steps

- Recognise whether the dark line in the image is horizontal, vertical or circular
- Preprocess using the image histogram and define masks for better thresholds
- Analyse the whole image instead of a single row in `intensity_analyser`
