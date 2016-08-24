# Semaphores in OpenBSD 3.5

**Overview** 

This is a project from my Operating Systems course. The idea is to modify the kernel and add semaphore support (as a system call).


**Kernel Files (Modified)**

- syscall.masters
- proc.h --- usr/src/sys/sys/
- kern_exit.c --- usr/src/sys/kern/
- kern_fork.c --- usr/src/sys/kern/

> Note: The files above are from the kernel of the OpenBSD 3.5. Modified code is annotated by comments.

cop4600.c  (not part of the original kernel)


**Test File**

kerntest.c

**Bugs**

There are some known bugs in the program that were not documented
