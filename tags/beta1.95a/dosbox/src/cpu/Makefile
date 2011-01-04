GCC=g++
CFLAGS= -DHAVE_CONFIG_H -I. -I../..  -I../../include -I/usr/local/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE  -g -O2
SOURCES=callback.cpp\
	core_dyn_x86.cpp\
	core_dynrec.cpp\
	core_full.cpp\
	core_normal.cpp\
	core_prefetch.cpp\
	core_simple.cpp\
	cpu.cpp\
	flags.cpp\
	modrm.cpp\
	paging.cpp

OBJECTS=$(SOURCES:%.cpp=%.o)

all: $(OBJECTS)

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@
