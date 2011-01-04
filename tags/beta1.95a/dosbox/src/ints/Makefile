GCC=g++
CFLAGS= -DHAVE_CONFIG_H -I. -I../..  -I../../include -I/usr/local/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE  -g -O2

SOURCES=	./bios.cpp \
	./bios_disk.cpp \
	./bios_keyboard.cpp \
	./ems.cpp \
	./int10.cpp \
	./int10_char.cpp \
	./int10_memory.cpp \
	./int10_misc.cpp \
	./int10_modes.cpp \
	./int10_pal.cpp \
	./int10_put_pixel.cpp \
	./int10_vesa.cpp \
	./int10_video_state.cpp \
	./int10_vptable.cpp \
	./mouse.cpp \
	./xms.cpp \


OBJECTS=$(SOURCES:%.cpp=%.o)

all: $(OBJECTS)

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@
