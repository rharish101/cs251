#include<stdio.h>
#include<stdlib.h>
#include<sys/time.h>

#define CUDA_ERROR_EXIT(str) do{\
                                    cudaError err = cudaGetLastError();\
                                    if( err != cudaSuccess){\
                                             printf("Cuda Error: '%s' for %s\n", cudaGetErrorString(err), str);\
                                             exit(-1);\
                                    }\
                             }while(0);
#define TDIFF(start, end) ((end.tv_sec - start.tv_sec) * 1000000UL + (end.tv_usec - start.tv_usec))
#define USAGE_EXIT(s) do\
{\
    printf("Usage: %s <# of elements> <random seed> \n%s\n", argv[0], s);\
    exit(-1);\
}while(0);

__global__ void xor_piece(int *arr, int *step, int num)
{
    int i = (blockDim.x * blockIdx.x + threadIdx.x);
    if (((float) num) / i < *step)
        return;
    i *= *step;
    if ((i >= num) || ((i + (*step) / 2) >= num))
        return;
    arr[i] ^= arr[i + (*step) / 2];
}

__global__ void double_step(int* step)
{
    *step *= 2;
}

int main(int argc, char **argv)
{
    struct timeval start, end, t_start, t_end;
    int i;
    int *host_mem;
    int *gpu_mem;
    int *host_step;
    int *gpu_step;
    int *answer;
    unsigned long num;   /*Default value of num from MACRO*/
    int blocks, seed;

    if(argc != 3)
        USAGE_EXIT("Not enough parameters");

    num = atoi(argv[1]);   /*Update after checking*/
    if(num <= 0)
        USAGE_EXIT("Invalid number of elements");

    seed = atoi(argv[2]);   /*Update after checking*/
    if(seed <= 0)
        USAGE_EXIT("Invalid number of elements");

    /* Allocate host (CPU) memory and initialize*/
    host_mem = (int*)malloc(num * sizeof(int));
    srand(seed);
    for(i=0; i<num; ++i){
       host_mem[i] = random();
    }
    answer = (int*)malloc(sizeof(int));
    host_step = (int*)malloc(sizeof(int));
    *host_step = 2;
    
    gettimeofday(&t_start, NULL);
    
    /* Allocate GPU memory and copy from CPU --> GPU*/
    cudaMalloc(&gpu_mem, num * sizeof(int));
    CUDA_ERROR_EXIT("cudaMalloc");
    cudaMalloc(&gpu_step, sizeof(int));
    CUDA_ERROR_EXIT("cudaMalloc");

    cudaMemcpy(gpu_mem, host_mem, num * sizeof(int) , cudaMemcpyHostToDevice);
    CUDA_ERROR_EXIT("cudaMemcpy");
    cudaMemcpy(gpu_step, host_step, sizeof(int) , cudaMemcpyHostToDevice);
    CUDA_ERROR_EXIT("cudaMemcpy");
    
    gettimeofday(&start, NULL);
    
    blocks = num / 2048;
    if(num % 2048)
        ++blocks;

    while((*host_step / 2) <= num)
    {
        xor_piece<<<blocks, 1024>>>(gpu_mem, gpu_step, num);
        CUDA_ERROR_EXIT("kernel invocation");

        double_step<<<1, 1>>>(gpu_step);
        CUDA_ERROR_EXIT("kernel invocation");
        *host_step *= 2;
    }

    gettimeofday(&end, NULL);
    
    /* Copy back result*/
    cudaMemcpy(answer, gpu_mem, sizeof(int) , cudaMemcpyDeviceToHost);
    CUDA_ERROR_EXIT("memcpy");

    gettimeofday(&t_end, NULL);
    
    printf("Total time = %ld microsecs. Processsing = %ld microsecs\n", TDIFF(t_start, t_end), TDIFF(start, end));
    cudaFree(gpu_mem);
   
    /*Print the answer*/ 
    printf("Result = %d\n", *answer);

    /**answer = 0;
    for (i = 0; i < num; i++)
        *answer ^= host_mem[i];
    printf("Actual answer = %d\n", *answer);*/
    
    free(host_mem);
    free(host_step);
    free(answer);
}
