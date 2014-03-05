#define real float

typedef struct{real x, y, z;} v3r;

real sqr(real a)
{
	return a*a;
}

v3r add(v3r a, v3r b)
{
	v3r t = {a.x + b.x, a.y + b.y, a.z + b.z};
	return t;
}

v3r sub(v3r a, v3r b)
{
	v3r t = {a.x - b.x, a.y - b.y, a.z - b.z};
	return t;
}

v3r mul(real a, v3r v)
{
	v3r t = {a*v.x, a*v.y, a*v.z};
	return t;
}

real len(v3r r)
{
	return sqrt(sqr(r.x)+sqr(r.y)+sqr(r.z));
}

#define G 1
#define R 1
__kernel void compute_forces(const uint n, __global const v3r * r, __global const real * m, __global v3r * a)
{
	uint id = get_global_id(0);
	if (id<n)
	{
		uint i;
		real d;
		v3r dr, r0 = r[id], f = {0.,0.,0.};
		for (i=0; i<n; i++)
			if (i!=id)
			{
				dr = sub(r[i], r0);
				d = len(dr);
				if (d>R)
					f = add(f, mul(m[i]/(d*d*d), dr));
//				else
//					f = add(f, mul(m[i]/(d*R*R), dr));
			}
		a[id] = mul(G, f);
	}
}

#define dt 0.01
__kernel void update_positions(const uint n, __global v3r * r, __global v3r * v, __global const v3r * a)
{
	uint id = get_global_id(0);
	if (id<n)
	{
		r[id] = add(r[id], mul(dt, add(v[id], mul(dt*0.5, a[id]))));
		v[id] = add(v[id], mul(dt, a[id]));
	}
}
