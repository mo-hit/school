#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <mqueue.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <signal.h>
//values to hold times
double t_a,t_b,t_c;

int N,B,p,c; //holding the N and B values

int d, status; //message payload
mqd_t qdes;	


int main( int argc, char *argv[]) 
{
	N =atoi(argv[1]);
	B =atoi(argv[2]);
	p = atoi(argv[3]);
	c = atoi(argv[4]);

	pid_t id_array[p+c];
	pid_t child_pid;
	
	struct timeval cur_time;

	gettimeofday(&cur_time,NULL);

	//Measure time A
	t_a=cur_time.tv_sec+(cur_time.tv_usec/1000000.0);

	// //fork the process
	// child_pid = fork();
	// if (child_pid != 0) {
	// 	producer(); //parent
	// 	return child_pid;
	// } else {
	// 	consumer(); //child
	// }
	char qname[] = "/mohit1";	//queue name must start with '/'. man mq_overview
	mode_t mode = S_IRUSR | S_IWUSR;
	struct  mq_attr attr;


	attr.mq_maxmsg  = B;
	attr.mq_msgsize = sizeof(int); //message size => integers
	attr.mq_flags   = 0;		// blocking queue 

	struct timeval t;
	//open the queue

	qdes  = mq_open(qname, O_RDWR | O_CREAT, mode, &attr);

	if (qdes == -1 ) {
		perror("mq_open() failed");
		exit(1);
	}

	int i,j;

	// for (i=0;i<c; i++ ) {
	// 	for (j=1; j<p; j++) {
	// 		child_pid = fork();
	// 		//fork process p times for the producers 
	// 		if (child_pid != 0) {
	// 			producer(j); //producer is spawned
	// 			return child_pid;
	// 		} else {
	// 			//child immediately ends
	// 		}
			
	// 	}
	// 	//fork the process c more times for the consumers
	// 	child_pid = fork();
	// 	if (child_pid !=0 ) {	
	// 		producer(0);
	// 		return child_pid;
	// 	} else {
	// 		consumer(i); //consumer is spawned
	// 	}
	// }
	for (i=0;i<p+c;i++) {
		child_pid = fork();
		if(child_pid != 0) {
	  	 	id_array[i] = child_pid;
			continue;
		} else {
			if (i<p) {
				producer(i);
			} else {
				consumer(i-p);
			}
			break;
		}
	}

	if(child_pid != 0) {
		for (i=0; i<p+c; i++) {
			waitpid(id_array[i], &status, 0);
		}
		if (mq_close(qdes) == -1) {
			perror("mq_close() failed");
			exit(2);
		}

		if (mq_unlink(qname) != 0) {
			perror("mq_unlink() failed");
			exit(3);
		}

		gettimeofday(&cur_time,NULL);
		//Measure time B
		t_b=cur_time.tv_sec+(cur_time.tv_usec/1000000.0);

		printf("Total Execution Time: %.61f\n", t_b-t_a);
	}
}
	// }

int producer (int id) {
	//printf("I am producer %d\n", id);
	d = id;		
	//send N integers
	while ( d<N ) {
		//message send
		if (mq_send(qdes, (char *)&d, sizeof(int), 0) == -1) {
			perror("mq_send() failed");
		}
		//printf("%d is produced by producer %d\n",d,id);
       	d = d + p;
	}

 
	// int status = 0;
	// wait(&status); //wait until consumer has completed



	// printf("\ntime to initialize system: %f\n",t_b-t_a);



	//printf("done producer %d\n",id);
	return 0;
}

int consumer(int id) 
{
	//printf("I am consumer %d\n",id);

	int i = id;
	double root =0;
	int num;
	//recieve N messages


	//calculate the total number of integers that need to be recieved by consumer 
	if((id-p) != (c-1)){
		num = N/c;
	} else{
		num = (N - (int)((N/c)*(c-1))); 
	}	

	while ( i<num ) {

		// only block for a limited time if queue is empty
		if (mq_receive(qdes, (char *) &d, \
		    sizeof(int), 0) == -1) {
					
			perror("mq_receive() failed");
			printf("Type Ctrl-C and wait for 5 seconds to terminate.\n");
		} else {
			root = sqrt(d);
			if (root == (int) root) {
				printf("c%d %d %d\n", id, d, (int)root);
			}
			
		     
		}
		i = i+c;

	}


		//printf("done consumer %d\n",id);

	return 0;
}
