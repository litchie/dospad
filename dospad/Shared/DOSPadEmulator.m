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

//
// DOSPadEmulator
//
// Set up environment for the dosbox emulation.
// - disk c
//   By default, Documents folder is set up as diskc.
//   However, if a `*.idos` folder is imported,
//   that folder will be mounted as diskc instead.
//
#import "DOSPadEmulator.h"
#import "FileSystemObject.h"
#import "Common.h"

extern char automount_path[];

char dospad_error_msg[1000];
char diskc[256];
char diskd[256];
cmd_entry *cmd_list=0;
int cmd_count=0;
int dospad_pause_flag = 0;
int dospad_should_launch_game=0;
int dospad_command_line_ready=0;
char dospad_launch_config[256];
char dospad_launch_section[256];

extern int SDL_main(int argc, char *argv[]);
static DOSPadEmulator* _sharedInstance;

@interface DOSPadEmulator ()
{

}
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

// Use config files under diskc, if not present,
// use bundled ones.
- (void)ensureConfigFiles
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *configDir = [self.diskcDirectory stringByAppendingPathComponent:@"config"];
	if (![fm fileExistsAtPath:configDir]) {
		[fm createDirectoryAtPath:configDir withIntermediateDirectories:YES attributes:@{} error:nil];
	}
	NSString *path = [configDir stringByAppendingPathComponent:@"dospad.cfg"];
    NSString *bundleConfigs = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"configs"].path;

	// Try to copy the bundled dospad.cfg if there is no dospad.cfg in c:/config
	if (![fm fileExistsAtPath:path]) {
		[fm copyItemAtPath:[bundleConfigs stringByAppendingPathComponent:@"dospad.cfg"] toPath:path error:nil];
	}

	// Fallback to bundled dospad.cfg
	if ([fm fileExistsAtPath:path]) {
		_dospadConfigFile = path;
	} else {
		_dospadConfigFile = [bundleConfigs stringByAppendingPathComponent:@"dospad.cfg"];
	}
	
	path = [configDir stringByAppendingPathComponent:@"ui.cfg"];
	if ([fm fileExistsAtPath:path]) {
		_uiConfigFile = path;
	} else {
		_uiConfigFile = [bundleConfigs stringByAppendingPathComponent:@"ui.cfg"];
	}
}

- (id)init
{
	self = [super init];
	
	self.diskcDirectory = [NSSearchPathForDirectoriesInDomains(
		NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	
	return self;
}

- (void)start 
{
	NSAssert([NSThread isMainThread], @"Not in main thread");
    if (started) {
        //NSLog(@"DosEmuThread %p already started", self);
        return;
    }
    
    [self ensureConfigFiles];
    
    strcpy(diskc, self.diskcDirectory.UTF8String);
	//strcpy(diskd, "/var/mobile/Documents");
	strcpy(automount_path, diskc);
	
	chdir(diskc);
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
		[self.delegate emulator:self saveScreenshot:[self.diskcDirectory stringByAppendingPathComponent:@"scrnshot.png"]];
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

- (void)sendCommand:(NSString *)cmd
{
    if (cmd == nil) return;
    const char *p = [cmd UTF8String];
    while (*p!=0)
    {
        int ch = *p;
        int shift=0;
        int code=get_scancode_for_char(ch, &shift);
        if (code >= 0) {
            if (shift)
                SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_LSHIFT);
            
            SDL_SendKeyboardKey( 0, SDL_PRESSED, code);
            [NSThread sleepForTimeInterval:0.05];
            SDL_SendKeyboardKey( 0, SDL_RELEASED, code);
            if (shift)
                SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_LSHIFT);
            
        } else {
            break;
        }
        p++;
    }
	SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_RETURN);
	[NSThread sleepForTimeInterval:0.05];
	SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_RETURN);
  
}

@end

////////////////////////////////////////////////////////////
// DOSBOX Interface

const char *dospad_config_dir()
{
    return [_sharedInstance dospadConfigFile].stringByDeletingLastPathComponent.UTF8String;
}

void dospad_pause()
{
    dospad_pause_flag = 1;
}

void dospad_resume()
{
    dospad_pause_flag = 0;
}

void dospad_launch_done()
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(onLaunchExit)])
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(onLaunchExit)];
    }
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
		sprintf(dospad_error_msg, "Unsupported open");
		return -1;
	}
	return 0;
}
