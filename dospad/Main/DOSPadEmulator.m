/*
 *  Copyright (C) 2010  Chaoji Li
 *
 *  DOSPAD is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

//## DOSPadEmulator
//
// Set up environment for the dosbox emulation.
// - workingDirectory
//   could be the `Documents` folder
//   By default, Documents folder is set up as diskc.
// or the `*.idos`
//   However, if a `*.idos` folder is imported,
//
//
// How autoexec section works.
//
//

#import "DOSPadEmulator.h"
#import "Common.h"
#import "keys.h"
#include "SDL.h"
#import "SDL_keyboard_c.h"
#import "keyinfotable.h"
#import "DPPackage.h"

extern int SDL_PrivateJoystickButton(SDL_Joystick * joystick, Uint8 button, Uint8 state);
extern int SDL_PrivateJoystickAxis(SDL_Joystick * joystick, Uint8 axis, Sint16 value);

char dospad_error_msg[1000];
char diskc[256];
char diskd[256];
cmd_entry *cmd_list=0;
int cmd_count=0;
int dospad_pause_flag = 0;
int dospad_should_launch_game=0;
int dospad_command_line_ready=0;

extern int SDL_main(int argc, char *argv[]);
static DOSPadEmulator* _sharedInstance;

#define MAX_PENDING_KEY_EVENTS 1000

@interface DOSPadEmulator ()
{
    SDL_Joystick *_joystick[4];
}
@property (strong) NSMutableArray<NSString*>* commandList;
@property (strong) DPPackage *package;

- (void)didCommandDone;

@end

@implementation DOSPadEmulator
@synthesize started;

+ (DOSPadEmulator*)sharedInstance
{
	if (!_sharedInstance)
	{
		_sharedInstance = [[DOSPadEmulator alloc] init];
	}
	return _sharedInstance;
}

+ (void)setSharedInstance:(DOSPadEmulator*)instance
{
	_sharedInstance = instance;
}

- (void)dealloc
{
	for (int i = 0;  i < sizeof(_joystick)/sizeof(_joystick[0]); i++)
	{
		SDL_JoystickClose(_joystick[i]);
	}
}

// Use config file 'name' under <diskc>/config.
// If not present, duplicate bundled ones.
// The bundled one will be copied into <diskc>/config
// so user can have a copy ready to work on.
- (NSString*)ensureConfigFile:(NSString*)name
{
	NSFileManager *fm = [NSFileManager defaultManager];

	// Make sure config directory exists under the disk c
	NSString *configDir = [self.workingDirectory.path stringByAppendingPathComponent:@"config"];
	if (![fm fileExistsAtPath:configDir])
	{
		[fm createDirectoryAtPath:configDir withIntermediateDirectories:YES attributes:@{} error:nil];
	}

	NSString *path = [configDir stringByAppendingPathComponent:name];
	if ([fm fileExistsAtPath:path])
		return path;
		
	// Try uppercase, as it could be saved by a DOS program
	path = [configDir stringByAppendingPathComponent:name.uppercaseString];
	if ([fm fileExistsAtPath:path])
		return path;
	
	NSString *bundleConfigs = [[[NSBundle mainBundle] resourceURL]
		URLByAppendingPathComponent:@"configs"].path;

	NSError *err = nil;
	if (![fm copyItemAtPath:[bundleConfigs stringByAppendingPathComponent:name]
			toPath:path error:&err])
	{
		NSLog(@"copy configuration failed: %@",err);
		return nil;
	}
	return path;
}


- (id)init
{
	self = [super init];
	
	// By default, use Documents folder in app sandbox as the
	// workingDirectory. It can be changed later to other location,
	// but it must be done before the emulation starts.
	self.workingDirectory = [NSURL fileURLWithPath:[
        NSSearchPathForDirectoriesInDomains(
		    NSDocumentDirectory, NSUserDomainMask, YES
        )
        lastObject
    ]];
    
    self.commandList = [[NSMutableArray alloc] init];
	return self;
}

- (void)start 
{
	NSAssert([NSThread isMainThread], @"Not in main thread");
    
    if (started)
    {
        NSLog(@"Emulator %p already started", self);
        return;
    }
 
    chdir(self.workingDirectory.path.UTF8String);
    
    self.package = [[DPPackage alloc] initWithURL:self.workingDirectory];
    
    // Generating automount commands
    for (DPDrive * drive in self.package.driveList) {
        NSString *cmd = nil;
        switch (drive.type) {
        case  DPDriveTypeHarddisk:
            if (drive.sourceType == DPDriveSourceTypeImage) {
                cmd = [NSString stringWithFormat:@"imgmount %c \"%@\" -t hdd",
                    drive.driveLetter, drive.sourceUrl.path];
            } else {
                cmd = [NSString stringWithFormat:@"mount %c -freesize 1000 \"%@\"",
                drive.driveLetter, drive.sourceUrl.path];
            }
            break;
        case DPDriveTypeFloppy:
            if (drive.sourceType == DPDriveSourceTypeImage) {
                cmd = [NSString stringWithFormat:@"imgmount %c \"%@\" -t floppy",
                    drive.driveLetter, drive.sourceUrl.path];
            } else {
                cmd = [NSString stringWithFormat:@"mount %c \"%@\" -t floppy",
                drive.driveLetter, drive.sourceUrl.path];
            }
            break;
        case DPDriveTypeCdrom:
            if (drive.sourceType == DPDriveSourceTypeISO) {
                cmd = [NSString stringWithFormat:@"imgmount %c \"%@\" -t iso",
                    drive.driveLetter, drive.sourceUrl.path];
            } else if (drive.sourceType == DPDriveSourceTypeFolder) {
                cmd = [NSString stringWithFormat:@"mount %c \"%@\" -t cdrom",
                    drive.driveLetter, drive.sourceUrl.path];
            }
            break;
        default:
            break;
        }
        if (cmd) {
            [self.commandList addObject:cmd];
        }
    }
    
    // If this is a iDOS package or the iDOS default folder
    // switch to drive C by default
    if (self.package.type == DPPackageTypeIDOS || self.package.type == DPPackageTypeDefault) {
        DPDrive *drv = [self.package findDrive:'C'];
        if (drv) {
            [self.commandList addObject:@"C:"];
            
        }
    }
    [self.commandList addObject:@"cls"];
    [self.commandList addObject:@"REM END AUTOMOUNT"];
    
    // Go to startup program folder and run the program
    if (self.package.defaultProgramPath) {
        NSURL *programUrl = [self.package.baseUrl URLByAppendingPathComponent:self.package.defaultProgramPath];
        NSString *path = [self.package findFileInDrives:programUrl];
        NSString *startupDir = [self.package findFileInDrives:programUrl.URLByDeletingLastPathComponent];
        NSString *programName = self.package.defaultProgramPath.lastPathComponent;
        if (path) {
            [self.commandList addObject:[path substringToIndex:2]];
            if (path.length > 3) {
                [self.commandList addObject:[NSString stringWithFormat:@"cd %@", [startupDir substringFromIndex:3]]];
            }
            [self.commandList addObject:programName];
        }
    }

	_dospadConfigFile  = [self ensureConfigFile:@"dospad.cfg"];
	_uiConfigFile      = [self ensureConfigFile:@"ui.cfg"];
	_mfiConfigFile     = [self ensureConfigFile:@"mfi.cfg"];
	_gamepadConfigFile = [self ensureConfigFile:@"gamepad.cfg"];
     
	// Initalize command history
	dospad_init_history();

	if (_delegate)
	{
		[_delegate emulatorWillStart:self];
	}

    //NSLog(@"Start dosbox in new thread");
    started = YES;
    [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
}

- (void) run {
    @autoreleasepool {
        char *argv[1] = {"dosbox"};
        
        // Calling dosbox entry function
        SDL_main(1, argv);
        started = NO;
    }
} 

- (void)takeScreenshot
{
	if (self.delegate)
	{
		[self.delegate emulator:self saveScreenshot:[self.workingDirectory.path stringByAppendingPathComponent:@"scrnshot.png"]];
	}
}

- (void)open:(NSString*)path
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.delegate)
		{
			[self.delegate emulator:self open:path];
		}
	});
}

- (BOOL)sendCommand:(NSString *)cmd
{
	if (dospad_command_line_ready) {
        [self.commandList addObject:cmd];
        // This is a hack to get dosbox shell to quit its readline
        // and we have a chance to inject the commands
		[self sendKey:SDL_SCANCODE_RETURN];
        return YES;
	} else {
        return NO;
    }
}

- (void)sendText:(NSString *)text
{
    for (int i = 0; i < text.length; i++)
    	[self sendChar:[text characterAtIndex:i]];
}

- (void)sendChar:(unichar)c
{
	Uint16 mod = 0;
	SDL_scancode code;
	
	if (c < 127) {
		/* figure out the SDL_scancode and SDL_keymod for this unichar */
		code = unicharToUIKeyInfoTable[c].code;
		mod  = unicharToUIKeyInfoTable[c].mod;
	}
	else {
		/* we only deal with ASCII right now */
		code = SDL_SCANCODE_UNKNOWN;
		mod = 0;
	}
	
	if (mod & KMOD_SHIFT) {
		/* If character uses shift, press shift down */
		SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_LSHIFT);
	}
	/* send a keydown and keyup even for the character */
	[self sendKey:code];
	if (mod & KMOD_SHIFT) {
		/* If character uses shift, press shift back up */
		SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_LSHIFT);
	}
}

