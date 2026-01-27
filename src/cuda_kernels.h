#pragma once

#include "complex.cuh"

struct uchar4;
struct int2;

using floatType = double;

template < typename T >
__host__ __device__
Complex< T > f( Complex< T > x );

template< typename T >
__host__ __device__
Complex< T > f_div( Complex< T > x );

__host__ __device__
Complex< floatType > NewtonIteration( Complex< floatType > z );

void prepareKernelData();
void cleanKernelData();

void kernelLauncher( uchar4* d_out, int w, int h );