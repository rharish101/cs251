#include<stdio.h>
#include<stdlib.h>
#include<sys/time.h>
#include<string.h>
#include<pthread.h>
#include<math.h>

#define SEED 0x7457

#define MAX_THREADS 64
#define USAGE_EXIT(s) do\
{\
    printf("Usage: %s <# of elements> <# of threads> \n%s\n", argv[0], s);\
    exit(-1);\
}while(0);

#define TDIFF(start, end) ((end.tv_sec - start.tv_sec) * 1000000UL + (end.tv_usec - start.tv_usec))

struct thread_param
{
    pthread_t tid;
    int *array;
    int size;
    int skip;
    int max;  
    int max_index;
};

int is_prime(int num)
{
    if (num <= 1)
        return -1;
    else if (num <= 3)
        return num;
    else if (num % 2 == 0 || num % 3 == 0)
        return -1;
 
    for (int i=5; i*i <= num; i+=6)
        if (num % i == 0 || num % (i + 2) == 0)
           return -1;
    return num;
}

void* find_max(void *arg)
{
     struct thread_param *param = (struct thread_param *) arg;
     int ctr=0;
     param->max = is_prime(param->array[ctr]);
     param->max_index = ctr;
   
     ctr = param->skip;
     while(ctr < param->size)
     {
           int x = is_prime(param->array[ctr]);
           if(x > param->max)
           {
                param->max = x;
                param->max_index = ctr;
           }
           ctr += param->skip;
     }          
     return NULL;
}

int main(int argc, char **argv)
{
    struct thread_param *params;
    struct timeval start, end;
    int *a, num_elements, ctr, num_threads;
    int max;
    int max_index;

    if(argc !=3)
        USAGE_EXIT("Not enough parameters");

    num_elements = atoi(argv[1]);
    if(num_elements <=0)
        USAGE_EXIT("Invalid number of elements");

    num_threads = atoi(argv[2]);
    if(num_threads <=0 || num_threads > MAX_THREADS)
        USAGE_EXIT("Invalid number of threads");

    a = malloc(num_elements * sizeof(int));
    if(!a)
        USAGE_EXIT("Invalid number of elements, not enough memory");

    /*srand(time(NULL));*/
    srand(SEED);
    for(ctr=0; ctr<num_elements; ++ctr)
        a[ctr] = random();

    /*Allocate thread specific parameters*/
    params = malloc(num_threads * sizeof(struct thread_param));
    bzero(params, num_threads * sizeof(struct thread_param));

    gettimeofday(&start, NULL);

    /*Partion data and create threads*/      
    for(ctr=0; ctr < num_threads; ++ctr)
    {
        struct thread_param *param = params + ctr;
        param->size = num_elements - ctr;
        param->skip = num_threads;
        param->array = a + ctr;
        
        if(pthread_create(&param->tid, NULL, find_max, param) != 0)
        {
            perror("pthread_create");
            exit(-1);
        }
    }
    
    /*Wait for threads to finish their execution*/      
    for(ctr=0; ctr < num_threads; ++ctr)
    {
        struct thread_param *param = params + ctr;
        pthread_join(param->tid, NULL);
        if(ctr == 0 || (ctr > 0 && param->max > max))
        {
            max = param->max;    
            max_index = param->max_index + num_elements - param->size;
        }
    }
        
    if (max == -1)
        printf("No prime number found among input\n");
    else
        printf("Maximum prime number = %d at index=%d\n", max, max_index);
    gettimeofday(&end, NULL);
    printf("Time taken = %ld microsecs\n", TDIFF(start, end));
    free(a);
    free(params);
}
