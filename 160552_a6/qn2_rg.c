#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>
#include<string.h>
#include<sys/time.h>
int MAXVAL;

#define TDIFF(start, end) ((end.tv_sec - start.tv_sec) * 1000000UL + (end.tv_usec - start.tv_usec))

typedef struct Transactions{
	int type;
	double amount;
	int acc1;
	int acc2;
	//int isdone;
}transaction;
transaction* curr;
double ar[10001];
static pthread_mutex_t lock[10002];
//pthread_mutex_t* lock=(pthread_mutex_t*)malloc(10002*sizeof(pthread_mutex_t));
int gl=0;

void* acc_update(void* arg)
{	
	transaction* tcurr;
	while(gl<MAXVAL){
		
		pthread_mutex_lock(&lock[10001]);
		tcurr=curr+gl;gl++;
		pthread_mutex_unlock(&lock[10001]);
		int acin1=(tcurr->acc1)-1000;
		int acin2=(tcurr->acc2)-1000;
		//pthread_mutex_lock(&lock[acin1]);
		//if(acin2>=1)pthread_mutex_lock(&lock[acin2]);
		if(tcurr->type==1){
		pthread_mutex_lock(&lock[acin1]);
		ar[acin1]=ar[acin1]+0.99*(tcurr->amount);	
		pthread_mutex_unlock(&lock[acin1]);		
		}	
		else if(tcurr->type==2){
		pthread_mutex_lock(&lock[acin1]);
		ar[acin1]=ar[acin1]-1.01*(tcurr->amount);	
		pthread_mutex_unlock(&lock[acin1]);
		}
		else if(tcurr->type==3){
		pthread_mutex_lock(&lock[acin1]);
		ar[acin1]=1.071*(ar[acin1]);	
		pthread_mutex_unlock(&lock[acin1]);
		}
		else {
		pthread_mutex_lock(&lock[acin1]);
		pthread_mutex_lock(&lock[acin2]);		
		ar[acin2]=ar[acin2]+0.99*(tcurr->amount);
		ar[acin1]=ar[acin1]-1.01*(tcurr->amount);
		pthread_mutex_unlock(&lock[acin1]);
		pthread_mutex_unlock(&lock[acin2]);}
}		
	
}

int main(int argc,char**argv)
{	
	pthread_t *threads;
	struct timeval start, end;
	if(argc !=5)
		   printf("not enough parameters");
	  
	  int num_threads = atoi(argv[4]);
	  MAXVAL=atoi(argv[3]);
	  threads=(pthread_t *)malloc(num_threads*sizeof(pthread_t));
	  if(num_threads <=0 || num_threads > 64){
		  printf("invalid num of threads");
	  }
	  ar[0]=0;

	FILE* fp;
	fp=fopen(argv[1],"r");
	if(fp==NULL)printf("Invalid file input");
	size_t size=0;
	char* line=NULL;
	char *pch;
	int acc;double val2;
	int count;
	while(getline(&line,&size,fp)!=-1)
	{
		pch = strtok(line," ");
		count=0;
		while (pch != NULL)
		{
		  if(count==0){acc=atoi(pch);count++;}
		  else val2=atof(pch);
		  pch = strtok (NULL, " ");
		}
		ar[acc-1000]=val2;
	}
	curr=(transaction*)malloc(MAXVAL*sizeof(transaction));
	fp=fopen(argv[2],"r");
	if(fp==NULL)printf("Invalid file input");
	int i=0;
	while(getline(&line,&size,fp)!=-1)
	{
		pch = strtok(line," ");
		count=0;
		while (pch != NULL)
		{
		  if(count==0){count++;}
		  else if(count==1){curr[i].type=atoi(pch);count++;}
		  else if(count==2){curr[i].amount=atof(pch);count++;}
		  else if(count==3){curr[i].acc1=atoi(pch);count++;}
		  else curr[i].acc2=atoi(pch);
		  //curr[i].isdone=0;
		  pch = strtok (NULL, " ");
		}
		i++;
	}
	//printf("%d----",a);
	for(int k=0;k<=10001;k++)pthread_mutex_init(&lock[k], NULL);
	
	gettimeofday(&start, NULL);
	for(int j=0;j<num_threads;j++)
	{
		if(pthread_create(&threads[j], NULL,acc_update,NULL) != 0){
              		perror("pthread_create");
        	        exit(-1);}
        }
	for(int j=0;j<num_threads;j++)
	{
		pthread_join(threads[j], NULL);
        }
	gettimeofday(&end, NULL);	
	
	//printf("Time taken = %ld microsecs\n", TDIFF(start, end));
	for(int j=1;j<=10000;j++)printf("%d %.2f\n",j+1000,ar[j]);
	//printf("%d",gl);
	printf("%lf",curr[MAXVAL-1].amount);
	free(curr);
	free(threads);
	//free(ar);
}


