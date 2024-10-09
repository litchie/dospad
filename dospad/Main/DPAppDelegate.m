/*
 *  Copyright (C) 2010-2024 Chaoji Li
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

#import "DPAppDelegate.h"
#import "DPEmulatorViewController.h"
#import "Common.h"
#import <AVFoundation/AVFoundation.h>
#import "ColorTheme.h"
#import "UIViewController+Alert.h"
#import "DPSettings.h"

#define kLastURL @"LastPackageURL"

@interface DPAppDelegate ()
{
}
@property (nonatomic, readonly) DPEmulatorViewController *emulatorController;
@end


@implementation DPAppDelegate
@synthesize frameskip;
@synthesize cycles;
@synthesize maxPercent;

- (DPEmulatorViewController*)emulatorController {
    return (DPEmulatorViewController*)self.window.rootViewController;
}

- (UIWindow*)window {
    if (_window == nil) {
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return _window;
}

- (void)rememberURL:(NSURL*)url
{
    NSData *bookmark = [url bookmarkDataWithOptions:0
        includingResourceValuesForKeys:nil
        relativeToURL:nil
        error:nil];
    if (bookmark)
    {
        [[NSUserDefaults standardUserDefaults] setObject:bookmark
            forKey:kLastURL];
    }
}

- (NSURL*)openLastURL
{
	NSData *bookmark = [[NSUserDefaults standardUserDefaults] objectForKey:kLastURL];
	if (bookmark)
	{
		NSError *err = nil;
		BOOL isStale = NO;
		NSURL *url = [NSURL URLByResolvingBookmarkData:bookmark options:0 relativeToURL:nil bookmarkDataIsStale:&isStale error:&err];
		if (url && [[NSFileManager defaultManager] fileExistsAtPath:url.path] && !isStale)
		{
			return url;
		}
	}
	return nil;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
	sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	NSLog(@"openURL: %@", url);
	if (url.isFileURL)
	{
		if ([DOSPadEmulator sharedInstance].started)
		{
			// TODO Should automatically terminate the current
            // emulator thread. Not easy though
			[self.emulatorController alert:@"Sorry, iDOS is busy"
				message:@"Can not launch game package while emulator is running. Please terminate the app first."];
			return NO;
		}
		[url startAccessingSecurityScopedResource];
		[self rememberURL:url];
		[DOSPadEmulator sharedInstance].workingDirectory = url;
	}
	return YES;
}

-(SDL_uikitopenglview*)screen
{
    return screenView;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    dospad_pause();
    [self.emulatorController willResignActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    dospad_resume();
    [self.emulatorController didBecomeActive];
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
	[[DOSPadEmulator sharedInstance] start];
}

- (void)initColorTheme
{
	NSString *path = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"configs/colortheme.json"];
	ColorTheme *theme = [[ColorTheme alloc] initWithPath:path];
	[ColorTheme setDefaultTheme:theme];
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
	NSLog(@"didFinishLaunchingWithOptions %@", launchOptions);
	[DPSettings shared];
	[self initBackup];
	[self initColorTheme];
	
	if ([DPSettings shared].autoOpenLastPackage)
	{
		NSURL *lastUrl = [self openLastURL];
		if (lastUrl) {
			[DOSPadEmulator sharedInstance].workingDirectory = lastUrl;
		}
	}

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
	self.emulatorController.screenView = screenView;
    
	[super applicationDidFinishLaunching:application];

#ifdef THREADED
	// FIXME at present it is a must to delay emulation thread
    [self performSelector:@selector(startDOS) withObject:nil afterDelay:1];
#endif
    return YES;
}


-(void)setWindowTitle:(char *)title
{
    char buf[8];
    NSAssert([NSThread isMainThread], @"Should work in main thread");
    
    // Skip the beginning and go directly to the juicy part
    title = strstr(title, "CPU speed");
    if (!title) {
        return;
    }
    
    if (strstr(title, "max"))
    {
        sscanf(title, "CPU speed: max %d%% cycles, Frameskip %d", &maxPercent, &frameskip);
        sprintf(buf, "%3d%%", maxPercent);
        cycles = 0;
    } 
    else
    {
        sscanf(title, "CPU speed: %d cycles, Frameskip %d", &cycles, &frameskip);
        sprintf(buf, "%4d", cycles);
        maxPercent = 0;
    }
    
    [self.emulatorController updateCpuCycles:@(buf)];
	[self.emulatorController updateFrameskip:@(frameskip)];
}

@end
