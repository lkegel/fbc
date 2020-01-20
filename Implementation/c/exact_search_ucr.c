#include "exact_search_ucr.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "exact_search.h"
#include "load.h"
#include "ucr.h"

int main(int argc, char **argv) {

	struct timespec time1, time2;
	clock_gettime(CLOCK_REALTIME, &time1);

	char *path = argv[1];
	char *fn_dataset = argv[2];
	char *fn_queryset = argv[3];
	char *fn_es = argv[4];
	char *dist = argv[5];
	int I = atoi(argv[6]);
	int T = atoi(argv[7]);
	int Q = atoi(argv[8]);

	void (*es_ptr)(double *, double *, distance (*dist_ptr)(void *, void *, int, double, int *), int, es *, int, int);
	distance (*dist_ptr)(void *, void *, int, double, int *);

	char fp_dataset[1024], fp_queryset[1024];
	file_path(fp_dataset, path, fn_dataset);
	file_path(fp_queryset, path, fn_queryset);

	double *dataset = (double *) malloc(sizeof(double) * I * T);
	double *queryset = (double *) malloc(sizeof(double) * Q * T);
	read_dataset(fp_dataset, I, T, dataset);
	read_dataset(fp_queryset, Q, T, queryset);

	if (strcmp(dist, "ED") == 0) {
		es_ptr = &exact_search_ed;
		dist_ptr = &d_ed;
	} else if (strcmp(dist, "UCR") == 0) {
		es_ptr = &exact_search_ucr;
		dist_ptr = &d_ucr;
	} else {
		printf("Unknown representation: %s\n", argv[7]);
		return EXIT_FAILURE;
	}

	es *result = (es *) malloc(I * sizeof(es));
	for (int q = 0; q < Q; q++) {
		printf(".");
		fflush(stdout);
		(*es_ptr)(dataset, queryset, dist_ptr, q, result + q, I, T);
	}
	exact_search_store(result, path, fn_es, Q);
	clock_gettime(CLOCK_REALTIME, &time2);

	double elapsed = (double) (diff(time1, time2).tv_sec * 1000000000 + diff(time1, time2).tv_nsec) / 1000000.0;
	printf("Time elapsed [ms]: %f\n", elapsed);

	// fclose(dataset);
	free(dataset);
	free(queryset);

	return EXIT_SUCCESS;
}
