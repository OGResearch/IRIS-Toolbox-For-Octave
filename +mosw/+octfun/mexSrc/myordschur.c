/* [UU,TT,EigVal] = myordschur(AA,eigValTol) */

#define dgemm dgemm_
#define dgees dgees_

#include "mex.h"
#include "math.h"
#include "string.h"

// interface between C and FORTRAN
//////////////////////////////////

/*default tolerance for the ordering criteria*/
double toler = 1e-8;

/*type definition needed for DGGES criteria*/
typedef int (*DGEESCRIT)(const double*, const double*);

/*balancing jobs*/
//typedef enum {none, permute_only, scale_only, permute_and_scale} t_balance_job;

/*ordering criteria*/
int
order_eigs1 (const double* alphar, const double* alphai)
/*criterium 1: |eigVals| > 1 + toler*/
{
  return *alphar * *alphar + *alphai * *alphai >= (1.0+toler);
}

int
order_eigs (const double* alphar, const double* alphai)
/*criterium 2: ||eigVals| - 1| < toler*/
{
  return ((*alphar * *alphar + *alphai * *alphai < (1.0+toler))
          && (*alphar * *alphar + *alphai * *alphai > (1.0-toler))) ;
}

/*wrapper for the DGEES.F function*/
void
mydgees(double *AA, double *UU, int nfull, int nsegm,
        DGEESCRIT crit, int *info, int *sdim, double *alphar, double *alphai)

{
  double work_query;
  int ld = nfull;
  int *bwork;
  int lwork = -1;

  bwork = mxCalloc(ld, sizeof(int));

  dgees("V", "S", crit, &nsegm, AA, &ld,
	       sdim, alphar, alphai, UU, &ld,
	       &work_query, &lwork, bwork, info);

  lwork = (int)work_query;
  double *work;
  work = mxCalloc(lwork, sizeof(double));

  dgees("V", "S", crit, &nsegm, AA, &ld,
	       sdim, alphar, alphai, UU, &ld,
	       work, &lwork, bwork, info);

  //mexPrintf("sdim = %d\n",*sdim);  

  mxFree(work);
  mxFree(bwork);
}

// interface between Octave and C
/////////////////////////////////

void
mexFunction (int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[])

