#include<stdio.h>
#include<stdlib.h>
#include<fcntl.h>
#include<pthread.h>
#include<sys/time.h>

#define THREADS 8
#define TDIFF(start, end) ((end.tv_sec - start.tv_sec) * 1000000UL + (end.tv_usec - start.tv_usec))

pthread_mutex_t lock[10000];
static char *dataptr;
static char *dataptr1;
int acc_no[10000];
float amt[10000];
pthread_mutex_t lock1;
int g=0;

void *func(void *arg)
{
   char *cptr;
   unsigned long *chash;
   char *endptr = (char *)arg;
 
   while(1){     
        pthread_mutex_lock(&lock1);   
        if(dataptr >= endptr){
            for(int y=0;y<10000;y++)
              pthread_mutex_unlock(&lock[y]);
            pthread_mutex_unlock(&lock1);
            break;
        }  
  
        int v=0;  
        cptr = dataptr;
        while(*(cptr+v)!='\n')
             v++;
        //*(cptr+v)='\0';
        //printf("%s\n",cptr);
        dataptr+=v+1;
         
        pthread_mutex_unlock(&lock1);

	/*for (int j = 0; j < 1000; j++)
	{
		j++;
		j--;
	} */    
	/*Perform the real calculation*/
        //printf("%s\n",cptr);
        // printf("%d\n",++g); 
        int i=0;  
        char *ptr[3];
        int j=0;
        while(*(cptr+i)!='\n')
           {
             i++;
             if(*(cptr+i)=='\t')
                 {
                   *(cptr+i)='\0';
                   ptr[j++]=cptr+i+1;   
                 } 
           }
        *(cptr+i)='\0';
        int trans_type=atoll(ptr[0]);
        float trans_amt=atof(ptr[1]);
        int acc1=atoll(ptr[2]);
        int acc2=atoll(ptr[3]); 
        //printf("%d\n",acc1); 
       pthread_mutex_lock(&lock[acc1-1001]);  
       
        if(trans_type==1)
         {   //printf("type 1 done on acc %d \n",acc1); 
             //pthread_mutex_lock(&lock[acc1-1001]); 
             amt[acc1-1001]+=0.99*trans_amt;
             //printf("%d type 1 done on acc %d \n",++g,acc1); 
             //pthread_mutex_unlock(&lock[acc1-1001]); 
         }
        else if (trans_type==2)
          {  //printf("type 2 done on acc %d \n",acc1); 
             //pthread_mutex_lock(&lock[acc1-1001]); 
             amt[acc1-1001]-=1.01*trans_amt;
             //printf("%d type 2 done on acc %d \n",++g,acc1);
             //pthread_mutex_unlock(&lock[acc1-1001]);
          }

        else if (trans_type==3)
          {  
             //pthread_mutex_lock(&lock[acc1-1001]);
             //printf("%d no_backup for acc %d\n",++g,acc1);
              amt[acc1-1001]=1.071*amt[acc1-1001];
             //pthread_mutex_unlock(&lock[acc1-1001]);
          }      
        else
        { //printf("type 4 done btw acc %d and acc %d \n",acc1,acc2); 
          //pthread_mutex_lock(&lock[acc1-1001]);
            amt[acc1-1001]-=(1.01*trans_amt);
            //printf("%d type 4 done btw acc %d and acc %d \n",++g,acc1,acc2); 
          //pthread_mutex_unlock(&lock[acc1-1001]);  
   
          pthread_mutex_lock(&lock[acc2-1001]);
            amt[acc2-1001]+=(0.99*trans_amt);
          //printf("type 4 done btw acc %d and acc %d \n",acc1,acc2);  
          pthread_mutex_unlock(&lock[acc2-1001]); 
        }

         pthread_mutex_unlock(&lock[acc1-1001]);  
                
           
  }
//!!!!!!
  pthread_exit(NULL); 
}

