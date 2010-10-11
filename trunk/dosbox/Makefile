GCC=g++
CFLAGS= -DHAVE_CONFIG_H -I.  -Iinclude -I/usr/local/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE  -g
LFLAGS=-L/usr/local/lib -lz -lSDLmain -lSDL -Wl,-framework,Cocoa \
       -framework OpenGL -framework CoreMIDI -framework AudioUnit -framework AudioToolbox
DOSBOX_SRC=./src/cpu/callback.cpp \
	./src/cpu/core_dyn_x86.cpp \
	./src/cpu/core_dynrec.cpp \
	./src/cpu/core_full.cpp \
	./src/cpu/core_normal.cpp \
	./src/cpu/core_prefetch.cpp \
	./src/cpu/core_simple.cpp \
	./src/cpu/cpu.cpp \
	./src/cpu/flags.cpp \
	./src/cpu/modrm.cpp \
	./src/cpu/paging.cpp \
	./src/dos/cdrom.cpp \
	./src/dos/cdrom_aspi_win32.cpp \
	./src/dos/cdrom_image.cpp \
	./src/dos/cdrom_ioctl_linux.cpp \
	./src/dos/cdrom_ioctl_os2.cpp \
	./src/dos/cdrom_ioctl_win32.cpp \
	./src/dos/dos.cpp \
	./src/dos/dos_classes.cpp \
	./src/dos/dos_devices.cpp \
	./src/dos/dos_execute.cpp \
	./src/dos/dos_files.cpp \
	./src/dos/dos_ioctl.cpp \
	./src/dos/dos_keyboard_layout.cpp \
	./src/dos/dos_memory.cpp \
	./src/dos/dos_misc.cpp \
	./src/dos/dos_mscdex.cpp \
	./src/dos/dos_programs.cpp \
	./src/dos/dos_tables.cpp \
	./src/dos/drive_cache.cpp \
	./src/dos/drive_fat.cpp \
	./src/dos/drive_iso.cpp \
	./src/dos/drive_local.cpp \
	./src/dos/drive_virtual.cpp \
	./src/dos/drives.cpp \
	./src/dosbox.cpp \
	./src/fpu/fpu.cpp \
	./src/hardware/adlib.cpp \
	./src/hardware/cmos.cpp \
	./src/hardware/dbopl.cpp \
	./src/hardware/disney.cpp \
	./src/hardware/dma.cpp \
	./src/hardware/gameblaster.cpp \
	./src/hardware/gus.cpp \
	./src/hardware/hardware.cpp \
	./src/hardware/iohandler.cpp \
	./src/hardware/ipx.cpp \
	./src/hardware/ipxserver.cpp \
	./src/hardware/joystick.cpp \
	./src/hardware/keyboard.cpp \
	./src/hardware/memory.cpp \
	./src/hardware/mixer.cpp \
	./src/hardware/mpu401.cpp \
	./src/hardware/opl.cpp \
	./src/hardware/pcspeaker.cpp \
	./src/hardware/pic.cpp \
	./src/hardware/sblaster.cpp \
	./src/hardware/serialport/directserial.cpp \
	./src/hardware/serialport/libserial.cpp \
	./src/hardware/serialport/misc_util.cpp \
	./src/hardware/serialport/nullmodem.cpp \
	./src/hardware/serialport/serialdummy.cpp \
	./src/hardware/serialport/serialport.cpp \
	./src/hardware/serialport/softmodem.cpp \
	./src/hardware/tandy_sound.cpp \
	./src/hardware/timer.cpp \
	./src/hardware/vga.cpp \
	./src/hardware/vga_attr.cpp \
	./src/hardware/vga_crtc.cpp \
	./src/hardware/vga_dac.cpp \
	./src/hardware/vga_draw.cpp \
	./src/hardware/vga_gfx.cpp \
	./src/hardware/vga_memory.cpp \
	./src/hardware/vga_misc.cpp \
	./src/hardware/vga_other.cpp \
	./src/hardware/vga_paradise.cpp \
	./src/hardware/vga_s3.cpp \
	./src/hardware/vga_seq.cpp \
	./src/hardware/vga_tseng.cpp \
	./src/hardware/vga_xga.cpp \
	./src/ints/bios.cpp \
	./src/ints/bios_disk.cpp \
	./src/ints/bios_keyboard.cpp \
	./src/ints/ems.cpp \
	./src/ints/int10.cpp \
	./src/ints/int10_char.cpp \
	./src/ints/int10_memory.cpp \
	./src/ints/int10_misc.cpp \
	./src/ints/int10_modes.cpp \
	./src/ints/int10_pal.cpp \
	./src/ints/int10_put_pixel.cpp \
	./src/ints/int10_vesa.cpp \
	./src/ints/int10_video_state.cpp \
	./src/ints/int10_vptable.cpp \
	./src/ints/mouse.cpp \
	./src/ints/xms.cpp \
	./src/libs/gui_tk/gui_tk.cpp \
	./src/libs/zmbv/zmbv.cpp \
	./src/misc/cross.cpp \
	./src/misc/messages.cpp \
	./src/misc/programs.cpp \
	./src/misc/setup.cpp \
	./src/misc/support.cpp \
	./src/shell/shell.cpp \
	./src/shell/shell_batch.cpp \
	./src/shell/shell_cmds.cpp \
	./src/shell/shell_misc.cpp \

GUI_SRC=./src/gui/midi.cpp \
	./src/gui/render.cpp \
	./src/gui/render_scalers.cpp \
	./src/gui/sdl_gui.cpp \
	./src/gui/sdl_mapper.cpp \
	./src/gui/sdlmain.cpp


OBJECTS=$(DOSBOX_SRC:%.cpp=%.o) $(GUI_SRC:%.cpp=%.o)

dosbox: $(OBJECTS)
	g++ -g -O2 $(LFLAGS) -o $@ $(OBJECTS) 

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@
clean:
	rm -f $(OBJECTS)