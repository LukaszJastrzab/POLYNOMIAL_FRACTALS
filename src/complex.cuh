#pragma once

template< typename T >
struct Complex
{
    float real;
    float imag;

    __host__ __device__
        Complex( T r = 0, T i = 0 ) : real( r ), imag( i ) {}

    __host__ __device__
        Complex< T > operator+( const Complex< T >& b ) const
    {
        return Complex< T >( real + b.real, imag + b.imag );
    }

    __host__ __device__
        Complex< T > operator-( const Complex< T >& b ) const
    {
        return Complex< T >( real - b.real, imag - b.imag );
    }

    __host__ __device__
        Complex< T > operator*( const Complex< T >& b ) const
    {
        return Complex< T >( real * b.real - imag * b.imag, real * b.imag + imag * b.real );
    }

    __host__ __device__
        Complex< T > operator/( const Complex< T >& b ) const
    {
        float denom = b.real * b.real + b.imag * b.imag;
        return Complex< T >(
            ( real * b.real + imag * b.imag ) / denom,
            ( imag * b.real - real * b.imag ) / denom
        );
    }

    __host__ __device__
        T dist( const Complex< T >& b ) const
    {
        return sqrt( ( b.real - real ) * ( b.real - real ) + ( b.imag - imag ) * ( b.imag - imag ) );
    }
};