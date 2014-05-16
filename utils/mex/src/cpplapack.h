// Copyright (C) 2005, Ondra Kamenik

// $Id: cpplapack.h 1411 2012-03-15 16:39:18Z okamenik $

#ifndef OGM_CPPLAPACK_H
#define OGM_CPPLAPACK_H

#define LAPACK_dgetrf dgetrf_
#define LAPACK_dgecon dgecon_
#define LAPACK_dgetrs dgetrs_
#define LAPACK_dgees  dgees_
#define LAPACK_dgges  dgges_
#define LAPACK_dsyevr dsyevr_
#define LAPACK_dgeqrf dgeqrf_
#define LAPACK_dorgqr dorgqr_
#define LAPACK_dgelsd dgelsd_
#define LAPACK_dgerqf dgerqf_
#define LAPACK_dorgrq dorgrq_
#define LAPACK_dtrsyl dtrsyl_
#define LAPACK_dgesdd dgesdd_
#define LAPACK_dgesvd dgesvd_
#define LAPACK_dggsvd dggsvd_
#define LAPACK_dormqr dormqr_
#define LAPACK_dormrq dormrq_
#define LAPACK_dggbal dggbal_
#define LAPACK_dpbtrf dpbtrf_
#define LAPACK_dpbtrs dpbtrs_
#define LAPACK_dpotrf dpotrf_
#define LAPACK_dpotrs dpotrs_

typedef int (*DGGESCRIT)(const double*, const double*, const double*);
typedef int (*DGEESCRIT)(const double*, const double*);

#ifdef __cplusplus
extern "C" {
#endif
	void LAPACK_dgetrf(const int* m, const int* n, double* a, const int* lda,
					   int* ipiv, int* info);
	void LAPACK_dgecon(const char* norm, const int* n, const double* a, const int* lda,
					   const double* anorm, double* rcond, double* work, int* iwork,
					   int* info);
	void LAPACK_dgetrs(const char* trans, const int* n, const int* nrhs, const double* a,
					   const int* lda, const int* ipiv, double* b, const int* ldb,
					   int* info);
	void  LAPACK_dgees(const char* jobvs, const char* sort, DGEESCRIT select,
					   const int* n, double* a, const int* lda, int* sdim,
					   double* wr, double* wi, double* vs, const int* ldvs,
					   double* work, const int* lwork, const int* bwork, int* info);
	void  LAPACK_dgges(const char* jobvsl, const char* jobvsr, const char* sort, DGGESCRIT delztg,
					   const int* n, double* a, const int* lda, double* b, const int* ldb,
					   int* sdim, double* alphar, double* alphai, double* beta,
					   double* vsl, const int* ldvsl, double* vsr, const int* ldvsr,
					   double* work, int* lwork, int* bwork, int* info);
	void LAPACK_dsyevr(const char* jobz, const char* range, const char* uplo, const int* n, double* a,
					   const int* lda, double* lv, double* vu, const int* il, const int* iu,
					   const double* abstol, int* m, double* w, double* z, const int* ldz,
					   int* isuppz, double* work, const int* lwork, int* iwork, const int* liwork,
					   int* info);
	void LAPACK_dgeqrf(const int* m, const int* n, double* a, const int* lda, double* tau,
					   double* work, const int* lwork, int* info);
	void LAPACK_dorgqr(const int* m, const int* n, const int* k, double* a, const int* lda,
					   const double* tau, double* work, const int* lwork, int* info);
	void LAPACK_dgelsd(const int* m, const int* n, const int* nrhs, const double* a,
					   const int* lda, double* b, const int* ldb, double* s, const double* rcond,
					   int* rank, double* work, const int* lwork, int* iwork, int* info);
	void LAPACK_dgerqf(const int* m, const int* n, double* a, const int* lda, double* tau,
					   double* work, const int* lwork, int* info);
	void LAPACK_dorgrq(const int* m, const int* n, const int* k, double* a, const int* lda,
					   const double* tau, double* work, const int* lwork, int* info);
	void LAPACK_dtrsyl(const char* trana, const char* tranb, const int* isgn, const int* m,
					   const int* n, const double* a, const int* lda, const double* b,
					   const int* ldb, double* c, const int* ldc, double* scale, int* info);
	void LAPACK_dgesdd(const char* jobz, const int* m, const int* n, double* a, const int* lda,
					   double* s, double* u, const int* ldu, double* vt, const int* ldvt,
					   double* work, const int* lwork, int* iwork, int* info);
	void LAPACK_dgesvd(const char* jobu, const char* jobvt, const int* m, const int* n, double* a,
					   const int* lda, double* s, double* u, const int* ldu, double* vt,
					   const int* ldvt, double* work, const int* lwork, int* info);
	void LAPACK_dggsvd(const char* jobu, const char* jobv, const char* jobq, const int* m,
					   const int* n, const int* p, int* k, int* l, double* a, const int* lda,
					   double* b, const int* ldb, double* alpha, double* beta, double* u,
					   const int* ldu, double* v, const int* ldv, double* q, const int* ldq,
					   double* work, int* iwork, int* info);
	void LAPACK_dormqr(const char* side, const char* trans, const int* m, const int* n,
					   const int* k, double* a, const int* lda, const double* tau, double* c,
					   const int* ldc, double* work, const int* lwork, int* info);
	void LAPACK_dormrq(const char* side, const char* trans, const int* m, const int* n,
					   const int* k, double* a, const int* lda, const double* tau, double* c,
					   const int* ldc, double* work, const int* lwork, int* info);
	void LAPACK_dggbal(const char* job, const int* n, double* a, const int* lda,
					   double* b, const int* ldb, int* ilo, int* ihi,
					   double* lscale, double* rscale, double* work, int* info);
	void LAPACK_dpbtrf(const char* uplo, const int* n, const int* kd, double* ab,
					   const int* ldab, int* info);
	void LAPACK_dpbtrs(const char* uplo, const int* n, const int* kd, const int* nrhs,
					   const double* ab, const int* ldab, double* b, const int* ldb,
					   int* info);
	void LAPACK_dpotrf(const char* uplo, const int* n, double* a,
					   const int* ldab, int* info);
	void LAPACK_dpotrs(const char* uplo, const int* n, const int* nrhs,
					   const double* a, const int* ldab, double* b, const int* ldb,
					   int* info);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif

// Local Variables:
// mode:C++
// End:

