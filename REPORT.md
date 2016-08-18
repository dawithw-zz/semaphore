#PROGRAM DOCUMENTATION

**Implementation strategy**

There are several parts that were taken into account when implementing the semaphore system calls. The most important question is how do we store semaphores, and where? Semaphores are specific to a process hierarchy, i.e. a semaphore created by a process A can not be accessed by any other process, unless this process is an nth child of process A (0 <= n). Furthermore, we needed to take into account that any child could override an inherited semaphore with one it creates, and be able to get back to the inherited semaphore if the child was to remove the semaphore it created. At the core of the idea is that semaphores are intimately associated with a process and it’s family. Therefore, it was logical for a process “object” to have a list of semaphores as part of it’s identity.

A process is simply a struct in OpenBSD. Therefore, to add semaphores to the process was as simple (in concept) as adding a data structure in the process structure. The choice of data structure to keep these semaphores was a linked list, implemented in OpenBSD as LIST. A process was to only keep track of semaphores that it created, and nothing else. Then how do we find what a process has inherited? In addition to the list of semaphores, we will need a flag that is set every time a process fork()s. Say a “root” user process (the first process) is forked from a system process. Since it’s unlikely that a system process is using our semaphore, this “root” process will not inherit any semaphores. Therefore, we set the inherited flag to FALSE. If this process was to create a semaphore and fork(), then the child will have its inherited flag set to TRUE. We determine what to set the flag by simply checking if the list of semaphores the process we fork()ed from is empty. If the list is empty, the parent has no semaphores to pass down to it’s child, so the child inherits nothing. If the parent has created semaphores, it’s list will not be empty, and the child would then set its flag to TRUE, indicating that the parent process has some semaphores that it might want to access later.

But keep track of all this flag and conditions? Why not just copy over the semaphores into the child? One reason is, if there is a tall tree of process hierarchies, and if each child down that process tree creates its own semaphore that has the same name as the parent, by the time we get to the 5th generation children we’ll have 5 different semaphores with the same name. This makes it challenging to figure out which semaphore takes precedence over the others when doing the system calls. If the current process has created a semaphore, we can simply check if it owns it, and we have a match. But, if the current process doesn’t own the semaphore, then we’d have to find the owner of each semaphore and traverse the process tree upwards to check which process comes first (I’ll shortly describe what a semaphore object entails, bot for now let’s just assume that we can figure out who owns a semaphore as long as we have access to the semaphore). If we are going to traverse the tree, it would be computationally less demanding if we were to go up the tree in order (this way we know where a process is in the tree), rather than jumping around to figure out where a process lies in the tree. So, whenever a process inherits a semaphore, it sets its inherited flag and searching for a semaphore becomes trivial. We search the process’s list, and if semaphore is not in there, we get the process’s parent and search its list, and so on until we either get the semaphore or we reach a process with an inherited flag not set (FALSE). Note that a process structure keeps pointers to its parent and its children, so accessing them is just a matter of grabbing that pointer.

What happens when a process is terminated?
When a process is dying, we’ll want to free up all the semaphores it created. Note that if a process has a semaphore, on which other processes are sleeping, and if this process exits before they wake up, it is an error. It is up to the programmer to ensure that a process does not exit while it’s semaphore is being used, or else there might be a deadlock. But, when everything is fine and normal, and no one wants a process or its semaphores, then the exit function (the function responsible for freeing up all memory space a process has occupied) will go though the list of semaphores and delete them one by one. Normally, in OpenBSD, when a process exits before the child is terminated, the orphaned child(ren) are now adopted by the init process. This will make them lose all their inherited semaphores, as they now have no family. Logically, it is unclear whether these children should still be able to access their inheritance even after orphaned, but it’s a matter of how we want to implement access policy. This implementation tracks and maintains inheritance based on the
process family one is located in, rather than using semantics to determine what is “fair” to a process.

So what is this semaphore and of what is it made?
OpenBSD is mostly written in C, and ‘objects’ in C are simply made of structs. A semaphore is a structure that has a name, a count that keeps track of access, a lock to supply mutual exclusion and a list that keeps track of all processes that are waiting on the semaphore. Since we’re keeping track of semaphores in a process as linked lists (LIST), a semaphore is also a “node” in this linked list. Therefore it has a pointer to the next semaphore in that list, although this could be NULL if the semaphore is a loner. A semaphore also has a pointer to the owner process. Whenever a process creates a semaphore, this pointer is set to the process structure, giving as direct access to the owner through the semaphore.

Now that the definitions and policies are out the way, let’s see how operations on semaphores work. There are four system calls that could be performed on a semaphore: allocate_semaphore(), down_semaphore(), up_semaphore(), and free_semaphore().

The allocate_semaphore()function, as it’s name implies is responsible for creating, instantiating and attaching a semaphore to a process. OpenBSD system calls proved the calling process as one of the arguments, so we already know with which process to attach the semaphore. This function takes in the semaphore name and initial count as arguments, and instantiates the semaphore with those user supplied values. Naturally, we can’t trust the user with providing the correct argument format, so we check to make sure that the name and count meet the necessary conditions. We would also make sure that the calling process does not already own a semaphore with that name, otherwise we return an error to the user.  After checking all criteria are met, commit to creating the semaphore and allocate memory space for it. If there is memory available, we create the semaphore and append the calling process to the semaphore. We also add the semaphore to the calling process’s semaphore list, after instantiating and setting all its variables.

The free_semaphore() function removes a specified semaphore and releases memory the semaphore occupied. A process will only be able to successfully perform this operation on an existing semaphore that the process can access (inherited or owned sempahores – uses the find function that I describe shortly). If the process can not find such semaphore, nothing is done and an error is returned to the user. If such semaphore is found, the semaphore is removed from the owner’s semaphore list. Note that since the children of a process do not actually get copies of the semaphores they inherit, removing the semaphore form the owner process is enough. If the children were to have copies of the inherited semaphore, we’d have to traverse all the children and delete all instances/pointers to this semaphore to ensure stability, which is computationally expensive. Hence, another reason why this implementation method is used.

Before discussing the remaining system calls, let’s take a look at the helper find() function that the system calls use to get the semaphore of choice.

The find function is a recursive function that traverses the list of semaphores a process owns, and checks if a semaphore of specified name exists in that list. If the semaphore is not present, then the find function traverses the process’s parent’s list. If not found, it keeps on going up the process tree until one of two things happen: it finds the semaphore it was looking for, or it finds a process that has neither inherited semaphores nor owns semaphores – the “root” process. This traversal guarantees that the first semaphore we encounter will be the semaphore that is created by the most recently created process in the list. Note that this traversal is strictly going up the tree, and doesn’t check the branches (sibling processes), nor does it go down into the children processes.
The remaining two system calls are the up_semaphore() and the down_semaphore() functions. They both take in the name of a semaphore as the argument. They both use the find function to determine if such semaphore exists, before starting their section. Both functions use the lock on their mutex before going into their critical section, and unlock the mutex on exit. Furthermore, the down_semaphore() operation releases the mutex lock right before going to sleep, and requires the lock upon waking up.

The down_semaphore() function will decrement the count of the semaphore, indicating that a process is requesting access. If the count is less than 0, then its an indicator that resources are not available, hence the process goes to sleep. Whenever a process sleeps, it does so on a condition. This condition could be an arbitrary object, and the process is awakened when a wakeup signal is sent on the “condition” it went to sleep. Since we want to ensure the semaphore is fair, whenever a process sleeps, it is put on a wait queue and the process that is first in the list (longest waiting) is to be woken up first. But, if we were to make all processes sleep on the same “condition”, then a wakeup signal might cause unwanted processes to wakeup our of order. To overcome this, we make a process sleep on itself. Therefore, when we call wakeup on the process address, the process itself is woken up. This is an easy way of ensuring that we’re waking up the process we intend to wakeup, and no other process. Once a process has gone to sleep, it waits until another process calls up_semaphore on the semaphore it slept.

