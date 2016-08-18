#include <sys/syscall.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define NOERR 0

void status()
{
	switch(errno) 
	{
		case NOERR:
			printf("SUCCESS\n");
			break;
		case EFAULT:
			printf("ERROR: EFAULT\n");
			break;
		case ENOMEM:
			printf("ERROR: ENOMEM\n");
			break;
		case ENAMETOOLONG:
			printf("ERROR: ENAMETOOLONG\n");
			break;
		case EEXIST:
			printf("ERROR: EEXIST\n");
			break;
		case EDOM:
			printf("ERROR: EDOM\n");
			break;
		case ENOENT:
			printf("ERROR: ENOENT\n");
			break;
		default:
			printf("ERROR: UNKNOWN\n");
			break;
	}
}

void createSemaphore(char *name, int init_val)
{
	int pid;
	errno = 0;
	printf("creating semaphore (%s, %d) .... ", name, init_val);
	pid = syscall(SYS_allocate_semaphore, name, init_val);
	status();
}


void removeSemaphore(char *name)
{
	int pid;
	errno = 0;
	printf("removing semaphore (%s) .... ", name);
	pid = syscall(SYS_free_semaphore, name);
	status();
}

void down(char *name)
{
	int pid;
	errno = 0;
	printf("down on semaphore (%s) .... ", name);
	pid = syscall(SYS_down_semaphore, name);
	status();
}

void up(char *name)
{
	int pid;
	errno = 0;
	printf("up on semaphore (%s) .... ", name);
	pid = syscall(SYS_up_semaphore, name);
	status();
}

