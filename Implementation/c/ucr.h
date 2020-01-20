#ifndef UCR_H_
#define UCR_H_

#include "exact_search.h"

typedef struct q_index {
	double value;
	int    index;
} q_index;

distance d_ucr(void * x, void * y, int T, double bsf, int * order);
void exact_search_ucr(
		double * dataset,
		double * queryset,
		distance (*dist_ptr)(void *, void *, int, double, int *),
		int query_name,
		es * result,
		int I, int T);
void reorder_query(double * query_raw, int * query_order, int T);
int znorm_comp(const void *a, const void* b);

#endif /* UCR_H_ */
