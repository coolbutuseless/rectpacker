
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rectpacker

<!-- badges: start -->

![](https://img.shields.io/badge/cool-useless-green.svg)
[![CRAN](https://www.r-pkg.org/badges/version/rectpacker)](https://CRAN.R-project.org/package=rectpacker)
<!-- badges: end -->

‘rectpacker’ implements the skyline algorithm for packing rectangles
into a box.

This package uses `stb_rect_pack.h` from
[stb](https://github.com/nothings/stb).

## Installation

<!-- This package can be installed from CRAN -->

<!-- ``` r -->

<!-- install.packages('rectpacker') -->

<!-- ``` -->

You can install the latest development version from
[GitHub](https://github.com/coolbutuseless/rectpacker) with:

``` r
# install.package('remotes')
remotes::install_github('coolbutuseless/rectpacker')
```

<!-- Pre-built source/binary versions can also be installed from -->

<!-- [R-universe](https://r-universe.dev) -->

<!-- ``` r -->

<!-- install.packages('rectpacker', repos = c('https://coolbutuseless.r-universe.dev', 'https://cloud.r-project.org')) -->

<!-- ``` -->

## Simple example

Pack 100 randomly sized rectangles into a 50x25 box

``` r
library(ggplot2)
library(rectpacker)

set.seed(1)
N       <- 100
widths  <- sample(7, N, replace = TRUE)
heights <- sample(6, N, replace = TRUE)
rects   <- pack_rects(50, 25, widths, heights)
rects$w <- widths
rects$h <- heights

# How many of the 100 rectangles actually got packed?
table(rects$packed)
```

    #> 
    #> FALSE  TRUE 
    #>    18    82

``` r
# Keep only the rects which were able to be packed into the box
rects <- subset(rects, packed == TRUE)
head(rects)
```

    #> # A tibble: 6 × 6
    #>     idx packed     x     y     w     h
    #>   <int> <lgl>  <int> <int> <int> <int>
    #> 1     1 TRUE      33    19     4     3
    #> 2     2 TRUE      14     0     7     6
    #> 3     3 TRUE      49    21     1     2
    #> 4     5 TRUE      23    19     5     3
    #> 5     6 TRUE       0     0     7     6
    #> 6     8 TRUE       0    12     6     4

``` r
# Plot the rectangles
ggplot(rects) +
  geom_rect(
    aes(
      xmin = x,
      ymin = y,
      xmax = x + w,
      ymax = y + h,
      fill = as.factor(idx)
    ),
    col  = 'black'
  ) + 
  annotate('rect', xmin = 0, ymin = 0, xmax = 50, ymax = 25, fill = NA, col = 'red') + 
  coord_equal() + 
  theme_minimal() + 
  theme(legend.position = 'none') + 
  scale_fill_viridis_d()
```

<img src="man/figures/README-example-1.png" width="100%" />