int main(int argc, char **argv)
{
     int fd, ctr;
     unsigned long size, bytes_read = 0;
     char *buff, *cbuff;
     
     //defining variables for accounts file 
     int fd1, ctr1;
     unsigned long size1, bytes_read1 = 0;
     char *buff1, *cbuff1;

     //int THREADS=argv[4];
     //int no_trans=argv[3];
     pthread_t threads[THREADS];
     //int THREADS=argv[4]; 
///////////////////////////////////////////
    //reading transactionn file
     fd = open(argv[2], O_RDONLY);
     if(fd < 0){
           printf("Can not open file\n");
           exit(-1);
     } 
    
    size = lseek(fd, 0, SEEK_END);
    if(size <= 0){
           perror("lseek");
           exit(-1);
    }
    
    if(lseek(fd, 0, SEEK_SET) != 0){
           perror("lseek");
           exit(-1);
    }
   
    buff = malloc(size);
    if(!buff){
           perror("mem");
           exit(-1);
    }   
    do{
         unsigned long bytes;
         cbuff = buff + bytes_read;
         bytes = read(fd, cbuff, size - bytes_read);
         if(bytes < 0){
             perror("read");
             exit(-1);
         }
        bytes_read += bytes;
     }while(size != bytes_read);
     
     dataptr = buff;
     cbuff = buff + size; 
/////////////////////////////////////////////
     //reading accounts file
      fd1 = open(argv[1], O_RDONLY);
      
     if(fd1 < 0){
           printf("Can not open file\n");
           exit(-1);
     } 
    
    size1 = lseek(fd1, 0, SEEK_END);
    if(size1 <= 0){
           perror("lseek");
           exit(-1);
    }
    
    if(lseek(fd1, 0, SEEK_SET) != 0){
           perror("lseek");
           exit(-1);
    }
   
    buff1 = malloc(size1);
    if(!buff1){
           perror("mem");
           exit(-1);
    }   
   
    do{
         unsigned long bytes1;
         cbuff1 = buff1 + bytes_read1;
         bytes1 = read(fd1, cbuff1, size1 - bytes_read1);
         if(bytes1 < 0){
             perror("read");
             exit(-1);
         }
        bytes_read1 += bytes1;
     }while(size1 != bytes_read1);
 
dataptr1=buff1;      
 //printf("%s",dataptr1);

///////////////////////////////////////////////
//new way to read account file
  int i=0;
   FILE *file = fopen (argv[1], "r" );
   if ( file != NULL )
   {
       char line[128]; 
      while ( fgets ( line, sizeof line, file ) != NULL ) /* read a line */
     {
         int j=0,k=0;
         while(line[j]!='\n')
           { 
             j++;
             if(line[j]=='\t')
                {
                  line[j]='\0';
                  k=j;
                 } 
           }   
         line[j]='\0';
         acc_no[i]=atoll(line);
         amt[i]=atof(line+k+1);
         //printf("%d %.2f\n",acc_no[i],amt[i]);
         i++;   
      }
      fclose ( file );
   }
   else
   {
      perror ( argv[1] ); /* why didn't the file open? */
   }



////////////////////////////////
 //reading done, Now making threads to work
     for(int r=0;r<10000;r++)
          pthread_mutex_init(&lock[r], NULL);
  
     pthread_mutex_init(&lock1,NULL);   

     struct timeval start, end;
 
     gettimeofday(&start, NULL);
     for(ctr=0; ctr < THREADS; ++ctr){
        if(pthread_create(&threads[ctr], NULL, func, cbuff) != 0){
              perror("pthread_create");
              exit(-1);
        }
 
     }
     
     for(ctr=0; ctr < THREADS; ++ctr)
            pthread_join(threads[ctr], NULL);

    gettimeofday(&end, NULL);
    //printf("Time taken = %ld microsecs\n", TDIFF(start, end));
    for(int p=0;p<10000;p++)
    {
        printf("%d %.2f\n",p+1001,amt[p]);  
    }
 
     free(buff);
     close(fd);
}