- (void)sendKey:(int)scancode pressed:(BOOL)pressed
{
	SDL_SendKeyboardKey( 0, pressed?SDL_PRESSED:SDL_RELEASED, scancode);
}

- (void)sendKey:(int)scancode
{
	SDL_SendKeyboardKey( 0, SDL_PRESSED, scancode);
    [NSThread sleepForTimeInterval:0.05]; // Very very important	
	SDL_SendKeyboardKey( 0, SDL_RELEASED, scancode);
}

- (BOOL)ensureJoystick:(NSInteger)index
{
    if (!_joystick[index])
    {
        _joystick[index] = SDL_JoystickOpen((int)index);
    }
    return _joystick[index] != 0;
}


- (void)updateJoystick:(NSInteger)index x:(float)x y:(float)y
{
	if (![self ensureJoystick:index])
		return;
		
    int maxValue = 32767;
    x *= maxValue;
    y *= maxValue;
    y = -y;
    
    if (x > 0)
    {
        x = MIN(x, maxValue);
    }
    else
    {
        x = MAX(x, -maxValue);
    }
    
    if (y > 0)
    {
        y = MIN(y, maxValue);
    }
    else
    {
        y = MAX(y, -maxValue);
    }
    
    SDL_PrivateJoystickAxis(_joystick[index], 0, (int)x);
    SDL_PrivateJoystickAxis(_joystick[index], 1, (int)y);
}

