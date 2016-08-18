/*      $OpenBSD: cop4600.c,v 1.00 2003/07/12 01:33:27 dts Exp $        */

#include <sys/param.h>
#include <sys/acct.h>
#include <sys/systm.h>
#include <sys/ucred.h>
#include <sys/proc.h>
#include <sys/timeb.h>
#include <sys/times.h>
#include <sys/types.h>
#include <sys/malloc.h>
#include <sys/filedesc.h>
#include <sys/pool.h>
#include <sys/queue.h>
#include <sys/mount.h>
#include <sys/syscallargs.h>

/*========================================================================**
**  Dave's example system calls                                           **
**========================================================================*/

/*
** hello() prints to the tty a hello message and returns the process id
*/

int
sys_hello( struct proc *p, void *v, register_t *retval )
{
  uprintf( "\nHello, process %d!\n", p->p_pid );
  *retval = p->p_pid;

  return (0);
}

/*
** showargs() demonstrates passing arguments to the kernel
*/

#define MAX_STR_LENGTH  1024

int
sys_showargs( struct proc *p, void *v, register_t *retval )
{
  /* The arguments are passed in a structure defined as:
  **
  **  struct sys_showargs_args
  **  {
  **      syscallarg(char *) str;
  **      syscallarg(int)    val;
  **  }
  */

  struct sys_showargs_args *uap = v;

  char kstr[MAX_STR_LENGTH+1]; /* will hold kernal-space copy of uap->str */
  int err = 0;
  int size = 0;

  /* copy the user-space arg string to kernal-space */

  err = copyinstr( SCARG(uap, str), &kstr, MAX_STR_LENGTH, &size );
  if (err == EFAULT)
    return( err );

  uprintf( "The argument string is \"%s\"\n", kstr );
  uprintf( "The argument integer is %d\n", SCARG(uap, val) );
  *retval = 0;

  return (0);
}

/*========================================================================**
**  Dawit's COP4600 2004C system calls                                    **
**========================================================================*/


/* --------- SYSTEM CALL --------- */

#define min(a,b) (((a) > (b)) ? (b) : (a))  // compute minimum value

void substitution (char *text, int textLength, int lkey, int nkey);
void transposition (char *text, int textLength, int lkey, int nkey);

/* 
** TigerCipher® : Protecting us against canine digital attack
** Note: text has to be mutable, and not a string literal assigned
** to char*
*/

int 
sys_cipher (struct proc *p, void *v, register_t *retval)
{
  int err = 0;
  size_t textSize;

  struct sys_cipher_args *args = v;
  
  char ktext[MAX_STR_LENGTH + 1];    /* kernel space copy of text */
  int klkey;                         /* kernel copy of lkey */
  int knkey;                         /* kernel copy of nkey */
  
  /* Copy text to kernel space */
  err = copyinstr( SCARG(args, text), &ktext, MAX_STR_LENGTH, &textSize);
  if(err == EFAULT)
    return (err);
  
  /* Copy values to kernel space */
  klkey = SCARG(args, lkey);
  knkey = SCARG(args, nkey);

  // Pass 1
  substitution(ktext, textSize, klkey, knkey);

  // Pass 2
  transposition(ktext, textSize, klkey, knkey);

  /* Copy text to user space */
  err = copyoutstr(&ktext, SCARG(args, text), MAX_STR_LENGTH+1 , &textSize);
  if(err == EFAULT)
    return(err);
  
  *retval = textSize;

  return (0);
}

/* --------- END SYSTEM CALL --------- */

/* --------- HELPER FUCNTION --------- */

/* Mutate characters by by shifting their ascii values */
void substitution (char *text, int textLength, int lkey, int nkey)
{
  /* These variables change every loop iteration */
  char c;                                         // temp char 
  int i;                                          // loop counter
  int x, offset;                                  // shift values
  int upperCaseShift, lowecaseShift, digitShift;  // precomputed shifts
  int primaryCondition, secondaryCondtion;        // conditions

  /* Precompute variables constant throughout loop iteration */
  upperCaseShift = ((lkey % 26) - 'A' + 26);  
  lowecaseShift = ((lkey % 26) - 'a' + 26); 
  digitShift = ((nkey % 10) - '0' + 10);
  primaryCondition = ((lkey < 0) && (lkey & 0x1));

  // for each character c in text, perform the appropriate computation
    for(i = 0; i < textLength; ++i)
    {
      c = text[i];
      // c is uppercase
      if(c >= 'A' && c <= 'Z')
      {
        x = (c + upperCaseShift) % 26;
        secondaryCondtion = ((x - 'A') & 0x1);

        /*  
        * conditional shortcut (??)
        *
        * The following double conditional statement:
        * ((a < 0) && (b & 0x1)) ?
        *     (c & 0x1) ? X : Y ) : 
        *   (c & 0x1) ? Y : X )
        *
        * can be converted to an equivalent biconditional statement of the form:
        * (((a < 0) && (b & 0x1)) IFF (c & 0x1))) ?
        *      X : Y
        * 
        *   Note: The conditionals in this form will always evaluate to 'true' = 1
        * and not some random non-zero integer, because (some_number & 0x1) always
        *   evaluates to either 0 or 1
        *
        *   Therefore, we can represent IFF as:
        * (EXPRESSION1 == EXPRESSION2) ? TRUE : FALSE
        */
        offset = ( (primaryCondition == secondaryCondtion) ? 'A' : 'a' );
        text[i] = x + offset;
      }
      // c is lowecase
      else if (c >= 'a' && c <= 'z')
      {
        x = (c + lowecaseShift) % 26;
        secondaryCondtion = ((x - 'a') & 0x1);
        offset = ( (primaryCondition == secondaryCondtion) ? 'a' : 'A' );

        text[i] = x + offset;
      }
      // c is digit
      else if (c >= '0' && c <= '9')
      {
        text[i] = ((c + digitShift) % 10) + '0';
      }
      // c is something else: text[i] = c
    }

}

