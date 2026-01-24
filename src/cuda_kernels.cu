#include <limits>

#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#include "cuda_kernels.h"
#include "complex.cuh"

#define TX 32
#define TY 32

const double initRight = 10.0;
const double initLeft = -initRight;
const double initUp = 10.0;
const double initDown = -initUp;


using floatType = double;

int divUp( int a, int b )
{
	return ( a + b - 1 ) / b;
}


template < typename T >
__device__
Complex< T > f( Complex< T > x )
{
    return x * x * x + Complex< T >( -5.0 ) * x * x + Complex< T >( 2.0 ) * x + 1;
}


template< typename T >
__device__
Complex< T > f_div( Complex< T > x )
{
	const auto h = Complex< T >( 0.0, 1e-20 );

	return ( f( x + h ) - f( x - h ) ) / ( Complex < T >( 2 ) * h );
}

__device__
unsigned char clip( int n )
{
	return n > 255 ? 255 : ( n < 0 ? 0 : n );
}

__device__
int idxClip( int idx, int idxMax )
{
	return idx > ( idxMax - 1 ) ? ( idxMax - 1 ) : ( idx < 0 ? 0 : idx );
}

__device__
int flatten( int col, int row, int width, int height )
{
	return idxClip( col, width ) + idxClip( row, height ) * width;
}

__device__
floatType scaleXY( int rc, int wh, float ld, float ru )
{
	return ld + ( ru - ld ) * rc / wh;
}


__global__
void NewtonKernel( uchar4* d_out, int w, int h, int left, int right, int down, int up )
{
	const int c = blockIdx.x * blockDim.x + threadIdx.x;
	const int r = blockIdx.y * blockDim.y + threadIdx.y;

	floatType x = scaleXY( c, w, left, right );
	floatType y = scaleXY( r, h, down, up );

	int g_idx = flatten( c, r, w, h );

	Complex< floatType > z_0( x, y );

	const int max_count{ 100 };
	int idx{ 0 };

	while( idx++ < max_count )
		z_0 = z_0 - ( f( z_0 ) / f_div( z_0 ) );

	d_out[ g_idx ].x = clip( c / 3 );
	d_out[ g_idx ].y = clip( r / 3 );
	d_out[ g_idx ].z = 0;



}

void kernelLauncher( uchar4* d_out, int w, int h )
{
	const dim3 blockSize( TX, TY );
	const dim3 gridSize( divUp( w, TX ), divUp( h, TY ) );
	const size_t locMemSize = TX * TY * sizeof( floatType );

	NewtonKernel <<< gridSize, blockSize, locMemSize >>> ( d_out, w, h, initLeft, initRight, initDown, initRight );


}