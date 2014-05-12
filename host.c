#include "opencl.h"

#define v3r cl_float3

static cl_kernel kernel_compute_forces, kernel_update_positions;
static cl_var gpu_r, gpu_v, gpu_a, gpu_m;

extern void gpu_init(const uint n, const uint wg_size, const real m[], const v3r r[], const v3r v[])
{
	opencl_init(GPU);
	cl_program program = opencl_create_program("kernel.cl", NULL);
	kernel_compute_forces = opencl_create_kernel(program, "compute_forces");
	kernel_update_positions = opencl_create_kernel(program, "update_positions");
	gpu_r = opencl_create_var(sizeof(v3r), n, 0, r);
	gpu_v = opencl_create_var(sizeof(v3r), n, 0, v);
	gpu_a = opencl_create_var(sizeof(v3r), n, 0, NULL);
	gpu_m = opencl_create_var(sizeof(real), n, CL_MEM_READ_ONLY, m);
	opencl_set_kernel_args(kernel_compute_forces, gpu_r, gpu_m, gpu_a);
	opencl_set_kernel_args(kernel_update_positions, gpu_r, gpu_v, gpu_a);
	opencl_set_local_ws(1, wg_size);
	opencl_set_global_ws(1, n);
}

extern void gpu_update()
{
	opencl_run_kernel(kernel_compute_forces);
	opencl_run_kernel(kernel_update_positions);
}

extern void gpu_getval(v3r r[])
{
	opencl_get_var(gpu_r, r);
}


#include <math.h>
#define R 1
#define dt 0.01
#define dt2 0.005

extern void cpu_update(const uint n, const real m[], v3r r[], v3r v[])
{
	v3r dr, r0, f;
	real d;
	uint i, j;
	#pragma omp parallel for private(f, dr, r0, d, i, j)
	for (j=0; j<n; j++)
	{
		f.x = f.y = f.z = 0;
		r0 = r[j];
		for (i=0; i<n; i++)
		{
			dr.x = r[i].x - r0.x;
			dr.y = r[i].y - r0.y;
			dr.z = r[i].z - r0.z;
			d = sqrt(dr.x*dr.x + dr.y*dr.y + dr.z*dr.z);
			if (d>R)
			{
				d = m[i]/(d*d*d);
				f.x += dr.x * d;
				f.y += dr.y * d;
				f.z += dr.z * d;
			}
		}
		r[j].x += dt * (v[j].x + dt2 * f.x);
		r[j].y += dt * (v[j].y + dt2 * f.y);
		r[j].z += dt * (v[j].z + dt2 * f.z);
		v[j].x += dt * f.x;
		v[j].y += dt * f.y;
		v[j].z += dt * f.z;
	}
}
