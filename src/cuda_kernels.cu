#include <cuda_runtime.h>

#include "cuda_kernels.h"
#include "complex.cuh"

#define TX 32
#define TY 32

__device__
Complex< float > f( Complex< float > x )
{
    return x * x + Complex< float >( 2.0 ) * x + 1;
}


__device__
unsigned char clip( int n )
{
	return n > 255 ? 255 : ( n < 0 ? 0 : n );
}

__global__
void NewtonKernel()
{
}

void kernelLauncher( uchar4* d_out, int w, int h )
{
	NewtonKernel <<< 1, 1 >>> ( );
}