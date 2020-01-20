//
//  calc_utils.c
//  UCR Suite version
//
//  Created by Lars Kegel on 07/11/2019
//
//  Based on Karima Echihabi on 18/12/2016
//  Copyright 2016 Paris Descartes University. All rights reserved.
//
//  Based on isax code written by Zoumpatianos on 3/12/12.
//  Copyright 2012 University of Trento. All rights reserved.
//

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "load.h"
#include "ucr.h"

#include "exact_search.h"
#include "exact_search_ucr.h"

distance d_ucr(void * x, void * y, int T, double bsf, int * order) {
	double * query = (double *) x;
	double * cand = (double *) y;
	double d = 0.0, value = 0.0;
	int t;

	for (t = 0; t < T && d < bsf; t++) {
		value = cand[order[t]];
		d += (value - query[t]) * (value - query[t]);
	}

	distance ret;
	ret.distance = d;
	ret.elapsed = 0;

	return(ret);
}

void exact_search_ucr(
		double * dataset,
		double * queryset,
		distance (*dist_ptr)(void *, void *, int, double, int *),
		int query_name,
		es * result,
		int I, int T) {

	struct timespec time1, time2;
	clock_gettime(CLOCK_REALTIME, &time1);

	int nn_name = -1;
	double nn_dist = INFINITY;
	int n_raw = 0;

	double * query_raw = queryset + query_name * T; //= (double *) malloc(sizeof(double) * T);
	double * cand_raw; // = (double *) malloc(sizeof(double) * T);
//	read_series(queryset, query_name, T, query_raw);

	// Re-order values
	int * query_order = (int *) malloc(sizeof(int) * T);
	reorder_query(query_raw, query_order, T);

	for (int cand_name = 0; cand_name < I; cand_name++) {
//		read_series(dataset, cand_name, T, cand_raw);
		cand_raw = dataset + cand_name * T;
		distance res = (*dist_ptr)(query_raw, cand_raw, T, nn_dist, query_order);
		// el_raw += res.elapsed;
		double cand_dist = res.distance;
		n_raw++;

		if (cand_dist < nn_dist) {
		      nn_name = cand_name;
		      nn_dist = cand_dist;
		}
	}

//	free(query_raw);
//	free(cand_raw);
	free(query_order);

	clock_gettime(CLOCK_REALTIME, &time2);

	result->name = nn_name;
	result->raw = sqrt(nn_dist);
	result->repr = 0;
	result->n_raw = n_raw;
	result->n_repr = 0;
	result->el_repr = 0;
	result->el_raw = diff(time1, time2).tv_sec * 1000 + diff(time1, time2).tv_nsec / 1000000;

	return;
}

void reorder_query(double * query_raw, int * query_order, int T) {
	q_index *q_tmp = malloc(sizeof(q_index) * T);
	int t;

	for(t = 0; t < T; t++) {
		q_tmp[t].value = query_raw[t];
		q_tmp[t].index = t;
	}

	qsort(q_tmp, T, sizeof(q_index), znorm_comp);

	for(t = 0; t < T; t++) {
		query_raw[t] = q_tmp[t].value;
		query_order[t] = q_tmp[t].index;
	}

	free(q_tmp);
}

int znorm_comp(const void *a, const void* b)
{
    q_index* x = (q_index*) a;
    q_index* y = (q_index*) b;

    //    return abs(y->value) - abs(x->value);

    if (fabsf(y->value) > fabsf(x->value) )
       return 1;
    else if (fabsf(y->value) == fabsf(x->value))
      return 0;
    else
      return -1;
}
