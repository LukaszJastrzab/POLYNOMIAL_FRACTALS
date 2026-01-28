#include <limits>
#include <vector>
#include <iostream>

#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#include "cuda_kernels.h"
#include "complex.cuh"

#define TX 32
#define TY 32

std::vector< floatType > zeros_real, zeros_imag;
floatType* d_zeros_real{ NULL }, * d_zeros_imag{ NULL };
int zeros_count{ 0 };

double DiffX = 10.0, DiffY = 10.0;
double MidX = 0.0, MidY = 0.0;

double L, R, U, D;

void CalcCoords()
{
	R = MidX + DiffX;
	L = MidX - DiffX;
	U = MidY + DiffY;
	D = MidY - DiffY;
}



int divUp( int a, int b )
{
	return ( a + b - 1 ) / b;
}


template < typename T >
__host__ __device__
Complex< T > f( Complex< T > x )
{
	return x * x * x + 2.0 * x * x + 3.0 * x + 1.0;
}


template< typename T >
__host__ __device__
Complex< T > f_div( Complex< T > x )
{
	return 3.0 * x * x + 4.0 * x + 3.0;
}

__device__
unsigned char clip( int n )
{
	if( n < 0 )
		n = -n;

	return ( n % 255 );
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

__device__
uchar4 siutZeroColor( int zero_idx )
{
	uchar4 color{ 0,0,0,0 };

	switch( zero_idx )
	{
	case 0:
		color.x = 255;
		break;
	case 1:
		color.y = 255;
		break;
	case 2:
		color.z = 255;
		break;
	case 3:
		color.x = 255;
		color.y = 255;
		break;
	case 4:
		color.x = 255;
		color.z = 255;
		break;
	case 5:
		color.y = 255;
		color.z = 255;
		break;
	}

	return color;
}

__host__ __device__
Complex< floatType > NewtonIteration( Complex< floatType > z )
{
	Complex< floatType > denom = f_div( z );

	if( denom.real == floatType( 0.0 ) && denom.imag == floatType( 0.0 ) )
		return z;
	else
		return z - ( f( z ) / denom );
}

constexpr floatType PI = 3.14159265358979323846;
constexpr floatType eps = 1e-5;

std::vector< Complex< floatType > > CalcZeroesCPU( floatType r, int N )
{
	std::vector< Complex< floatType > > out;

	for( int i{ 0 }; i < N; ++i )
	{
		floatType fi = i * 2.0 * PI / N;

		auto z_0 = Complex< floatType >( r * cos( fi ), r * sin( fi ) );
		auto z_n{ NewtonIteration( z_0 ) };

		while( z_n.dist( z_0 ) > eps )
		{
			z_0 = z_n;
			z_n = NewtonIteration( z_0 );
		}

		bool already_found{ false };
		for ( const auto& z : out  )
			if( z_n.dist( z ) <= eps )
			{
				already_found = true;
				break;
			}

		if( !already_found )
			out.push_back( z_n );
	}

	return out;
}

__global__
void NewtonKernel(floatType* zeros_real, floatType* zeros_imag, int zeros_N, uchar4* d_out, int w, int h, int left, int right, int down, int up )
{
	const int c = blockIdx.x * blockDim.x + threadIdx.x;
	const int r = blockIdx.y * blockDim.y + threadIdx.y;

	if( c >= w || r >= h )
		return;

	floatType x = scaleXY( c, w, left, right );
 	floatType y = scaleXY( r, h, down, up );

	int g_idx = flatten( c, r, w, h );

	Complex< floatType > z_0( x, y );

	Complex< floatType > z_n{ NewtonIteration( z_0 ) };

	while( z_n.dist( z_0 ) > eps )
	{
		z_0 = z_n;
		z_n = NewtonIteration( z_0 );
	}

	int idx{ 0 };
	for( ; idx < zeros_N; ++idx )
		if( sqrt( ( z_n.real - zeros_real[ idx ] ) * ( z_n.real - zeros_real[ idx ] ) +
			( z_n.imag - zeros_imag[ idx ] ) * ( z_n.imag - zeros_imag[ idx ] ) ) <= eps )
			break;

	d_out[ g_idx ] = siutZeroColor( idx );
}

void prepareKernelData()
{
	auto zeros = CalcZeroesCPU( 10, 120 );
	for( const auto& z : zeros )
	{
		zeros_real.push_back( z.real );
		zeros_imag.push_back( z.imag );

		std::cout << z.real << " ";
		if( z.imag >= 0 )
			std::cout << "+";
		std::cout << z.imag << "i\n";
	}

	zeros_count = zeros.size();

	cudaMalloc( &d_zeros_real, zeros_count * sizeof( floatType ) );
	cudaMalloc( &d_zeros_imag, zeros_count * sizeof( floatType ) );

	cudaMemcpy( d_zeros_real, zeros_real.data(), zeros_count * sizeof( floatType ), cudaMemcpyHostToDevice );
	cudaMemcpy( d_zeros_imag, zeros_imag.data(), zeros_count * sizeof( floatType ), cudaMemcpyHostToDevice );
}

void cleanKernelData()
{
	cudaFree( d_zeros_real );
	cudaFree( d_zeros_imag );
}

void kernelLauncher( uchar4* d_out, int w, int h )
{
	const dim3 blockSize( TX, TY );
	const dim3 gridSize( divUp( w, TX ), divUp( h, TY ) );
	const size_t locMemSize = TX * TY * sizeof( floatType );

	if( d_zeros_real == NULL || d_zeros_imag == NULL || zeros_count == 0 )
		throw;

	NewtonKernel <<< gridSize, blockSize, locMemSize >>> ( d_zeros_real, d_zeros_imag, zeros_count, d_out, w, h, L, R, D, U );
}