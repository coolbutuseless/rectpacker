
// #define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

extern SEXP pack_rects_(SEXP box_width_, SEXP box_height_, SEXP widths_, SEXP heights_);

static const R_CallMethodDef CEntries[] = {

  {"pack_rects_", (DL_FUNC) &pack_rects_, 4},
  {NULL , NULL, 0}
};


void R_init_rectpacker(DllInfo *info) {
  R_registerRoutines(
    info,      // DllInfo
    NULL,      // .C
    CEntries,  // .Call
    NULL,      // Fortran
    NULL       // External
  );
  R_useDynamicSymbols(info, FALSE);
}



