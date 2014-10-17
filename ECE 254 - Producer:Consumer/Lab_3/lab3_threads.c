#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <semaphore.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <signal.h>
#include <math.h>
#include <pthread.h>

int N,B,P,C, p_count, c_count;

pthread_t* pid;
pthread_t* cid;

sem_t data, lock, prod, con, access;

struct timeval tv;

double ta,tb;

typedef struct {
	int* buf;
	int pindex;
	int cindex;	
} boundedBuffer;

boundedBuffer buffer;

void init() {
	sem_init(&access,0,B);
	sem_init(&data, 0, 0);
	sem_init(&lock, 0, 1);
	sem_init(&prod, 0, 1);
	sem_init(&con, 0, 1);

	p_count = 0;
	c_count = 0;

	buffer.pindex = 0;
	buffer.cindex = 0;
}
void insert(int payload) {
	sem_wait(&access); //can a producer run?
	sem_wait(&lock); //lock queue

	buffer.buf[buffer.pindex] = payload; //store value in queue
	buffer.pindex = (buffer.pindex + 1) % B; //incrememnt producer index

	sem_post(&lock); //unlock queue
	sem_post(&data); //data is ready
}
int retrieve() {
	int payload;
	sem_wait(&data); //wait for data
	sem_wait(&lock); //lock queue
	payload = buffer.buf[buffer.cindex]; //get the payload
	buffer.cindex = (buffer.cindex + 1) % B; //increment consumer index

	sem_post(&lock); //unlock qeuue
	sem_post(&access); //consumed, now produce 
	return payload;
}

void* producer(int* arg){
	int id = (int) arg;
	int payload =id;

	while(1) {
		sem_wait(&prod);

		if(p_count > (N-1)) {
			sem_post(&prod);
			break;
		}
		p_count++;
		sem_post(&prod);
//		printf("Producer %d: %d\n",id, payload);
		insert(payload);

		payload +=P;
	}
}

void* consumer(int* arg) {
	int id = (int) arg;
	int payload;
	double root;

	while(1) {
		sem_wait(&con); 

		if (c_count > (N-1)) {
			sem_post(&con);
			break;
		}



		c_count++;
		sem_post(&con);
		payload = retrieve();

		root = sqrt(payload);
		if(root == (int)root) {
			printf("Consumer %d: %d %d \n",id,payload,(int)root);
		}
	}

	if (id == 0) {
		gettimeofday(&tv,NULL);
		tb = tv.tv_sec + tv.tv_usec/1000000.0;
		printf("Execution Time: %.61f\n", tb-ta);
	}

}
int main(int argc, char* argv[]) {
	if(argc < 4){
		printf("Usage: boundedBuffer <num_ops> <num_consumers> <num_producers>\n");
		return 0;
	}
	N =atoi(argv[1]);
	B =atoi(argv[2]);
	P = atoi(argv[3]);
	C = atoi(argv[4]);

	//printf("Parameters: N=%d\n B=%d\n P=%d\n C=%d\n",N,B,P,C);

	buffer.buf = (int*) malloc(B * sizeof(int));
	pid = (pthread_t*) malloc(P * sizeof(pthread_t));
	cid = (pthread_t*) malloc(C * sizeof(pthread_t));	


	int i;

	init();
	gettimeofday(&tv,NULL);
	ta = tv.tv_sec + tv.tv_usec/1000000.0;

	for (i=0; i<P; i++ )
	{
		pthread_create(&pid[i], NULL, producer, (void*)i);
	}

	for (i=0; i<C; i++ )
	{
		pthread_create(&cid[i], 0, consumer, (void*)i);
	}	

	for (i=0; i<P; i++ )
	{
		pthread_join(pid[i],NULL);
	}

	for (i=0; i<C; i++ )
	{
		pthread_join(cid[i], NULL);
	}


}



