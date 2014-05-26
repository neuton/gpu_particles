MAKEINC = builddef.txt

include $(MAKEINC)

ERROR =
ifdef AMDAPPSDKROOT
	CLINC = $(AMDAPPSDKROOT)/include
	ifeq ($(CPU_ARCHITECTURE), 64)
		CLLIB = $(AMDAPPSDKROOT)/lib/x86_64
	else
		CLLIB = $(AMDAPPSDKROOT)/lib/x86
	endif
else
	ifdef OPENCL_INCLUDE_PATH
		CLINC = $(OPENCL_INCLUDE_PATH)
		ifdef OPENCL_LIB_PATH
			CLLIB = $(OPENCL_LIB_PATH)
		else
			ERROR = $(error AMDAPPSDKROOT not defined; please, define OPENCL_LIB_PATH)
		endif
	else
		ERROR = $(error AMDAPPSDKROOT not defined; please, define OPENCL_INCLUDE_PATH)
	endif
endif

ifeq ($(OPENMP), yes)
	FOPENMP = -fopenmp
else
	FOPENMP =
endif

CCFLAGS := $(CCFLAGS)
ifneq ($(OS), Windows_NT)
	CCFLAGS := $(CCFLAGS) -fPIC
	SHELL = /bin/sh
else
	SHELL = cmd
endif

.PHONY: all, clean

ifeq ($(BUILDTEST), yes)
all: $(TEST).exe $(LIB).dll
else
all: $(LIB).dll
endif
	@echo all done

$(LIB).dll: $(LIB).o opencl.o cl_error.o
	$(ERROR)
	@echo making $(LIB) ...
	@$(CC) -shared $(LIB).o opencl.o cl_error.o -o $(LIB).dll -L"$(CLLIB)" -lOpenCL $(FOPENMP)

$(LIB).o: $(LIB).c opencl.h Makefile $(MAKEINC)
	$(ERROR)
	@echo making $(LIB).o ...
	@$(CC) $(CCFLAGS) -c -I"$(CLINC)" $(LIB).c -o $(LIB).o $(FOPENMP)

opencl.o: opencl.c opencl.h cl_error.h Makefile $(MAKEINC)
	$(ERROR)
	@echo making opencl.o ...
	@$(CC) $(CCFLAGS) -c -I"$(CLINC)" opencl.c -o opencl.o

cl_error.o: cl_error.c cl_error.h Makefile $(MAKEINC)
	$(ERROR)
	@echo making cl_error.o ...
	@$(CC) $(CCFLAGS) -c -I"$(CLINC)" cl_error.c -o cl_error.o

$(TEST).exe: $(TEST).o opencl.o cl_error.o
	$(ERROR)
	@echo making $(TEST) ...
	@$(CC) $(TEST).o opencl.o cl_error.o -o $(TEST).exe -L"$(CLLIB)" -lOpenCL $(FOPENMP)

$(TEST).o: $(TEST).c $(LIB).c opencl.h Makefile $(MAKEINC)
	$(ERROR)
	@echo making $(TEST).o ...
	@$(CC) -Wall -O2 -c -I"$(CLINC)" $(TEST).c -o $(TEST).o $(FOPENMP)

clean:
	@echo cleaning ...
ifeq ($(OS), Windows_NT)
	@del *.o
else
	@rm -f *.o
endif
	@echo all cleaned
