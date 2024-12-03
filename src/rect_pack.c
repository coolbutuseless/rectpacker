
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>

#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>

#include "utils.h"

#define STB_RECT_PACK_IMPLEMENTATION
#include "stb_rect_pack.h"


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Call STB rectangle packing
// @param box_width,box_height dimensions of box to pack into
// @param w_,h_ vectors of rectangle dimensions
// @return data.frame of packing information
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SEXP pack_rects_(SEXP box_width_, SEXP box_height_, SEXP w_, SEXP h_) {
  int nprotect = 0;
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Sanity check rectangles
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (length(w_) != length(h_)) {
    error("widths and heights must be same length");
  }
  int *w = INTEGER(w_);
  int *h = INTEGER(h_);
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Create rectangles for call to STB lib
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  int nrects = length(w_);
  stbrp_rect *rects = NULL;
  rects = calloc((size_t)nrects, sizeof(stbrp_rect));
  if (rects == NULL) {
    error("rects: couldn't allocate");
  }
  
  for (int i = 0; i < nrects; i++) {
    rects[i].id = i;
    rects[i].w = w[i];
    rects[i].h = h[i];
    rects[i].x = -1;
    rects[i].y = -1;
    rects[i].was_packed = 0;
  }
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Create packing context.
  // Ensure that nnodes > box_width
  // I'm over-allocating here. Not too sure it matters. Memory is cheap! :)
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  stbrp_context ctx = { 0 };
  
  int box_width = asInteger(box_width_);
  int box_height = asInteger(box_height_);
  
  int nnodes = 10 * nrects;
  if (nnodes < box_width) {
    nnodes = box_width * 4;  
  }
  
  stbrp_node *nodes = calloc((size_t)nnodes, sizeof(stbrp_node));
  if (nodes == NULL) {
    error("nodes: Couldn't allocate");
  }
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Let it pack!
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  stbrp_init_target(&ctx, box_width, box_height, nodes, nnodes);
  stbrp_setup_heuristic(&ctx, STBRP_HEURISTIC_Skyline_BF_sortHeight);
  stbrp_pack_rects(&ctx, rects, nrects);
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Prepare a data.frame to copy results into
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  SEXP idx_    = PROTECT(allocVector(INTSXP, nrects)); nprotect++;
  SEXP x_      = PROTECT(allocVector(INTSXP, nrects)); nprotect++;
  SEXP y_      = PROTECT(allocVector(INTSXP, nrects)); nprotect++;
  SEXP packed_ = PROTECT(allocVector(LGLSXP, nrects)); nprotect++;
  
  SEXP df_ = PROTECT(create_named_list(4, 
                                       "idx", idx_, 
                                       "packed", packed_,
                                       "x", x_, 
                                       "y", y_)); nprotect++;
  set_df_attributes(df_);
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Copy results into data.frame
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  int *idx    = INTEGER(idx_);
  int *x      = INTEGER(x_);
  int *y      = INTEGER(y_);
  int *packed = INTEGER(packed_);
  for (int i = 0; i < nrects; i++) {
    idx[i]    = i;
    packed[i] = rects[i].was_packed;
    if (!rects[i].was_packed) {
      x[i] = NA_INTEGER;
      y[i] = NA_INTEGER;
    } else {
      x[i]      = rects[i].x;
      y[i]      = rects[i].y;
    }    
  }
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Tidy and return
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  free(nodes);
  free(rects);
  UNPROTECT(nprotect);
  return df_;
}
