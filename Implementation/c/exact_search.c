#include "exact_search.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>

#include "exact_search_ucr.h"
#include "load.h"

int cmp(const void *a, const void *b) {
	idx_val *a1 = (idx_val *) a;
	idx_val *a2 = (idx_val *) b;
    if (a1->value < a2->value)
        return -1;
    else if (a1->value > a2->value)
        return 1;
    else
        return 0;
}

struct timespec diff(struct timespec start, struct timespec end) {
  struct timespec temp;
  if ((end.tv_nsec-start.tv_nsec)<0) {
    temp.tv_sec = end.tv_sec-start.tv_sec-1;
    temp.tv_nsec = 1000000000+end.tv_nsec-start.tv_nsec;
  } else {
    temp.tv_sec = end.tv_sec-start.tv_sec;
    temp.tv_nsec = end.tv_nsec-start.tv_nsec;
  }
  return temp;
}

distance d_ed(void * x, void * y, int T, double bsf, int * order) {
	double * x_flt = (double *) x;
	double * y_flt = (double *) y;
	double d = 0.0;
	// struct timespec time1, time2;

	// clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time1);

	for (int t = 0; t < T; t++) {
		d += (x_flt[t] - y_flt[t]) * (x_flt[t] - y_flt[t]);
//		if (d > bsf)
//			break; // slows down ED
	}
	// d = sqrt(d);

	// clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time2);

	distance ret;
	ret.distance = d;
	ret.elapsed = 0; //diff(time1, time2).tv_sec * 1000000000 + diff(time1, time2).tv_nsec;

	return(ret);
}

void exact_search_ed(
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

//	double * query_raw = (double *) malloc(sizeof(double) * T);
//	double * cand_raw = (double *) malloc(sizeof(double) * T);
	double * query_raw = queryset + query_name * T;
	double * cand_raw;

//	read_series(queryset, query_name, T, query_raw);
	for (int cand_name = 0; cand_name < I; cand_name++) {
//		read_series(dataset, cand_name, T, cand_raw);
		cand_raw = dataset + cand_name * T;
		distance res = (*dist_ptr)(query_raw, cand_raw, T, nn_dist, NULL);
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

void exact_search_store(es * result, char * path, char * fn, int I) {
	FILE *fd;
	char fp[1024];

	file_path(fp, path, fn);

	fd = fopen(fp, "w");
	fprintf(fd, "name;raw;repr;n_raw;n_repr;el_repr;el_raw\n");
	for (int i = 0; i < I; i++) {
		fprintf(fd, "%i;%f;%f;%i;%i;%ld;%ld\n",
				result[i].name,
				result[i].raw,
				result[i].repr,
				result[i].n_raw,
				result[i].n_repr,
				result[i].el_repr,
				result[i].el_raw);
	}

	fclose(fd);
}

int exact_search_load(es * result, char * path, char * fn, int I) {
	FILE *fd;
	char fp[1024];

	char puffer[1024];

	file_path(fp, path, fn);

	fd = fopen(fp, "r");

	bool header = true;
	int i = 0;
	while(fgets(puffer, 1024, fd)) {
		if (header) {
			header = false;
			continue;
		}

		sscanf(puffer, "%i;%lf;%lf;%i;%i;%ld;%ld\n",
				&result[i].name,
				&result[i].raw,
				&result[i].repr,
				&result[i].n_raw,
				&result[i].n_repr,
				&result[i].el_repr,
				&result[i].el_raw);

		i++;
	}

	fclose(fd);

	return i;
}

void exact_search_store_dist(idx_val *id, char * path, char * fn, int I) {
	FILE *fd;
	char fp[1024];

	file_path(fp, path, fn);

	fd = fopen(fp, "w");
	fprintf(fd, "name;value\n");
	for (int i = 0; i < I; i++) {
		fprintf(fd, "%i;%f\n",
				id[i].index,
				id[i].value);
	}

	fclose(fd);
}