The up_semaphore function is conceptually simple. After doing basic check and acquiring the lock, it increments the semaphore count. If the count was below zero, that means a process is waiting on the semaphore, so a wakeup is issued. To ensure that the wakeup is done on the longest waiting semaphore, we simply check to see which process is first in the wait queue of the semaphore. Once we figure that out, we just issue a wakeup on that process to wake it up (remember: a process sleeps on itself, so it should be woken up by issuing a wakeup on itself).

After a process is woken up, we free up the memory that it was occupying as a “node” in the wait queue. We then release the mutex lock we originally acquired and exit.


**Testing Strategy**

*Note 1: SUCCEED means operation shold complete without errors, and FAIL means operation should encounter and error. When FAIL, the type of error is printed to the console.*

*Note 2: We want some of these calls to result FAIL. The reason is because we want to ensure error handling is done properly. If a call that is supposed to FAIL ended up SUCCEED, that would indicate an actual failure.*

Part 1: Testing basic call functionality

1. Create semaphore with the following arguments: (Status)
  - Regular name, regular count: SUCCEED
  - Duplicate name, regular count: FAIL
  - Long name (36 chars), regular count: FAIL 
  - Regular name, negative count: FAIL
2. Call up on the following semaphores 
  - Existing semaphore: SUCCEED
  - Non-existing semaphore: FAIL
3. Free the following semaphores
  - Existing semaphore: SUCCEED 
  - Non-existing semaphore: FAIL 
  - Deleted semaphore: FAIL
4. Call up on the following
  - Deleted semaphore: FAIL
  - Illegal name (36 chars): FAIL

Part 2: Testing Inheritance

- Parent creates SEM_P
- Parent forks into two children: CHILD 1, CHILD 2 
- Parent wait for children to die
- CHILD 1:
  - create SEM_P (should have priority over inherited)
  - create SEM_C1 (unique to CHILD 1) 
- CHILD 2:
  - create SEM_C2 (unique to CHILD 2)

- Child 1: try down() on Child 2’s semaphore (SEM_C2) : FAIL
- Child 2: go down() on inherited SEM_A : SUCCEED
- Child 1: try up() on SEM_A: NOTHING as doing up on SEM_A it created
- Child 1: remove SEM_A: Inherited SEM_A now in scope
- Child 1: up() on SEM_A: SUCCEED (wakeup Child 2)
- Child 1: call series of up() on SEM_A to make count > 0
- Child 2: return from down() (after wake up form Child 1)
- Child 2: call a series of down() to ensure it won’t block. Number of down() <= Number of up() called by Child 1
- Child 1:Free semaphores and die
    - SEM_P: SUCCEED (FAIL if Child 2 freed first)
    - SEM_C1: SUCCEED
    - SEM_C2: FAIL
- Child 2: Free semaphores and die
    - SEM_P: SUCCEED (FAIL if Child 1 freed first) SEM_C1: FAIL
    - SEM_C2: SUCCEED

Part3: Testing Fainess

- Parent creates semaphore FAIR
- Parent forks 4 children
- Parent waits for children to die
- Child 1–3 call down() on FAIR
- Child 4 call up() on FAIR 3 times
  - WAKEUP order should be: Child 1,Child 2,Child 3
- Children die

Part 4: Testing free resources on exit

  - Parent create SEM A and SEM B
  - Parent fork a child
  - Parent sleep for 2 seconds so Child can execulte some commands, then die
  - Child: Call up on SEM A and SEM B: SUCCESS
  - Child sleep for 3 seconds - Parent should die by now
  - Child: Call up on SEM A and SEM B: FAIL
  - Child dies
