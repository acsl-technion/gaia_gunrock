
#include <string>
#include <gunrock/fileMap.cuh>

template<class Value>
struct producer
{
	fileMapping<char>	map_addr;
	int msqid;
	key_t key = MSG_QUEUE_KEY;
	int ittr;

	long random_at_most(long max) {
	  unsigned long
	    // max <= RAND_MAX < ULONG_MAX, so this is okay.
	    num_bins = (unsigned long) max + 1,
	    num_rand = (unsigned long) RAND_MAX + 1,
	    bin_size = num_rand / num_bins,
	    defect   = num_rand % num_bins;

	  long x;
	  do {
	   x = get_random_number(RAND_MAX, get_random_seed());//random();
	  }
	  // This is carefully written not to overflow
	  while (num_rand - defect <= (unsigned long)x);

	  // Truncated division is intentional
	  return x/bin_size;
	}
	#define MSG_TYPE 0


	struct msgbuf_t
	{
		long    mtype;
		char    mtext[MAXSIZE];
	};

	int get_offset(int rand_max)
	{
		return (random_at_most(rand_max)/sizeof(Value))*sizeof(Value);
	}

	int run_test(void)
	{
		struct msgbuf_t sbuf;
		size_t buflen;
		/* Done preparing files */
		for (int i = 0; i < ittr; i++) {
			int offset = get_offset(map_addr.map_len) ;
			printf("PRODUCER: will update at offset = %d, addr=0x%llx \n",
					offset, (Value*)map_addr.get_addr() + offset);
			*(Value*)map_addr.get_addr() = random_at_most(map_addr.map_len);


			sleep(1);
		}

		printf("PRODUCER: Done\n");
		return;

		static int idx = 0;

		int msqid;
			key_t key = MSG_QUEUE_KEY;

		/* First update the file at random location */
		int offset = get_offset(rand_max) ;
	printf("PRODUCER: will update at offset = %d, addr=0x%llx page_idx=%d, GPU page idx = %d\n",
		offset, &input[offset], offset*8/4096, (offset*8/4096)/16);

		strncpy(&input[offset], &words[idx], MIN(MAXSIZE,8));

		/* Now send the msg */
		if (msqid  < 0) {   //Get the message queue ID for the given key
				perror("PRODUCER: msgget");
			return -1;
		}

		sbuf.mtype = 1;
		strncpy(sbuf.mtext, &words[idx], MIN(MAXSIZE,8));
		if (msgsnd(msqid, &sbuf, MIN(MAXSIZE,9), IPC_NOWAIT) < 0){
			perror("PRODUCER: msgsnd");
			return -1;
		}
			printf ("PRODUCER: msg sent = %s\n",sbuf.mtext );

	//if (msync(input,  fsize, MS_SYNC))
	//printf("error msync from producer\n");

		idx +=9;
		return offset;
	}
	
	producer(string file_name, int iterations)
	{
		fileMapping<char>	map_addr(file_name);
		UCM_DBG("enter. file = %s size = %d\n", file_name.c_str(), map_addr.map_len);

		//Flush the msg queue before startingthe test
		if ((msqid = msgget(key, IPC_CREAT | 0666 )) < 0) {   //Get the message queue ID for the given key
			perror("PRODUCER: msgget");
			return;
		}
		msgctl(msqid, IPC_RMID, NULL);
		ittr = iterations;
	}
}
