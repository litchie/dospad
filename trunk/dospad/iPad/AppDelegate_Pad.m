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

#import "AppDelegate_Pad.h"
#import "FileSystemObject.h"
#import "Common.h"

@implementation AppDelegate_Pad
@synthesize controller;

-(SDL_uikitopenglview*)screen
{
    return controller.screenView;
}



// iOS 4.x
- (void)applicationWillEnterForeground:(UIApplication *)application
{

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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after application launch
	[uiwindow addSubview:controller.view];
    [uiwindow makeKeyAndVisible];
    [super applicationDidFinishLaunching:application];
	return YES;
}

- (void)dealloc {
    [controller release];
    [super dealloc];
}

/*
 if(CPU_CycleAutoAdjust) {
 sprintf(title,"Cpu speed: max %3d%% cycles, Frameskip %2d",internal_cycles,internal_frameskip);
 } else {
 sprintf(title,"Cpu speed: %8d cycles, Frameskip %2d",internal_cycles,internal_frameskip);
 } 
 */
-(void)setWindowTitle:(char *)title
{
    int cycles=0, frameskip=0;
    int max_percent=0;
    char buf[8];
    if (strstr(title, "max")) {
        sscanf(title, "Cpu speed: max %d%% cycles, Frameskip %d", &max_percent, &frameskip);
        sprintf(buf, "%3d%%", max_percent);
    } else {
        sscanf(title, "Cpu speed: %d cycles, Frameskip %d", &cycles, &frameskip);
        sprintf(buf, "%4d", cycles);
    }
    
    NSString * t = [[NSString alloc] initWithUTF8String:buf];
    [self.controller performSelectorOnMainThread:@selector(updateCpuCycles:) withObject:t waitUntilDone:YES];
    [self.controller performSelectorOnMainThread:@selector(updateFrameskip:) withObject:[NSNumber numberWithInt:frameskip] waitUntilDone:YES];
    [t release];
}


@end
