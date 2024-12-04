

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
#'   \item{\code{w,h}}{Integer dimensions of each rectangle}
#'   \item{\code{packed}}{Logical: Was this rectangle packed into the box?}
#'   \item{\code{x,y}}{Integer coordinates of packing position of bottom-left of rectangle}
#' }
#' @examples
#' # Pack 10 rectangles into a 25x25 box
#' # Note: All rectangles in the results have 'packed=TRUE' which
#' # means they all fit into the box
#' set.seed(1)
#' N <- 10
#' rect_widths  <- sample(N)
#' rect_heights <- sample(N)
#' pack_rects(box_width = 25, box_height = 25, rect_widths, rect_heights)
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pack_rects <- function(box_width, box_height, rect_widths, rect_heights) {
  .Call(pack_rects_, box_width, box_height, rect_widths, rect_heights)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Find the dimensions of a small box to store all the given rectangles
#' 
#' This is a brute force search with a simple heuristic. Is not 
#' guaranteed to find the box with the minimum area, but simply a box
#' that snugly fits the rectangles without too much wasted space.
#' 
#' @inheritParams pack_rects
#' @param aspect_ratios Vector of box aspect ratios to be tested. Aspect ratio 
#'        is defined here as \code{width / height}. Default: \code{c(1.61803, 1/1.61803)}
#'        i.e. golden ratio and its inverse.
#' @param verbosity Level of debugging output. Default: 0 (no output)
#' @return List with 2 elements: \code{width} and \code{height} of a small box
#'         which fits all the rectangles.
#' @examples
#' # Find a minimal box to fit 10 random rectangles.
#' # Search for boxes with aspect ratios in seq(0.5, 2, length.out = 20)
#' set.seed(2)
#' N <- 10
#' rect_widths  <- sample(N)
#' rect_heights <- sample(N)
#' box <- calc_small_box(rect_widths, rect_heights, 
#'                       aspect_ratios = seq(0.5, 2, length.out = 20))
#' box
#' rects <- pack_rects(box$width, box$height, rect_widths, rect_heights)
#' all(rects$packed)
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
calc_small_box <- function(rect_widths, rect_heights, aspect_ratios = c(1.61803, 1/1.61803), verbosity = 0L) {
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Sanity check
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  stopifnot(length(rect_widths) == length(rect_heights))
  tarea <- sum(rect_widths * rect_heights)
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Keep track of the best (w, h) (which has the smallest area) which contains 
  # all the rects
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  best_w    <- Inf
  best_h    <- Inf
  best_area <- Inf
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # For each aspect ratio
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  count <- 0L
  for (aspect in aspect_ratios) {
    
    # Calculate the minimum width and height which might contain 
    # all the rectangles
    min_h <- sqrt(tarea / aspect)
    min_w <- tarea / min_h
    min_w <- as.integer(floor(min_w))
    min_h <- as.integer(floor(min_h))
    
    # At each aspect ratio, keep expanding the 'w' and 'h'
    # until we find a box which fits all rectangles.
    offset <- 0L
    found_at_aspect <- FALSE
    
    while(!found_at_aspect) {    
      for (expand in 1:3) {
        
        # Three types of expansion to try at each step
        #  - increase width by 1
        #  - increase height by 1
        #  - increase both width and height by 1
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

        # If the area is ever less than the total area of all the rectangles
        # then this can't possibly be a solution
        if (w * h < tarea) next        
        rects <- pack_rects(w, h, rect_widths, rect_heights)
        
        # Print information about each iteration
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

