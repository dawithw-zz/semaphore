# Semaphores in OpenBSD 3.5

**Overview** 

This is a project from Operating Systems class by Dave Small (2015). The idea is to modify the kernel of the OS to add semaphore support as a system call.


**Kernel Files (Modified)**

syscall.masters

- In __usr/src/sys/kern/__
  - kern_exit.c  
  - kern_fork.c
- In __usr/src/sys/sys/__
  -proc.h

> Note: The files above are from the kernel of the OpenBSD 3.5, with the modified code annotated by comments.

cop4600.c  (not part of the original kernel)


**Test File**

kerntest.c

**Bugs**

There are some known bugs in the program that were not documented
