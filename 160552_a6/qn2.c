#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<fcntl.h>
#include<pthread.h>
#include<sys/time.h>

#define MAX_THREADS 64
#define NUM_ACC 10000
#define ACC_START 1001

#define USAGE_EXIT(s) do\
{\
    printf("Usage: %s <acc_file> <txn_file> <# of transactions> <# of threads>\n%s\n", argv[0], s);\
    exit(-1);\
}while(0);

#define TDIFF(start, end) ((end.tv_sec - start.tv_sec) * 1000000UL + (end.tv_usec - start.tv_usec))

pthread_mutex_t lock;
static char *txn_details;
static double *acc_details;
static int num_transactions;
static int trans_done = 0;
static char *dataptr;

void process_trans(char *ptr, int newl_cnt)
{
    int trans_num, trans_type, acc_1, acc_2;
    double amount;
    ptr[newl_cnt] = '\0';
    sscanf(ptr, "%d %d %lf %d %d", &trans_num, &trans_type, &amount, &acc_1, &acc_2);//for(int i=0;i<100;i++){i++;i--;}
    ptr[newl_cnt] = '\n';
    while (trans_num - trans_done != 1);
    switch(trans_type)
    {
        case 1:
            acc_details[acc_1 - ACC_START] += amount * 0.99;
            break;
        case 2:
            acc_details[acc_1 - ACC_START] -= amount * 1.01;
            break;
        case 3:
            acc_details[acc_1 - ACC_START] *= 1.071;
            break;
        case 4:
            acc_details[acc_1 - ACC_START] -= amount * 1.01;
            acc_details[acc_2 - ACC_START] += amount * 0.99;
            break;
    }
    trans_done++;
}

void *update_acc(void *arg)
/*Argument is the end pointer*/
{
    char *cptr;
    char *endptr = (char *)arg;

    while(1)
    {
        pthread_mutex_lock(&lock);
        if(dataptr >= endptr)
        {
            pthread_mutex_unlock(&lock);
            break;
        }
        cptr = dataptr;

        int newl_cnt;
        for (newl_cnt = 0; newl_cnt < endptr - dataptr; newl_cnt++)
            if (dataptr[newl_cnt] == '\n')
                break;

        dataptr += newl_cnt + 1;
        pthread_mutex_unlock(&lock);

        if (trans_done > num_transactions)
            break;
        else
            process_trans(cptr, newl_cnt); 
    }
    pthread_exit(NULL); 
}

void get_acc_details_whole(char* file_name)
{
    int acc_file;
    unsigned long size, bytes_read = 0;
    char *buff, *buff_end;

    acc_file = open(file_name, O_RDONLY);
    if(acc_file < 0)
    {
        printf("Can not open file\n");
        exit(-1);
    } 
    
    size = lseek(acc_file, 0, SEEK_END);
    if(size <= 0)
    {
        perror("lseek");
        exit(-1);
    }
    
    if(lseek(acc_file, 0, SEEK_SET) != 0)
    {
        perror("lseek");
        exit(-1);
    }
   
    buff = malloc(size);
    if(!buff)
    {
        perror("mem");
        exit(-1);
    }   

    /*Read the complete file into buff*/
    do
    {
        unsigned long bytes;
        buff_end = buff + bytes_read;
        bytes = read(acc_file, buff_end, size - bytes_read);
        if(bytes < 0)
        {
            perror("read");
            exit(-1);
        }
        bytes_read += bytes;
    }while(size != bytes_read);

    acc_details = (double*)malloc(NUM_ACC * sizeof(double));
    char *line = buff;
    for (int i = 0; i < NUM_ACC; i++)
    {
        int newl_cnt;
        for (newl_cnt = 0; newl_cnt < buff + size - line; newl_cnt++)
            if (line[newl_cnt] == '\n')
                break;

        int acc_num;
        double acc_balance;
        line[newl_cnt] = '\0';
        sscanf(line, "%d %lf", &acc_num, &acc_balance);
        line[newl_cnt] = '\n';
        line = line + newl_cnt + 1;
        acc_details[acc_num - ACC_START] = acc_balance;
    }

    free(buff);
    close(acc_file);
}

void get_acc_details_line_by_line(char* file_name)
{
    FILE *acc_file;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;

    acc_file = fopen(file_name, "r");
    if(!acc_file)
    {
        printf("Can not open file\n");
        exit(-1);
    }

    acc_details = (double*)malloc(NUM_ACC * sizeof(double));
    while((read = getline(&line, &len, acc_file)) != -1)
    {
        int acc_num;
        double acc_balance;
        sscanf(line, "%d %lf", &acc_num, &acc_balance);
        acc_details[acc_num - ACC_START] = acc_balance;
    }

    fclose(acc_file);
    if (line)
        free(line);
}

unsigned long get_txn_details(char* file_name)
{
    int txn_file;
    unsigned long size, bytes_read = 0;
    char *txn_details, *buff_end;

    txn_file = open(file_name, O_RDONLY);
    if(txn_file < 0)
    {
        printf("Can not open file\n");
        exit(-1);
    } 
    
    size = lseek(txn_file, 0, SEEK_END);
    if(size <= 0)
    {
        perror("lseek");
        exit(-1);
    }
    
    if(lseek(txn_file, 0, SEEK_SET) != 0)
    {
        perror("lseek");
        exit(-1);
    }
   
    txn_details = (char*) malloc(size);
    if(!txn_details)
    {
        perror("mem");
        exit(-1);
    }   

    /*Read the complete file into txn_details
    XXX Better implemented using mmap */
    do
    {
        unsigned long bytes;
        buff_end = txn_details + bytes_read;
        bytes = read(txn_file, buff_end, size - bytes_read);
        if(bytes < 0)
        {
            perror("read");
            exit(-1);
        }
        bytes_read += bytes;
    }while(size != bytes_read);

    dataptr = txn_details;
    close(txn_file);
    return size;
}

int main(int argc, char **argv)
{
    int ctr, num_threads;
    unsigned long size;
    char *buff_end;
    struct timeval start, end;

    if(argc != 5)
        USAGE_EXIT("Not enough parameters");

    num_transactions = atoi(argv[3]);
    if(num_transactions <= 0)
        USAGE_EXIT("Invalid number of transactions");

    num_threads = atoi(argv[4]);
    if(num_threads <= 0 || num_threads > MAX_THREADS)
        USAGE_EXIT("Invalid number of threads");
    pthread_t threads[num_threads];

    get_acc_details_line_by_line(argv[1]);
    size = get_txn_details(argv[2]);
    pthread_mutex_init(&lock, NULL);
    buff_end = dataptr + size;

    gettimeofday(&start, NULL);
    for(ctr=0; ctr < num_threads; ++ctr)
    {
        if(pthread_create(&threads[ctr], NULL, update_acc, buff_end) != 0)
        {
            perror("pthread_create");
            exit(-1);
        }
    }
    
    for(ctr=0; ctr < num_threads; ++ctr)
        pthread_join(threads[ctr], NULL);

    for(ctr=0; ctr < NUM_ACC; ++ctr)
        printf("%d %.2f\n", ACC_START + ctr, acc_details[ctr]);  
    
    gettimeofday(&end, NULL);
    /*printf("Time taken = %ld microsecs\n", TDIFF(start, end));*/

    free(txn_details);
    free(acc_details);
    return 0;
}
