#include <cuda_runtime.h>

__global__ void dummyKernel()
{
}

void launchDummy()
{
    dummyKernel<<<1,1>>>();
}