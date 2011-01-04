GCC=g++
CFLAGS= -DHAVE_CONFIG_H -I. -I../..  -I../../include -I/usr/local/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE  -g -O2
SOURCES=fpu.cpp

OBJECTS=$(SOURCES:%.cpp=%.o)

all: $(OBJECTS)

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@
