// [SS,TT,QQ,ZZ] = mydgges(AA,BB,eigValTol)

#include "mex.h"

// interface between C and FORTRAN
//////////////////////////////////

/*tolerance for the ordering criteria*/
double toler = 1e-8;

/*ordering criteria*/
int
order_eigs (const double* alphar, const double* alphai, const double* beta)
{
	return *alphar * *alphar + *alphai * *alphai < (1.0+toler) * *beta * *beta;
}

/*wrapper for the DGGES.f function*/


// interface between Octave and C
/////////////////////////////////

void
mexFunction (int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[])

{
  /*dimensions of input matrices*/
  unsigned int m1, n1, m2, n2;
  /*INPUTS*/
  double *AA, *BB;
  /*OUTPUTS*/
  double *SS, *TT, *QQ, *ZZ;
  
  /*check number of inputs and outputs*/
  if ((nlhs > 4) || (nlhs == 0) || (nrhs < 2) || (nrhs > 3))
    mexErrMsgTxt ("Number of inputs or outputs is wrong! Must be 2 or 3 inputs\
  and not more than 4 outputs.");
  
  /*check dimensions of input matrices*/
  m1 = mxGetM (prhs[0]);
  n1 = mxGetN (prhs[0]);
  m2 = mxGetM (prhs[1]);
  n2 = mxGetN (prhs[1]);
  if (!mxIsDouble (prhs[0]) || mxIsComplex (prhs[0])
      || !mxIsDouble (prhs[1]) || mxIsComplex (prhs[1])
      || (m1 != n1) || (m2 != n1) || (m2 != n2))
    mexErrMsgTxt ("AA and BB should be square real matrices of the same dimension!");
  
  /*get input matrices values*/
  AA = mxGetPr (prhs[0]);
  BB = mxGetPr (prhs[1]);
  
  /*get tolerance*/
  if (nrhs == 3 && mxGetM (prhs[2]) > 0)
    toler = *mxGetPr (prhs[2]);
  
  /*initiate output matrices*/
  plhs[0] = mxCreateDoubleMatrix (m1, m1, mxREAL);
  plhs[1] = mxCreateDoubleMatrix (m1, m1, mxREAL);
  plhs[2] = mxCreateDoubleMatrix (m1, m1, mxREAL);
  plhs[3] = mxCreateDoubleMatrix (m1, m1, mxREAL);
  
  /*link pointers of internal matrices and corresponding outputs*/
  SS = mxGetPr (plhs[0]);
  TT = mxGetPr (plhs[1]);
  QQ = mxGetPr (plhs[2]);
  ZZ = mxGetPr (plhs[3]);
}