- (void)joystickButton:(NSInteger)buttonIndex pressed:(BOOL)pressed joystickIndex:(NSInteger)index
{
	if (![self ensureJoystick:index])
		return;
	SDL_PrivateJoystickButton(_joystick[index], buttonIndex, pressed?SDL_PRESSED:SDL_RELEASED);
}


- (void)didCommandDone
{
	NSLog(@"command done");
}

@end

//-------------------------------------------------------------------
//## DOSBOX Interface
//
// Calling from dosbox to fetch next shell command to execute
// It returns the length of the command.
// If it returns zero, it means there is no more commands to run.

int dospad_get_next_command(char *buf, size_t n) {
    if (_sharedInstance.commandList.count == 0)
        return 0;
    NSString *cmd = _sharedInstance.commandList.firstObject;
    [_sharedInstance.commandList removeObjectAtIndex:0];
    strncpy(buf, cmd.UTF8String, n);
    return (int)strlen(buf);
}

const char *dospad_config_dir()
{
    return [_sharedInstance dospadConfigFile].stringByDeletingLastPathComponent.UTF8String;
}

const char *dospad_config_name()
{
    return [_sharedInstance dospadConfigFile].lastPathComponent.UTF8String;
}

void dospad_pause()
{
    dospad_pause_flag = 1;
}

