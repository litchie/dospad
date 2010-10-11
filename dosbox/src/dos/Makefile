GCC=g++
CFLAGS= -DHAVE_CONFIG_H -I. -I../..  -I../../include -I/usr/local/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE  -g -O2
SOURCES=cdrom.cpp\
	cdrom_aspi_win32.cpp\
	cdrom_image.cpp\
	cdrom_ioctl_linux.cpp\
	cdrom_ioctl_os2.cpp\
	cdrom_ioctl_win32.cpp\
	dos.cpp\
	dos_classes.cpp\
	dos_devices.cpp\
	dos_execute.cpp\
	dos_files.cpp\
	dos_ioctl.cpp\
	dos_keyboard_layout.cpp\
	dos_memory.cpp\
	dos_misc.cpp\
	dos_mscdex.cpp\
	dos_programs.cpp\
	dos_tables.cpp\
	drive_cache.cpp\
	drive_fat.cpp\
	drive_iso.cpp\
	drive_local.cpp\
	drive_virtual.cpp\
	drives.cpp


OBJECTS=$(SOURCES:%.cpp=%.o)

all: $(OBJECTS)

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@
