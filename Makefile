#########################################
CPU_ARCHITECTURE = 32
#needed when building as extension module:
#PYINC = C:\Python27\include
#PYLIB = C:\Python27\libs
#########################################

ifeq ($(CPU_ARCHITECTURE), 64)
	CC = C:\mingw64\bin\gcc
else
	CC = C:\MinGW\bin\gcc
endif

ifdef AMDAPPSDKROOT
	CLINC = $(AMDAPPSDKROOT)/include
	ifeq ($(CPU_ARCHITECTURE), 64)
		CLLIB = $(AMDAPPSDKROOT)/lib/x86_64
	else
		CLLIB = $(AMDAPPSDKROOT)/lib/x86
	endif
endif

.PHONY: all, clean

#all: test.exe host.dll
all: host.dll

test.exe: test.o opencl.o cl_error.o
	@echo making test.exe ...
	@$(CC) test.o opencl.o cl_error.o -o test.exe -L"$(CLLIB)" -lOpenCL

test.o: test.c opencl.h Makefile
	@echo making test.o ...
	@$(CC) -Wall -c -I"$(CLINC)" test.c -o test.o

host.dll: host.o opencl.o cl_error.o
	@echo making host.dll ...
#	$(CC) -shared host.o opencl.o cl_error.o -o host.dll -L"$(CLLIB)" -lOpenCL -L"$(PYLIB)" -lpython27
	@$(CC) -shared host.o opencl.o cl_error.o -o host.dll -L"$(CLLIB)" -lOpenCL

host.o: host.c opencl.h Makefile
	@echo making host.o ...
#	$(CC) -Wall -c -I"$(CLINC)" -I"$(PYINC)" host.c -o host.o
	@$(CC) -Wall -c -I"$(CLINC)" host.c -o host.o

opencl.o: opencl.c opencl.h cl_error.h Makefile
	@echo making opencl.o ...
	@$(CC) -Wall -c -I"$(CLINC)" opencl.c -o opencl.o

cl_error.o: cl_error.c cl_error.h Makefile
	@echo making cl_error.o ...
	@$(CC) -Wall -c -I"$(CLINC)" cl_error.c -o cl_error.o

clean:
	@echo cleaning ...
	@del *.o
