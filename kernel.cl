#define real float
#define v3r float3	//! on CPU vectorization works ~2 times slower than simple struct???

real len(v3r r)
{
	v3r r2 = r*r;
	return sqrt(r2.x + r2.y + r2.z);
}

#define ln 64	// work group size
#define R 1	// closest radius

__kernel __attribute__((reqd_work_group_size(ln, 1, 1)))
void compute_forces_naive(	__global const v3r * r,
							__constant const real * m,
							__global v3r * a)
{
	const uint id = get_global_id(0), n = get_global_size(0);
	v3r dr, r0 = r[id], f = (v3r)(0);
	uint i;
	real d;
	for (i=0; i<n; i++)
	{
		dr = r[i] - r0;
		d = len(dr);
		if (d>R)
			f += dr * m[i]/(d*d*d);
	}
	a[id] = f;
}

__kernel __attribute__((reqd_work_group_size(ln, 1, 1)))
void compute_forces(__global const v3r * r,
					__constant const real * m,
					__global v3r * a)
{
	const uint id = get_global_id(0), lid = get_local_id(0), n = get_global_size(0);
	__local v3r lr[ln], lm[ln];
	v3r dr, r0 = r[id], f = (v3r)(0);
	uint i, k = get_group_id(0)*ln;
	const uint k_end = (k+n-ln) % n;
	real d;
	while (true)
	{
		lr[lid] = r[lid+k];
		lm[lid] = m[lid+k];
		barrier(CLK_LOCAL_MEM_FENCE);
		for (i=0; i<ln; i++)
		{
			dr = lr[i] - r0;
			d = len(dr);
			if (d>R)
				f += dr * lm[i]/(d*d*d);
		}
		if (k==k_end) break;
		k = (k+ln)%n;
	}
	a[id] = f;
}

#define dt 0.01
#define dt2 0.005

__kernel void update_positions(__global v3r * r, __global v3r * v, __global const v3r * a)
{
	uint id = get_global_id(0);
	r[id] += dt * (v[id] + dt2 * a[id]);
	v[id] += dt * a[id];
}
