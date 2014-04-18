MAKEINC = builddef.txt

include $(MAKEINC)

ifdef AMDAPPSDKROOT
	ERROR =
	CLINC = $(AMDAPPSDKROOT)/include
	ifeq ($(CPU_ARCHITECTURE), 64)
		CLLIB = $(AMDAPPSDKROOT)/lib/x86_64
	else
		CLLIB = $(AMDAPPSDKROOT)/lib/x86
	endif
else
	ERROR = $(error AMDAPPSDKROOT not defined)
endif

ifeq ($(OSTYPE), linux-gnu)
	CCFLAGS = CCFLAGS -fPIC
endif

.PHONY: all, clean

ifeq ($(BUILDTEST), yes)
all: $(TEST).exe $(LIB).dll
else
all: $(LIB).dll
endif

$(LIB).dll: $(LIB).o opencl.o cl_error.o
	$(ERROR)
	@echo making $(LIB) ...
	@$(CC) -shared $(LIB).o opencl.o cl_error.o -o $(LIB).dll -L"$(CLLIB)" -lOpenCL

$(LIB).o: $(LIB).c opencl.h Makefile $(MAKEINC)
	$(ERROR)
	@echo making $(LIB).o ...
	@$(CC) $(CCFLAGS) -c -I"$(CLINC)" $(LIB).c -o $(LIB).o

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
	@$(CC) $(TEST).o opencl.o cl_error.o -o $(TEST).exe -L"$(CLLIB)" -lOpenCL

$(TEST).o: $(TEST).c opencl.h Makefile $(MAKEINC)
	$(ERROR)
	@echo making $(TEST).o ...
	@$(CC) -Wall -c -I"$(CLINC)" $(TEST).c -o $(TEST).o

clean:
	@echo cleaning ...
ifeq ($(OS), Windows_NT)
	@del *.o
else
	@rm -f *.o
endif
