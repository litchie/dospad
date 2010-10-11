GCC=g++
CFLAGS= -DHAVE_CONFIG_H -I. -I../..  -I../../include -I/usr/local/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE  -g -O2

SOURCES=./adlib.cpp \
	./cmos.cpp \
	./dbopl.cpp \
	./disney.cpp \
	./dma.cpp \
	./gameblaster.cpp \
	./gus.cpp \
	./hardware.cpp \
	./iohandler.cpp \
	./ipx.cpp \
	./ipxserver.cpp \
	./joystick.cpp \
	./keyboard.cpp \
	./memory.cpp \
	./mixer.cpp \
	./mpu401.cpp \
	./opl.cpp \
	./pcspeaker.cpp \
	./pic.cpp \
	./sblaster.cpp \
	./serialport/directserial.cpp \
	./serialport/libserial.cpp \
	./serialport/misc_util.cpp \
	./serialport/nullmodem.cpp \
	./serialport/serialdummy.cpp \
	./serialport/serialport.cpp \
	./serialport/softmodem.cpp \
	./tandy_sound.cpp \
	./timer.cpp \
	./vga.cpp \
	./vga_attr.cpp \
	./vga_crtc.cpp \
	./vga_dac.cpp \
	./vga_draw.cpp \
	./vga_gfx.cpp \
	./vga_memory.cpp \
	./vga_misc.cpp \
	./vga_other.cpp \
	./vga_paradise.cpp \
	./vga_s3.cpp \
	./vga_seq.cpp \
	./vga_tseng.cpp \
	./vga_xga.cpp \


OBJECTS=$(SOURCES:%.cpp=%.o)

all: $(OBJECTS)

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@
