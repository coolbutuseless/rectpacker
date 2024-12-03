

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Pack rectangles into a box using the skyline algorithm
#' 
#' This implementation accepts only integer valued sizes and coordinates.
#' 
#' @param box_width,box_height dimensions of the box into which the 
#'     rectangles will be packed. Integer values.
#' @param rect_widths,rect_heights widths and heights of the rectangles to pack.
#"    Must be integer values.
#' @return data.frame of packing information
#' \describe{
#'   \item{\code{idx}}{Integer index of rectangle in the input}
#'   \item{\code{packed}}{Logical: Was this rectangle packed into the box?}
#'   \item{\code{x,y}}{coordinates of packing position of bottom-left of rectangle}
#' }
#' @examples
#' # Pack 10 rectangles into a 25x25 box
#' set.seed(1)
#' N <- 10
#' widths  <- sample(N)
#' heights <- sample(N)
#' pack_rects(box_width = 25, box_height = 25, widths, heights)
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pack_rects <- function(box_width, box_height, rect_widths, rect_heights) {
  .Call(pack_rects_, box_width, box_height, rect_widths, rect_heights)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Find a small box to store all the given rectangles
#' 
#' This is a brute force search with a simple heuristic, and is not 
#' guaranteed to find the box with the miinimum area, but simply a box
#' that snugly fits the rectangles without too much wasted space.
#' 
#' @inheritParams pack_rects
#' @param aspect_ratios Vector of box aspect ratios to be tested. Aspect ratio 
#'        is defined here as \code{width / height}. Default: \code{c(1.61803, 1/1.61803)}
#'        i.e. golden ratio
#' @param verbosity Level of debugging output. Default: 0 (no output)
#' @return list with w elements: box width and height
#' @examples
#' # Find a minimal box to fit 10 random rectangles.
#' # Search for boxes with aspect ratios in seq(0.5, 2, length.out = 20)
#' set.seed(2)
#' N <- 10
#' widths  <- sample(N)
#' heights <- sample(N)
#' box <- calc_small_box(widths, heights, aspect_ratios = seq(0.5, 2, length.out = 20))
#' box
#' pack_rects(box$width, box$height, widths, heights)
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
calc_small_box <- function(rect_widths, rect_heights, aspect_ratios = c(1.61803, 1/1.61803), verbosity = 0L) {
  
  stopifnot(length(rect_widths) == length(rect_heights))
  tarea <- sum(rect_widths * rect_heights)
  
  best_w    <- Inf
  best_h    <- Inf
  best_area <- Inf
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Try a range of aspect ratios around the mean aspect ratio
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  count <- 0L
  for (aspect in aspect_ratios) {
    
    min_h <- sqrt(tarea / aspect)
    min_w <- tarea / min_h
    min_w <- as.integer(floor(min_w))
    min_h <- as.integer(floor(min_h))
    
    offset <- 0L
    found_at_aspect <- FALSE
    
    while(!found_at_aspect) {    
      for (expand in 1:3) {
        
        if (expand == 1) {
          w <- min_w + offset
          h <- min_h + offset
        } else if (expand == 2) {
          w <- min_w + offset + 1L
          h <- min_h + offset
        } else {
          w <- min_w + offset
          h <- min_h + offset + 1L
        }

        if (w * h < tarea) next        
        rects <- pack_rects(w, h, rect_widths, rect_heights)
        
        if (verbosity > 0) {
          count <- count + 1L
          cat(sprintf(
            "%4i: (%6.3f) [%2i, %2i] Area: %3i/%3i  Packed: %2i/%2i\n",
            count,
            aspect,
            w, h,
            w * h, tarea,
            sum(rects$packed), length(rect_widths)
          ))
        }
        
        if (all(rects$packed)) {
          found_at_aspect <- TRUE
          if (w * h < best_area) {
            best_area <- w * h
            best_w    <- w
            best_h    <- h
            break
          }
        }
        
      } # expand
      
      offset <- offset + 1L
    } # found_at_aspect
    
  } # aspect
  
  # Best values
  list(
    width  = as.integer(round(best_w)), 
    height = as.integer(round(best_h))
  )
}


if (FALSE) {
  
  set.seed(1)
  N <- 100
  rect_widths  <- sample(N, N, T)
  rect_heights <- sample(N, N, T)
  box <- calc_small_box(rect_widths, rect_heights, verbosity = 1)
  box
  rects <- pack_rects(box$width, box$height, rect_widths, rect_heights)
  # rects <- pack_rects(25, 25, widths, heights)
  rects
  
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
    annotate('rect', xmin = 0, ymin = 0, xmax = box$width, ymax = box$height, fill = NA, col = 'red') + 
    coord_equal() + 
    theme_minimal() + 
    theme(legend.position = 'none') + 
    scale_fill_viridis_d(option = 'D')
  
  
}




