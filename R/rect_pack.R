

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

