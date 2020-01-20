#ifndef EXACT_SEARCH_H_
#define EXACT_SEARCH_H_

typedef struct es_struct {
   int name;
   double raw;
   double repr;
   int n_repr;
   int n_raw;
   long el_repr;
   long el_raw;
} es;

typedef struct idx_val
{
    int index;
    double value;
} idx_val;

typedef struct distance {
	double distance;
	long elapsed;
} distance;

struct timespec diff(struct timespec start, struct timespec end);

distance d_ed(void * x, void * y, int T, double bsf, int * order);

void exact_search_ed(
		double * dataset,
		double * queryset,
		distance (*dist_ptr)(void *, void *, int, double, int *),
		int query_name,
		es * result,
		int I, int T);
void exact_search_store(es * result, char * path, char * fn, int I);
int exact_search_load(es * result, char * path, char * fn, int I);
void exact_search_store_dist(idx_val *id, char * path, char * fn, int I);
#endif /* EXACT_SEARCH_H_ */
