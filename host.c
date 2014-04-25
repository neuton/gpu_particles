#include "opencl.h"

typedef struct{real x, y, z;} v3r;

static cl_kernel kernel_compute_forces, kernel_update_positions;
static cl_var gpu_r, gpu_v, gpu_a, gpu_m, gpu_n;

extern void gpu_init(const uint n, const real m[], const v3r r[], const v3r v[])
{
	opencl_init(GPU);
	cl_program program = opencl_create_program("kernel.cl", NULL);
	kernel_compute_forces = opencl_create_kernel(program, "compute_forces");
	kernel_update_positions = opencl_create_kernel(program, "update_positions");
	gpu_r = opencl_create_var(sizeof(v3r), n, 0, r);
	gpu_v = opencl_create_var(sizeof(v3r), n, 0, v);
	gpu_a = opencl_create_var(sizeof(v3r), n, 0, NULL);
	gpu_m = opencl_create_var(sizeof(real), n, CL_MEM_READ_ONLY, m);
	gpu_n = opencl_create_var(sizeof(uint), 1, 0, &n);
	opencl_set_kernel_args(kernel_compute_forces, gpu_n, gpu_r, gpu_m, gpu_a);
	opencl_set_kernel_args(kernel_update_positions, gpu_n, gpu_r, gpu_v, gpu_a);
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