/* Split text into quads and transpose elements */
void transposition (char *text, int textLength, int lkey, int nkey)
{
  // detemine extra chars at the end
  int i;                            // iterator
  char temp;                        // swap space
  int nonQuad = textLength % 4;     // quad length < 4
  
  // process each normal quad with length = 4
  for(i = 0; i < (textLength - nonQuad); i+=4)
  {
    // swap 1st and 3th chars
    temp = text[i];
    text[i] = text[i+2];
    text[i+2] = temp;
    
    // swap 2nd and 4th chars
    temp = text[i+1];
    text[i+1] = text[i+3];
    text[i+3] = temp;
  }
  
  /* 
   * This will only be evaluated when the last "quad" of the
   * string contains a quad of length 1 to 3
   */

  if(nonQuad)
  {
    /* i is now at the 1st index of this weird "quad" */
    if (nonQuad == 3)
    {
      // swap 1st and 3rd chars
      temp = text[i];
      text[i] = text[i+2];
      text[i+2] = temp;
    }
    else if (nonQuad == 2)
    {
      // swap 1st and 2nd chars
      temp = text[i];
      text[i] = text[i+1];
      text[i+1] = temp;
    }
      /* leave the lonely char alone */
  }
}

/* --------- END HELPER FUNCTION --------- */

/*========================================================================**
**  Part 5: Semahores                                                     **
**========================================================================*/

#define EQUAL 0                        /* for strcmp */
#define FALSE 0
#define TRUE 1
//#define MAX_SEM_COUNT 64               /* max allowed sempahores system wide */

//extern int sys_semaphores;             /* system wide semaphores */
//extern lock_data_t control;            /* lock for updating sys_semaphores */

#define COPYNAME(kname, uap, length) do { \
    if (copyinstr(SCARG(uap,name), &kname, MAX_NAME_LENGTH, &length) == EFAULT) \
    {return EFAULT;}  \
} while(0)

#define NAMECHECK(kname, length, err) do {  \
    if (length == MAX_NAME_LENGTH && kname[MAX_NAME_LENGTH-1] != '\0')  \
    {return err;} \
} while (0)


/* helper functions */
semaphore_t* find_semaphore(struct proc *p, char *kname);

/*
 * Create and initialize semaphore: 292
 */
int
sys_allocate_semaphore (struct proc *p, void *v, register_t *retval)
{
  struct sys_allocate_semaphore_args *uap = v;  
  semaphore_t *sem;                              
  char kname[MAX_NAME_LENGTH]; 
  int kcount;
  int length;

  length = 0;

  COPYNAME(kname, uap, length);  
  NAMECHECK(kname, length, ENAMETOOLONG);
  LIST_FOREACH(sem, &(p->semaphores), s_next)
    if (strcmp(sem->name, kname) == EQUAL && sem->owner == p)
      return EEXIST;   /* process owns semaphore with that name */

  kcount = SCARG(uap, initial_count); 
  if (kcount < 0)
    return EDOM;            /* out of range */
  
  /* allocate memeory for semaphore right now */
  sem = (struct semaphore*) malloc(sizeof(struct semaphore), M_PROC, M_NOWAIT);
  if (sem == NULL)
    return ENOMEM;     /* not enough memeory */

  /* initialize semaphore */
  if (copystr(&kname, &sem->name, MAX_NAME_LENGTH, &length) == EFAULT)
  {     
    /* something bad happaned. abort*/                  
    free(sem, M_PROC);        
    return EFAULT;
  }
  sem->owner = p;
  sem->count = kcount;
  SIMPLEQ_INIT(&(sem->p_head));
  lockinit(&sem->mutex, p->p_priority,"semaphore: another process in critical section", 0, LK_CANRECURSE);
  LIST_INSERT_HEAD(&p->semaphores, sem, s_next);
  //++sys_semaphores;
  return(0);
}

/*
 * Semaphore down: 293
 */