int main()
{
	int pid1, pid2, pid3, pid4, pid5;

	pid1 = -1;
	pid2 = -1;
	pid3 = -1;
	pid4 = -1;
	pid5 = -1;

	printf("\n=============== START SEMAPHORE TEST ===============\n");
	printf("\n|-------=----------------------------|\n");
	printf("| KEYS:                              |\n");
	printf("| > creating semaphore (name, count) |\n");
	printf("| > removing semaphore (name)        |\n");   
	printf("| > up on semaphore (name)           |\n");      
	printf("| > down on semaphore (name)         |\n");
	printf("|--------=---------------------------|\n");

	printf("\n_________________ PART 1: BASIC CALLS _________________\n");

	printf("CREATE SEMAPHORE:\n");
	createSemaphore("Sem1", 0);
	createSemaphore("Sem1", 0);
	createSemaphore("abcdefghijklmnopqrstuvwxyz01234567890", 0);
	createSemaphore("Sem_negative", -1);

	printf("UP SEMAPHORE:\n");
	up("Sem1");
	up("Sem_noexist");

	printf("DELETE:\n");
	removeSemaphore("Sem1");
	removeSemaphore("Sem_noexist");
	removeSemaphore("Sem1");

	printf("UP SEMAPHORE:\n");
	up("Sem1");
	up("abcdefghijklmnopqrstuvwxyz01234567890");

	printf("_________________ END PART 1 ___________________________\n");

	printf("\n_________________ PART 2: INHERITANCE __________________\n");

	createSemaphore("Sem_P", 0);
	
	printf("Parent about to fork .... (1)\n");
	pid1 = fork();

	if (pid1 < 0)
	{
		fprintf(stderr, "Fork failed! Skipping ....\n");
	}
	else if (pid1 == 0)
	{
		printf("Child 1: START\n");

		createSemaphore("Sem_C1", 0);
		createSemaphore("Sem_P", 0);

		printf("DOWN SEMAPHORE (Child 1):\n");
		down("Sem_random");
		printf("Child 1: sleep for a seconds\n");
		usleep(1000000);
		printf("Child 1: wakeup\n");
		down("Sem_C2");

		printf("Child 1: sleep for 2 seconds\n");
		usleep(2000000);
		printf("Child 1: wakeup\n");

		printf("Child 1 (NOTE): At this point Child 2 went down() on inherited Sem_P. Child 1 has created it's own Sem_P\n");

		printf("UP SEMAPHORE (Child 1):\n");
		up("Sem_P");
		printf("Let's see if Child 2 wakes up...\nChild 1:  sleep for 5 seconds\n");
		usleep(5000000);
		printf("Child 1: wakeup\n");

		printf("REMOVE SEMAPHORE (Child 1):\n");
		removeSemaphore("Sem_P");

		printf("Let's try waking up Child 2 one more time by calling up() on Sem_P\n");
		printf("UP SEMAPHORE (Child 1):\n");
		up("Sem_P");
		up("Sem_P");
		up("Sem_P");
		up("Sem_P");
		up("Sem_P");

		printf("Child 1: sleep for 5 second\n");
		usleep(5000000);
		printf("Child 1: wakeup\n");

		printf("FREE SEMAPHORE (Child 1):\n");
		removeSemaphore("Sem_P");
		removeSemaphore("Sem_C1");
		removeSemaphore("Sem_C2");

		printf("Child 1: END\n");
		return 0;
	}
	else
	{
		printf("Parent about to fork .... (2)\n");
		pid2 = fork();

		if(pid2 < 0)
		{
			fprintf(stderr, "Fork failed! Skipping ....\n");
		}
		else if (pid2 == 0)
		{
			printf("Child 2: START\n");
			createSemaphore("Sem_C2", 0);

			printf("DOWN SEMAPHORE (Child 2):\n");
			down("Sem_P");
			printf("Child 2: completed down\n");

			printf("Child 2: sleep for 2 second\n");
			usleep(2000000);
			printf("Child 2: wakeup\n");

			printf("DOWN SEMAPHORE (Child 2):\n");
			down("Sem_P");
			down("Sem_P");
			down("Sem_P");
			down("Sem_P");

			printf("FREE SEMAPHORE (Child 2):\n");
			removeSemaphore("Sem_P");
			removeSemaphore("Sem_C1");
			removeSemaphore("Sem_C2");

			printf("Child 2: END\n");
			return 0;
		}
		else
		{
			wait(NULL);	/* let Child 2 finish */
		}
		wait(NULL);	/* let Child 1 finish */
	}

	printf("__________________ END PART 2 ___________________________\n");

	printf("\n__________________ PART 3: FAIRNESS _____________________\n");

	createSemaphore("Fair", 0);

	printf("Parent about to fork .... (1)\n");
	pid1 = fork();

	if (pid1 < 0)
	{
		fprintf(stderr, "Fork failed! Skipping ....\n");
	}
	else if (pid1 == 0)
	{
		printf("Child 1: DOWN SEMAPHORE\n");
		down("Fair");
		printf("Child 1: completed down .... exiting\n");
		return 0;
	}
	else
	{
		printf("Parent about to fork .... (2)\n");
		pid2 = fork();

		if (pid2 < 0)
		{
			fprintf(stderr, "Fork failed! Skipping ....\n");
		}
		else if (pid2 == 0)
		{
			printf("Child 2: DOWN SEMAPHORE\n");
			down("Fair");
			printf("Child 2: completed down .... exiting\n");
			return 0;
		}
		else
		{
			printf("Parent about to fork .... (3)\n");
			pid3 = fork();

			if (pid3 < 0)
			{
				fprintf(stderr, "Fork failed! Skipping ....\n");
			}
			else if (pid3 == 0)
			{
				printf("Child 3: DOWN SEMAPHORE\n");
				down("Fair");
				printf("Child 3: completed down .... exiting\n");
				return 0;
			}
			else
			{
				printf("Parent about to fork .... (4)\n");
				pid4 = fork();

				if (pid4 < 0)
				{
					fprintf(stderr, "Fork failed! Skipping .... (DEADLOCK)\n");
				}
				else if (pid4 == 0)
				{
					printf("Child 4: up semaphore, then sleep for a second\n");
					up("Fair");
					usleep(1000000);
					printf("Child 4: wakeup\n");
					printf("Child 4: up semaphore, then sleep for a second\n");
					up("Fair");
					usleep(1000000);
					printf("Child 4: wakeup\n");
					printf("Child 4: up semaphore, then sleep for a second\n");
					up("Fair");
					usleep(1000000);
					printf("Child 4: wakeup .... exiting\n");
					return 0;
				}
				else
				{
					wait(NULL);	/* Let child 4 finish */
				}
				wait(NULL);	/* Let child 3 finish */
			}
			wait(NULL); /* Let child 2 finish */
		}
		wait(NULL); /* Let child 1 finish */
	}

	printf("__________________ END PART 3 ____________________________\n");

	printf("\n__________________ PART 4: FREE ON EXIT __________________\n");

	createSemaphore("Sem A", 0);
	createSemaphore("Sem B", 0);

	printf("Parent about to fork .... (1)\n");
	pid1 = fork();

	if (pid1 < 0)
	{
		fprintf(stderr, "Fork failed! Skipping ....\n");
	}
	else if (pid1 == 0)
	{
		printf("Child: START\n");

		up("Sem A");
		up("Sem B");
		up("Sem Control");

		printf("Child: sleep for 3 seconds\n");
		usleep(3000000);
		printf("Child: wakeup\n");
		
		up("Sem A");
		up("Sem B");
		up("Sem Control");

		printf("Child: END\n");

		printf("__________________ END PART 4 ____________________________\n");
		printf("\n=============== END SEMAPHORE TEST ======================\n");
		return 0;
	}
	else
	{
		printf("Parent: sleep for 2 seconds\n");
		usleep(300000);
		printf("Parent: END\n");
	}
	/* Parent finishes before grandchild */
	return 0;
}