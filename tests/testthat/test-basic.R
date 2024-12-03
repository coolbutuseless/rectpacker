
test_that("basic features work", {
  
  set.seed(1)
  N       <- 100
  widths  <- sample(7, N, replace = TRUE)
  heights <- sample(6, N, replace = TRUE)
  rects   <- pack_rects(50, 25, widths, heights)
  
  expect_true(is.data.frame(rects))
  expect_identical(names(rects), c("idx", "w", "h", "packed", "x", "y"))
  expect_equal(nrow(rects), N)
  

  widths <- c(1, 2)
  heights <- c(1, 2, 3)
  expect_error(
    pack_rects(50, 25, widths, heights),
    "same length"
  )
      
})
