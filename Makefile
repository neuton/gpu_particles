#########################################
CPU_ARCHITECTURE = 64
#needed when building as extension module:
#PYINC = C:\Python27\include
#PYLIB = C:\Python27\libs
#########################################

CC = gcc
#ifeq ($(CPU_ARCHITECTURE), 64)
#	CC = C:\mingw64\bin\gcc
#else
#	CC = C:\MinGW\bin\gcc
#endif

ifdef AMDAPPSDKROOT
	CLINC = $(AMDAPPSDKROOT)/include
	ifeq ($(CPU_ARCHITECTURE), 64)
		CLLIB = $(AMDAPPSDKROOT)/lib/x86_64
	else
		CLLIB = $(AMDAPPSDKROOT)/lib/x86
	endif
endif

TEST = test
LIB = host

.PHONY: all, clean

#all: $(TEST).exe $(LIB).dll
all: $(LIB).dll

$(TEST).exe: $(TEST).o opencl.o cl_error.o
	@echo making $(TEST) ...
	@$(CC) $(TEST).o opencl.o cl_error.o -o $(TEST).exe -L"$(CLLIB)" -lOpenCL

$(TEST).o: $(TEST).c opencl.h Makefile
	@echo making $(TEST).o ...
	@$(CC) -Wall -fPIC -c -I"$(CLINC)" $(TEST).c -o $(TEST).o

$(LIB).dll: $(LIB).o opencl.o cl_error.o
	@echo making $(LIB) ...
#	$(CC) -shared $(LIB).o opencl.o cl_error.o -o $(LIB).dll -L"$(CLLIB)" -lOpenCL -L"$(PYLIB)" -lpython27
	@$(CC) -shared $(LIB).o opencl.o cl_error.o -o $(LIB).dll -L"$(CLLIB)" -lOpenCL

$(LIB).o: $(LIB).c opencl.h Makefile
	@echo making $(LIB).o ...
#	$(CC) -Wall -fPIC -c -I"$(CLINC)" -I"$(PYINC)" $(LIB).c -o $(LIB).o
	@$(CC) -Wall -fPIC -c -I"$(CLINC)" $(LIB).c -o $(LIB).o

opencl.o: opencl.c opencl.h cl_error.h Makefile
	@echo making opencl.o ...
	@$(CC) -Wall -fPIC -c -I"$(CLINC)" opencl.c -o opencl.o

cl_error.o: cl_error.c cl_error.h Makefile
	@echo making cl_error.o ...
	@$(CC) -Wall -fPIC -c -I"$(CLINC)" cl_error.c -o cl_error.o

clean:
	@echo cleaning ...
ifeq ($(OS), Windows_NT)
	@del *.o
else
	@rm -f *.o
endif