int
sys_down_semaphore (struct proc *p, void *v, register_t *retval)
{
  struct sys_down_semaphore_args *uap = v;
  semaphore_t *sem;
  char kname[MAX_NAME_LENGTH]; 
  int length;
  int flag;
  struct p_node *np;

  length = 0;
  flag = 1;

  /* Get semaphore */
  COPYNAME(kname, uap, length);
  NAMECHECK(kname, length, ENOENT);  
  sem = find_semaphore(p, kname);
  if(sem == NULL)
    return ENOENT;

  lockmgr(&sem->mutex, LK_EXCLUSIVE, NULL, p);  /* Lock mutex */
  --sem->count;
  if(sem->count < 0)
  { 
    /* create and instantiate node of SIMPLEQ */
    np = (struct p_node*) malloc (sizeof(struct p_node), M_PROC, M_NOWAIT);
    if(np == NULL)
      return ENOMEM;
    np->p = p;
    /* 
     * Make a process sleep on itself. This way, we wont have to worry about
     * notifying other processes upon wakeup. Each process will sleep on a 
     * unique "object" i.e itself
     */
    SIMPLEQ_INSERT_TAIL(&sem->p_head, np, p_next);   /* add process to wait queue */
    lockmgr(&sem->mutex, LK_RELEASE, NULL, p);       /* release lock before sleeping */
    
    while (flag != 0)         /* break out of this loop only if wakeup() is called */
      flag = tsleep((void*) np->p, p->p_priority,"waiting on semaphore",0);
      
    lockmgr(&sem->mutex, LK_EXCLUSIVE, NULL, p);     /* lock mutex */
  }
  lockmgr(&sem->mutex, LK_RELEASE, NULL, p);      /* Unlock mutex */
  return(0);
}

/*
 * Semaphore up: 294
 */

int
sys_up_semaphore (struct proc *p, void *v, register_t *retval)
{
  struct sys_up_semaphore_args *uap = v;
  semaphore_t *sem;
  char kname[MAX_NAME_LENGTH]; 
  int length;
  struct p_node *np;

  length = 0;

  /* Get semaphore */
  COPYNAME(kname, uap, length);
  NAMECHECK(kname, length, ENOENT);

  sem = find_semaphore(p, kname);
  if(sem == NULL)
    return ENOENT;

  lockmgr(&sem->mutex, LK_EXCLUSIVE, NULL, p);  /* Lock mutex */
  ++sem->count;

  if(sem->count <= 0)
  {
    /* Signal first process in wait list */
    np = SIMPLEQ_FIRST(&sem->p_head);
    wakeup((void*) np->p);
    SIMPLEQ_REMOVE_HEAD(&sem->p_head, np, p_next);  /* delete node */
    free(np, M_PROC);                               /* free memory */
  }
  /* Unlock mutex */
  lockmgr(&sem->mutex, LK_RELEASE, NULL, p);
  return(0);
}

/*
 * Delete semaphore: 295
 */

int
sys_free_semaphore (struct proc *p, void *v, register_t *retval)
{
  
  struct sys_free_semaphore_args *uap = v;  
  semaphore_t *sem;                              
  char kname[MAX_NAME_LENGTH]; 
  int length;

  length = 0;

  /* if name is not in proper format, don't bother checking */
  COPYNAME(kname, uap, length);
  NAMECHECK(kname, length, ENOENT);

  sem = find_semaphore(p, kname);
  if(sem == NULL)
    return ENOENT;    /* process doesn't own such semaphore */

  LIST_REMOVE(sem, s_next);   /* Remove from system list*/
  /* Delete all internals */
  /* Do I need to empty the queue? WHEN? HOW?* --- SEE DAVE'S COMMENT ON HINTS?*/  
  lockmgr(&sem->mutex, LK_DRAIN, NULL, p);    /* drain lock */
  free(sem, M_PROC);                          /* Free memory */
  //--semaphore_count;
  return(0);
}


/* Get semaphore with presedence according to creation - traverse the process tree bottom-up */
semaphore_t* find_semaphore(struct proc *p, char *kname)
{
  semaphore_t *sem;
  struct proc *p_find;      /* Process to search through */
  int breakloop;            /* flag to exit */

  p_find = p;             /* Start with current process */
  sem = NULL;
  breakloop = FALSE;

  /* Go through all the semaphores I created */
  while((LIST_EMPTY(&p_find->semaphores) == FALSE || p_find->inherited == TRUE) && breakloop == FALSE)      
  {  
    /* Until I get to a process that neither has created semaphore or inherited them */
    LIST_FOREACH(sem, &p_find->semaphores, s_next)
    {
      /* Search through the process's semaphore list for such name */
      if(strcmp(sem->name, kname) == EQUAL && sem->owner == p_find)
      {
        breakloop = TRUE;
        break;    /* found semaphore */
      }
    }
    p_find = p_find->p_pptr;  /* repate process in parent */
  }
  /* If semaphore is null at this point, then no semaphore has been found for the process */
  return sem;
}



















