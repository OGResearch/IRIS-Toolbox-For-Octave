/* [SS,TT,QQ,ZZ] = mydgges(AA,BB,eigValTol) */

#include "mex.h"
#include "cpplapack.h"
#include "math.h"
#include "string.h"

// interface between C and FORTRAN
//////////////////////////////////

/*tolerance for the ordering criteria*/
double toler = 1e-8;
/*balancing jobs*/
typedef enum {none, permute_only, scale_only, permute_and_scale} t_balance_job;
t_balance_job balance_job = none;

/*ordering criteria*/
int
order_eigs1 (const double* alphar, const double* alphai, const double* beta)

{
  return ((*alphar * *alphar + *alphai * *alphai < (1.0+toler) * *beta * *beta)
          && (*alphar * *alphar + *alphai * *alphai > (1.0-toler) * *beta * *beta)) ;

}

int
order_eigs (const double* alphar, const double* alphai, const double* beta)

{
  return *alphar * *alphar + *alphai * *alphai >= (1.0+toler) * *beta * *beta;
}

/*wrapper for the DGGES.F and DGGBAL.F functions*/
void
mydgges(double *AA, double *BB, double *QQ, double *ZZ, double *n,
        DGGESCRIT crit, int *info)

{
  // call dggbal to balance AA and BB
  const char* job =
    (balance_job == none)? "N" :
    (balance_job == permute_only)? "P" :
    (balance_job == scale_only)? "S" : "B";
  int ilo;
  int ihi;
  double *lscale;
  double *rscale;
  double *ggbalwork;
  int ld;

  ld = (int)*n;
  lscale = mxCalloc(ld, sizeof(double));
  rscale = mxCalloc(ld, sizeof(double));
  ggbalwork = mxCalloc(ld*6, sizeof(double));

  LAPACK_dggbal(job, &ld, AA, &ld, BB, &ld, &ilo, &ihi,
		lscale, rscale, ggbalwork, info);

  
  double *alphar, *alphai, *beta;
  double work_query;
  int sdim;
  double *work;
  int *bwork;
  int lwork = -1;

  alphar = mxCalloc(ld, sizeof(double));
  alphai = mxCalloc(ld, sizeof(double));
  beta = mxCalloc(ld, sizeof(double));
  bwork = mxCalloc(ld, sizeof(int));

  LAPACK_dgges("V", "V", "S", crit, &ld, AA, &ld, BB, &ld,
	       &sdim, alphar, alphai, beta, QQ, &ld, ZZ, &ld,
	       &work_query, &lwork, bwork, info);

  lwork = (int)work_query;
  work = mxCalloc(lwork, sizeof(double));

  LAPACK_dgges("V", "V", "S", crit, &ld, AA, &ld, BB, &ld,
	       &sdim, alphar, alphai, beta, QQ, &ld, ZZ, &ld,
	       work, &lwork, bwork, info);
}

// interface between Octave and C
/////////////////////////////////

mxArray* mxTranspose(const mxArray *, int);

void
mexFunction (int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[])

{
  /*dimensions of input matrices*/
  unsigned int m1, n1, m2, n2;
  /*dimension var for DGGES*/
  double ndim;
  /*DGGES information*/
  int info;
  /*INPUTS*/
  double *AA, *BB;
  /*OUTPUTS*/
  double *SS, *TT, *QQ, *ZZ, *QQ0, *ZZ0, *tmp;
  
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
  QQ0 = mxGetPr (mxCreateDoubleMatrix (m1, m1, mxREAL));
  ZZ0 = mxGetPr (mxCreateDoubleMatrix (m1, m1, mxREAL));
  tmp = mxGetPr (mxCreateDoubleMatrix (m1, m1, mxREAL));

  /*copy AA and BB to SS and TT*/
  memcpy (SS, AA, sizeof(double)*m1*m1);
  memcpy (TT, BB, sizeof(double)*m1*m1);

  ndim = m1;

  mydgges (SS, TT, QQ0, ZZ0, &ndim, order_eigs, &info);

  /*error?*/
  if (info != 0 && info != (ndim + 3))
    mexErrMsgIdAndTxt ("mydgges:BadInfo","There was an error in DGGES!");

  /*reordering failed?*/
  if (info == ndim + 3)
    mexWarnMsgIdAndTxt ("mydgges:reorderingFailed","Reordering failed in DGGES!");

  /*copy QQ0 and ZZ0 to QQ and ZZ*/
  memcpy (QQ, QQ0, sizeof(double)*m1*m1);
  memcpy (ZZ, ZZ0, sizeof(double)*m1*m1);

  mydgges (SS, TT, QQ, ZZ, &ndim, order_eigs1, &info);
  
  /*error?*/
  if (info != 0 && info != (ndim + 3))
    mexErrMsgIdAndTxt ("mydgges:BadInfo","There was an error in DGGES!");
  
  /*reordering failed?*/
  if (info == ndim + 3)
    mexWarnMsgIdAndTxt ("mydgges:reorderingFailed","Reordering failed in DGGES!");

  /*multiply QQ and QQ0*/
  memcpy (tmp, QQ, sizeof(double)*m1*m1);
  for (n1 = 0 ; n1 < m1 ; n1++ ) {
    for (n2 = 0 ; n2 < m1 ; n2++ ) {
      QQ[m1*n1+n2] = 0;
      for (m2 = 0 ; m2 < m1 ; m2++ ) {
        QQ[m1*n1+n2] += tmp[m1*n1+m2] * QQ0[m1*m2+n2];
      }
    }
  }

  /*multiply ZZ and ZZ0*/
  memcpy (tmp, ZZ, sizeof(double)*m1*m1);
  for (n1 = 0 ; n1 < m1 ; n1++ ) {
    for (n2 = 0 ; n2 < m1 ; n2++ ) {
      ZZ[m1*n1+n2] = 0;
      for (m2 = 0 ; m2 < m1 ; m2++ ) {
        ZZ[m1*n1+n2] += tmp[m1*n1+m2] * ZZ0[m1*m2+n2];
      }
    }
  }
  
  /*transpose QQ*/
  for (n1 = 0 ; n1 < m1 ; n1++ ) {
    for (n2 = 0 ; n2 < n1 ; n2++ ) {
      ndim = QQ[(m1*n1) + n2];
      QQ[(m1*n1) + n2] = QQ[(m1*n2) + n1];
      QQ[(m1*n2) + n1] = ndim;
    }
  }
}