void dospad_resume()
{
    dospad_pause_flag = 0;
}

void dospad_command_done()
{
	[_sharedInstance performSelectorOnMainThread:@selector(didCommandDone) withObject:nil waitUntilDone:NO];
}

static int strcmp_case_insensitive(const char *cs, const char *ct)
{
    while (*cs && *ct) {
        if (toupper(*cs) < toupper(*ct))
            return -1;
        else if (toupper(*cs) > toupper(*ct))
            return 1;
        cs++, ct++;
    }
    if (*cs == 0 && *ct == 0) return 0;
    else if (*cs) return 1;
    else return -1;
}

#define ISBLANK(c) (c==' '||c=='\t'||c=='\n'||c=='\r')

void dospad_add_history(const char* cmd)
{
    int i;
    if (strlen(cmd) < 2) {
        return;
    }
    cmd_entry *entry = malloc(sizeof(cmd_entry));
    memset(entry, 0, sizeof(cmd_entry));
    for (i = 0; cmd[i]; i++) {
        entry->cmd[i] = cmd[i];
        if (i > 250) {
            entry->cmd[i]=0;
            break;
        }
    }
    while (--i>=0) {
        if (!ISBLANK(entry->cmd[i]))
            break;
        else
            entry->cmd[i]=0;
    }
    if (cmd_list==0) {
        cmd_list=entry;
        cmd_count++;
    } else {
        cmd_entry *p;
        entry->next=cmd_list;
        cmd_list=entry;
        cmd_count++;
        for (p = cmd_list; p && p->next; p=p->next) {
            if (strcmp_case_insensitive(cmd, p->next->cmd)==0) {
                cmd_entry *tmp = p->next;
                p->next = tmp->next;
                free(tmp);
                cmd_count--;
            }
        }
    }
}

void dospad_save_history()
{
    NSString *path=[[NSString stringWithUTF8String:diskc] stringByAppendingPathComponent:@"HISTORY"];
    FILE *fp = fopen([path UTF8String], "w");
    if (fp == NULL) {
        return;
    }
    cmd_entry *p = cmd_list;
    int cnt=MAX_HISTORY_ITEMS;
    while (p && cnt-- > 0) {
        fprintf(fp, "%s\n", p->cmd);
        p = p->next;
    }
    fclose(fp);
}

void dospad_init_history()
{
    char buf[256];
    
    NSString *path=[[NSString stringWithUTF8String:diskc] stringByAppendingPathComponent:@"HISTORY"];
    FILE *fp = fopen([path UTF8String], "r");
    if (fp == NULL) {
        return;
    }
    
    while (fgets(buf, 256, fp)) {
        dospad_add_history(buf);
    }
    
    fclose(fp);
}

void dospad_should_pause()
{
    while (dospad_pause_flag)
    {
        [NSThread sleepForTimeInterval:0.5];
    }
}

int dospad_open(const char *args)
{
	if (strcmp(args, "screenshot")==0)
	{
		[_sharedInstance performSelectorOnMainThread:@selector(takeScreenshot) withObject:nil waitUntilDone:NO];
	}
	else if (args[0] == 0)
	{
		[_sharedInstance performSelector:@selector(open:) withObject:nil afterDelay:0.5];
//		[_sharedInstance performSelectorOnMainThread:@selector(open:) withObject:nil waitUntilDone:NO];
	}
	else
	{
		NSString *s = [NSString stringWithUTF8String:args];
		s= [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

		[_sharedInstance performSelector:@selector(open:) withObject:s afterDelay:0.5];
	}
	return 0;
}
