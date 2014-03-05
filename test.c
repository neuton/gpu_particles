#include <stdio.h>

#include "host.c"

int main()
{
	uint n = 2;
	v3r r[2] = {{2,3,4}, {4,5,6}}, f[2];
	real m[2] = {1,1};
	gpu_init(n);
	gpu_compute_forces(n,r,m,f);
	printf("%f %f\n", r[0].x, r[1].y);
	printf("%f %f\n", f[0].x, f[1].y);
	return 0;
}