{
  /*dimensions of input matrices*/
  size_t m1, n1;
  /*dimension var for DGEES*/
  int ndim;
  /*number of unit and stable roots*/
  int nUnit, nUnstable;
  /*DGGES information*/
  int info;
  /*INPUTS*/
  double *AA;
  /*OUTPUTS*/
  double *TT, *UU, *UU0, *tmp;
  /*eigenvalues and components*/
  double *alphar, *alphai;

  /*check number of inputs and outputs*/
  if ((nlhs > 3) || (nlhs == 0) || (nrhs < 1) || (nrhs > 2)) {
    mexErrMsgTxt ("Number of inputs or outputs is wrong! Must be 1 or 2 inputs\
  and not more than 3 outputs.");
  }

  /*check dimensions of input matrices*/
  m1 = mxGetM (prhs[0]);
  n1 = mxGetN (prhs[0]);
  if ((!mxIsDouble (prhs[0])) || (mxIsComplex (prhs[0])) || (m1 != n1)) {
    mexErrMsgTxt ("Input should be a square real matrix!");
  }

  /*get input matrices values*/
  AA = mxGetPr (prhs[0]);

  /*get tolerance*/
  if (nrhs == 2 && mxGetM (prhs[1]) > 0){
    toler = *mxGetPr (prhs[1]);
  }

  /*initiate 1st output matrix*/
  plhs[0] = mxCreateDoubleMatrix (m1, m1, mxREAL);

  /*link pointers of internal matrices and corresponding outputs*/
  /*and initiate 2nd and 3rd output matrices is needed          */
  if (nlhs == 1) {
    TT = mxGetPr (plhs[0]);
    UU = mxCalloc (m1*m1, sizeof(double));
  }
  if (nlhs > 1) {
    plhs[1] = mxCreateDoubleMatrix (m1, m1, mxREAL);
    UU = mxGetPr (plhs[0]);
    TT = mxGetPr (plhs[1]);
  }
  if (nlhs == 3) {
    plhs[2] = mxCreateDoubleMatrix (m1, 1, mxCOMPLEX);
    alphar = mxGetPr (plhs[2]);
    alphai = mxGetPi (plhs[2]);
  }
  else {
    alphar = mxCalloc (m1, sizeof(double));
    alphai = mxCalloc (m1, sizeof(double));
  }
  UU0 = mxCalloc (m1*m1, sizeof(double));
  tmp = mxCalloc (m1*m1, sizeof(double));

  /*copy AA to TT*/
  memcpy (TT, AA, sizeof(double)*m1*m1);

  /*cast the dimension as int*/
  ndim = (int)m1;

  /*first call to DGEES -- leading block has |eigVals| > 1 + toler*/
  /*AA = UU0*TT*UU0'*/
  mydgees (TT, UU0, ndim, ndim, order_eigs1, &info, &nUnstable, alphar, alphai);

  /*debug lines*/
//      mexPrintf("nUnstable = %d\n",nUnstable);
//      mexPrintf("info = %d\n",info);
  
  /*error?*/
  if (info != 0 && info <= ndim) {
    mexErrMsgIdAndTxt ("mydgees:badInfo","There was an error in DGEES!");
  }
  
  /*reordering failed?*/
  if ((info == ndim + 1) || (info == ndim + 2)) {
    mexWarnMsgIdAndTxt ("mydgees:reorderingFailed","Reordering failed in DGEES!");
  }

  /*size of segment for the second reordering*/
  int nsegm = ndim - nUnstable;
  int offset = nUnstable + nUnstable*ndim;

  /*upper left corners of UU should be an identity matrix*/
  int ix;
  for (ix=0; ix < nUnstable; ix++) {
    UU[ix+ndim*ix] = 1;
  }

  /*second call to DGEES -- leading block has ||eigVals| - 1| < toler*/
  /*AA = UU0*UU*TT*UU'*UU0'*/
  mydgees (TT+offset, UU+offset, ndim, nsegm, order_eigs, &info, &nUnit, alphar+nUnstable, alphai+nUnstable);

  /*debug lines*/
//      mexPrintf("nUnit = %d\n",nUnit);
//      mexPrintf("info = %d\n",info);

  /*error?*/
  if ((info != 0) && (info <= ndim)) {
    mexErrMsgIdAndTxt ("mydgees:badInfo","There was an error in DGEES!");
  }
  
  /*reordering failed?*/
  if ((info == ndim + 1) || (info == ndim + 2)) {
    mexWarnMsgIdAndTxt ("mydgees:reorderingFailed","Reordering failed in DGEES!");
  }

  /*transform TT12*/
  /*
  |u11 u12|   |t11 t12|   |u11 u12|T   |a11 a12|
  |       | x |       | x |       |  = |       |
  |u21 u22|   |0   t22|   |u21 u22|    |a21 a22|
   -------     -------     -------      -------
     UU0         TT0         UU0'         AA
  
  t22 = u0*t0*u0'
  TT0 = UU*TT*UU'
  
  |u11 u12|   |I  0 |   |t11 t12*u0|   |I  0 |T   |u11 u12|T   |a11 a12|
  |       | x |     | x |    ^^^^^^| x |     |  x |       |  = |       |
  |u21 u22|   |0  u0|   |0   t0    |   |0  u0|    |u21 u22|    |a21 a22|
   -------     -----     ----------     -----      -------      -------
     UU0        UU          TT           UU'         UU0'         AA
  */
  double alp = 1.0, bet = 0.0;
  int offset2 = nUnstable*ndim;
  memcpy (tmp, TT, sizeof(double)*ndim*ndim);
  dgemm("N","N",&nUnstable,&nsegm,&nsegm,&alp,tmp+offset2,&ndim,UU+offset,&ndim,&bet,TT+offset2,&ndim);

  /*multiply UU0 and UU*/
  memcpy (tmp, UU, sizeof(double)*ndim*ndim);
  dgemm("N","N",&ndim,&ndim,&ndim,&alp,UU0,&ndim,tmp,&ndim,&bet,UU,&ndim);

  /*deallocate memory*/
  mxFree(tmp);
  mxFree(UU0);
  if (nlhs == 1) {
    mxFree(UU);
  }
  if (nlhs == 2) {
    mxFree(alphar);
    mxFree(alphai);
  }

}
