template< typename T >
struct Complex
{
    float real;
    float imag;

    __device__
        Complex( T r = 0, T i = 0 ) : real( r ), imag( i ) {}

    __device__
        Complex< T > operator+( const Complex< T >& b ) const
    {
        return Complex< T >( real + b.real, imag + b.imag );
    }

    __device__
        Complex< T > operator-( const Complex< T >& b ) const
    {
        return Complex< T >( real - b.real, imag - b.imag );
    }

    __device__
        Complex< T > operator*( const Complex< T >& b ) const
    {
        return Complex< T >( real * b.real - imag * b.imag, real * b.imag + imag * b.real );
    }

    __device__
        Complex< T > operator/( const Complex< T >& b ) const
    {
        float denom = b.real * b.real + b.imag * b.imag;
        return Complex< T >(
            ( real * b.real + imag * b.imag ) / denom,
            ( imag * b.real - real * b.imag ) / denom
        );
    }
};