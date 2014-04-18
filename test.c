#include <stdio.h>

#include "host.c"

int main()
{
	uint n = 2;
	v3r r[2] = {{2,3,4}, {4,5,6}}, v[2] = {{0,0,0}, {0,0,0}};
	real m[2] = {1,1};
	gpu_init(n,m,r,v);
	gpu_update(r);
	printf("%f %f\n", r[0].x, r[0].y);
	printf("%f %f\n", r[1].x, r[1].y);
	return 0;
}
