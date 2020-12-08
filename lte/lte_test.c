#include     <stdio.h>     
#include     <stdlib.h>    
#include     <unistd.h>    
#include     <sys/types.h> 
#include     <sys/stat.h>  
#include     <fcntl.h>     
#include     <termios.h>   
#include     <errno.h>     

#include	<string.h>
#include 	<unistd.h>

#define FALSE 0
#define TRUE 1
/***@brief
*@param  fd
*@param  speed  
*@return  void*/

int speed_arr[] = { B115200, B38400, B19200, B9600, B4800, B2400, B1200, B300,
	    B115200, B38400, B19200, B9600, B4800, B2400, B1200, B300, };
int name_arr[] = {115200, 38400,  19200,  9600,  4800,  2400,  1200,  300,
	    115200, 38400,  19200,  9600, 4800, 2400, 1200,  300, };
void set_speed(int fd, int speed)
{
  int   i;
  int   status;
  struct termios   Opt;
  tcgetattr(fd, &Opt);
  for ( i= 0;  i < sizeof(speed_arr) / sizeof(int);  i++)
   {
   	if  (speed == name_arr[i])
   	{
   	    tcflush(fd, TCIOFLUSH);
    	cfsetispeed(&Opt, speed_arr[i]);
    	cfsetospeed(&Opt, speed_arr[i]);
    	status = tcsetattr(fd, TCSANOW, &Opt);
    	if  (status != 0)
            perror("tcsetattr fd1");
     	return;
     	}
   tcflush(fd,TCIOFLUSH);
   }
}

int set_Parity(int fd,int databits,int stopbits,int parity)
{
	struct termios options;
 if  ( tcgetattr( fd,&options)  !=  0)
  {
  	perror("SetupSerial 1");
  	return(FALSE);
  }
  options.c_cflag &= ~CSIZE;
  switch (databits)
  {
  	case 7:
  		options.c_cflag |= CS7;
  		break;
  	case 8:
		options.c_cflag |= CS8;
		break;
	default:
		fprintf(stderr,"Unsupported data size\n");
		return (FALSE);
	}
  switch (parity)
  	{
  	case 'n':
	case 'N':
		options.c_cflag &= ~PARENB;   /* Clear parity enable */
		options.c_iflag &= ~INPCK;     /* Enable parity checking */
		break;
	case 'o':
	case 'O':
		options.c_cflag |= (PARODD | PARENB);
		options.c_iflag |= INPCK;             /* Disnable parity checking */
		break;
	case 'e':
	case 'E':
		options.c_cflag |= PARENB;     /* Enable parity */
		options.c_cflag &= ~PARODD; 
		options.c_iflag |= INPCK;       /* Disnable parity checking */
		break;
	case 'S':
	case 's':  /*as no parity*/
		options.c_cflag &= ~PARENB;
		options.c_cflag &= ~CSTOPB;
		break;
	default:
		fprintf(stderr,"Unsupported parity\n");
		return (FALSE);
		}

  switch (stopbits)
  	{
  	case 1:
  		options.c_cflag &= ~CSTOPB;
		break;
	case 2:
		options.c_cflag |= CSTOPB;
		break;
	default:
		fprintf(stderr,"Unsupported stop bits\n");
		return (FALSE);
	}
  /* Set input parity option */
  if (parity != 'n')
  		options.c_iflag |= INPCK;
    options.c_cc[VTIME] = 150; // 15 seconds
    options.c_cc[VMIN] = 0;

  tcflush(fd,TCIFLUSH); /* Update the options and do it NOW */
  if (tcsetattr(fd,TCSANOW,&options) != 0)
  	{
  		perror("SetupSerial 3");
		return (FALSE);
	}
  return (TRUE);
 }
/**
*@breif 打开串口
*/
int OpenDev(char *Dev)
{
int	fd = open( Dev, O_RDWR | O_NONBLOCK);         //| O_NOCTTY | O_NDELAY
	if (-1 == fd)
		{
			perror("Can't Open Serial Port");
			return -1;
		}
	else
	return fd;

}
/**
*@breif 	main()
*/
int main(int argc, char **argv)
{
	int fd;
	int tag = 0;
	int nread;
	char buff[512];
	char *dev ="/dev/ttyAMA0";
	
	
	fd = OpenDev(dev);
	if (fd>0)
    set_speed(fd,115200);
	else
		{
		printf("Can't Open Serial Port!\n");
		exit(0);
		}
  if (set_Parity(fd,8,1,'N')== FALSE)
  {
    printf("Set Parity Error\n");
    exit(1);
  }
//  while(1)
  {
	memset(buff, 0, 512);
	strcat(buff, "ATI\r");
	nread = write(fd, buff, 4);
        usleep(1000*200);
        memset(buff, 0, 512);
	while((nread = read(fd,buff,2))>0)
	{
      		printf("%s",buff);
                memset(buff, 0, 512);
		tag = 1;
 	}
  }
    close(fd);
}
