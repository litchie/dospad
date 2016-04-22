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

#import "AppDelegate.h"
#import "DOSPadBaseViewController.h"
#import "Common.h"
#import <AVFoundation/AVFoundation.h>
#import "ColorTheme.h"

@implementation AppDelegate
@synthesize frameskip;
@synthesize cycles;
@synthesize maxPercent;

-(SDL_uikitopenglview*)screen
{
    return screenView;
}

// iOS 4.x
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    dospad_resume();
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    dospad_pause();
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Only when we have a DOSPadBaseViewController on the stack
    // that we resume the emulator
    NSArray *controllers=[navController viewControllers];
    for (int i = 0; i < [controllers count]; i++) 
    {
        UIViewController *ctrl=[controllers objectAtIndex:i];
        if ([ctrl isKindOfClass:[DOSPadBaseViewController class]])
        {
            dospad_resume();
            break;
        }
    }        
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    dospad_save_history();
}

// iOS 3.x
- (void)applicationWillTerminate:(UIApplication *)application
{
    dospad_save_history();
}

- (void)startDOS 
{
    if (emuThread == nil) 
    {
        emuThread = [DosEmuThread alloc];
    }
    
    if (!emuThread.started) 
    {
        [emuThread start];
    }
}

- (void)initColorTheme
{
	NSString *path = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"configs/colortheme.json"];
	ColorTheme *theme = [[ColorTheme alloc] initWithPath:path];
	[ColorTheme setDefaultTheme:theme];
}

- (void)registerDefaultSettings
{
	NSString *path = [[NSBundle mainBundle] bundlePath];
	path = [path stringByAppendingPathComponent:@"Settings.bundle"];
	path = [path stringByAppendingPathComponent:@"Root.plist"];
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSArray *prefs = settingsDict[@"PreferenceSpecifiers"];
	NSMutableDictionary *defs = [NSMutableDictionary dictionary];
	for (NSDictionary *item in prefs) {
		NSString *key = item[@"Key"];
		NSObject *obj = item[@"DefaultValue"];
		if (key && obj) {
			defs[key] = obj;
		}
	}
	if (defs.count > 0) {
		[[NSUserDefaults standardUserDefaults] registerDefaults:defs];
	}
}

// Reference: https://developer.apple.com/library/ios/qa/qa1719/_index.html
- (BOOL)setBackupAttributeToItemAtPath:(NSString *)filePathString skip:(BOOL)skip
{
    NSURL* URL = [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
 
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:skip]
                                  forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success)
	{
        NSLog(
			@"Error %@ `%@' from backup: %@",
			(skip?@"excluding":@"including"),
			[URL lastPathComponent], error
		);
    }
    return success;
}

/*
 * Exclude or include Documents folder for iCloud/iTunes backup,
 * depending on user settings.
 */
- (void)initBackup
{
	if (DEFS_GET_BOOL(kiCloudBackupEnabled)) {
		[self setBackupAttributeToItemAtPath:DOCUMENTS_DIR skip:NO];
	} else {
		[self setBackupAttributeToItemAtPath:DOCUMENTS_DIR skip:YES];
	}
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	[self registerDefaultSettings];
	[ConfigManager init];
	[self initBackup];
	[self initColorTheme];

	// Make sure we are allowed to play in lock screen
	NSError *setCategoryErr = nil;
	NSError *activationErr  = nil;
	[[AVAudioSession sharedInstance]
		setCategory: AVAudioSessionCategoryPlayback
		error: &setCategoryErr];
	[[AVAudioSession sharedInstance]
		setActive: YES
		error: &activationErr];

    screenView = [[SDL_uikitopenglview alloc] initWithFrame:CGRectMake(0,0,640,400)];
    DOSPadBaseViewController *dospad = [DOSPadBaseViewController dospadWithConfig:[ConfigManager dospadConfigFile]];
    dospad.screenView = screenView;
    navController = [[UINavigationController alloc] initWithRootViewController:dospad];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    navController.navigationBar.translucent=YES;
	uiwindow.rootViewController = navController;
    [uiwindow makeKeyAndVisible];
	[super applicationDidFinishLaunching:application];
#ifdef THREADED
    [self performSelector:@selector(startDOS) withObject:nil afterDelay:0.5];
#endif
    return YES;
}


-(void)setWindowTitle:(char *)title
{
    char buf[8];
    
    if (strstr(title, "max"))
    {
        sscanf(title, "Cpu speed: max %d%% cycles, Frameskip %d", &maxPercent, &frameskip);
        sprintf(buf, "%3d%%", maxPercent);
        cycles = 0;
    } 
    else
    {
        sscanf(title, "Cpu speed: %d cycles, Frameskip %d", &cycles, &frameskip);
        sprintf(buf, "%4d", cycles);
        maxPercent = 0;
    }
    NSString * t = [[NSString alloc] initWithUTF8String:buf];
    NSArray *controllers=[navController viewControllers];
    for (int i = 0; i < [controllers count]; i++) {
        UIViewController *ctrl=[controllers objectAtIndex:i];
        if ([ctrl respondsToSelector:@selector(updateCpuCycles:)]) {
            [ctrl performSelectorOnMainThread:@selector(updateCpuCycles:) withObject:t waitUntilDone:YES];
        }
        if ([ctrl respondsToSelector:@selector(updateFrameskip:)]) {
            [ctrl performSelectorOnMainThread:@selector(updateFrameskip:) 
                                   withObject:[NSNumber numberWithInt:frameskip]
                                waitUntilDone:YES];
        }
        
    }
}

-(void)onLaunchExit
{
    NSArray *controllers=[navController viewControllers];
    for (int i = 0; i < [controllers count]; i++) {
        UIViewController *ctrl=[controllers objectAtIndex:i];
        if ([ctrl respondsToSelector:@selector(onLaunchExit)]) {
            [ctrl performSelectorOnMainThread:@selector(onLaunchExit) withObject:nil waitUntilDone:NO];
        }
    }    
}

@end
