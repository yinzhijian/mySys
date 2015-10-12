#include <unistd.h>
#include <stdio.h>
int main(){
pid_t fpid;
int count=0;
fpid = fork();
if(fpid <0)
	printf("error in fork!");
else if(fpid ==0){
	printf("i am the child process,id is %d\n",getpid());
	count++;
	pause();
	char * const argv[] = {"ls","-l","/",0};
	char * const envp[] = {0,0};
	execve("/bin/ls",argv,envp);
}
else{
	waitpid(fpid);
	printf("i am the parent process,id is %d\n",getpid());
	count++;
}
printf("count is %d\n",count);
return 0;
}
