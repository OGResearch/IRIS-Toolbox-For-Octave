/* [SS,TT,QQ,ZZ] = mydgges(AA,BB,eigValTol) */

#if !defined(_WIN32)
#define dgemm dgemm_
#define dgges dgges_
#endif

#include "mex.h"
#include "math.h"
#include "string.h"

// interface between C and FORTRAN
//////////////////////////////////

/*default tolerance for the ordering criteria*/
double toler = 1e-8;

/*type definition needed for DGGES criteria*/
typedef int (*DGGESCRIT)(const double*, const double*, const double*);

/*balancing jobs*/
//typedef enum {none, permute_only, scale_only, permute_and_scale} t_balance_job;

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
mydgges(double *AA, double *BB, double *QQ, double *ZZ, int n,
        DGGESCRIT crit, int *info)

{
  /*balancing is gonna be added later, i hope :) */
  /*
  // call dggbal to balance AA and BB
  const char* job =
    (bal_job == none)? "N" :
    (bal_job == permute_only)? "P" :
    (bal_job == scale_only)? "S" : "B";
  int ilo;
  int ihi;
  double *lscale;
  double *rscale;
  double *ggbalwork;

  lscale = mxCalloc(ld, sizeof(double));
  rscale = mxCalloc(ld, sizeof(double));
  ggbalwork = mxCalloc(ld*6, sizeof(double));

  LAPACK_dggbal(job, &ld, AA, &ld, BB, &ld, &ilo, &ihi,
		lscale, rscale, ggbalwork, info);

  mxFree(ggbalwork);
  */

  double *alphar, *alphai, *beta;
  double work_query;
  int sdim;
  int ld = n;
  int *bwork;
  int lwork = -1;

  alphar = mxCalloc(ld, sizeof(double));
  alphai = mxCalloc(ld, sizeof(double));
  beta = mxCalloc(ld, sizeof(double));
  bwork = mxCalloc(ld, sizeof(int));

  dgges("V", "V", "S", crit, &ld, AA, &ld, BB, &ld,
	       &sdim, alphar, alphai, beta, QQ, &ld, ZZ, &ld,
	       &work_query, &lwork, bwork, info);

  lwork = (int)work_query;
  double *work;
  work = mxCalloc(lwork, sizeof(double));

  dgges("V", "V", "S", crit, &ld, AA, &ld, BB, &ld,
	       &sdim, alphar, alphai, beta, QQ, &ld, ZZ, &ld,
	       work, &lwork, bwork, info);

  mxFree(work);
  mxFree(alphar);
  mxFree(alphai);
  mxFree(beta);
  mxFree(bwork);
}

// interface between Octave and C
/////////////////////////////////

void
mexFunction (int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[])

{
  /*dimensions of input matrices*/
  size_t m1, n1, m2, n2;
  /*dimension var for DGGES*/
  int ndim;
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
  QQ0 = mxCalloc (m1*m1,sizeof(double));
  ZZ0 = mxCalloc (m1*m1,sizeof(double));
  tmp = mxCalloc (m1*m1,sizeof(double));

  /*copy AA and BB to SS and TT*/
  memcpy (SS, AA, sizeof(double)*m1*m1);
  memcpy (TT, BB, sizeof(double)*m1*m1);

  /*cast the dimension as int*/
  ndim = (int)m1;

  /*first call to DGGES -- leading block has |eigVals| >= 1 + tol*/
  /*AA = QQ0*SS*ZZ0', BB = QQ0*TT*ZZ0'*/
  mydgges (SS, TT, QQ0, ZZ0, ndim, order_eigs, &info);

  /*error?*/
  if (info != 0 && info != (ndim + 3))
    mexErrMsgIdAndTxt ("mydgges:BadInfo","There was an error in DGGES!");

  /*reordering failed?*/
  if (info == ndim + 3)
    mexWarnMsgIdAndTxt ("mydgges:reorderingFailed","Reordering failed in DGGES!");

  /*second call to DGGES -- leading block has ||eigVals|-1| < tol*/
  /*AA = QQ0*QQ*SS*ZZT*ZZ0T, BB = QQ0*QQ*TT*ZZT*ZZ0T*/
  mydgges (SS, TT, QQ, ZZ, ndim, order_eigs1, &info);
  
  /*error?*/
  if (info != 0 && info != (ndim + 3))
    mexErrMsgIdAndTxt ("mydgges:BadInfo","There was an error in DGGES!");
  
  /*reordering failed?*/
  if (info == ndim + 3)
    mexWarnMsgIdAndTxt ("mydgges:reorderingFailed","Reordering failed in DGGES!");
  
  /*in Matlab/Octave's notation Q*AA*Z = SS, which means that*/
  /*Q = QQT*QQ0T and Z = ZZ0*ZZ*/

  /*multiply QQT and QQ0T*/
  double alpha = 1.0, beta = 0.0;
  memcpy (tmp, QQ, sizeof(double)*ndim*ndim);
  dgemm("T","T",&ndim,&ndim,&ndim,&alpha,tmp,&ndim,QQ0,&ndim,&beta,QQ,&ndim);
  
  /*multiply ZZ0 and ZZ*/
  memcpy (tmp, ZZ, sizeof(double)*ndim*ndim);
  dgemm("N","N",&ndim,&ndim,&ndim,&alpha,ZZ0,&ndim,tmp,&ndim,&beta,ZZ,&ndim);

  /*deallocate memory*/
  mxFree(tmp);
  mxFree(QQ0);
  mxFree(ZZ0);

}
