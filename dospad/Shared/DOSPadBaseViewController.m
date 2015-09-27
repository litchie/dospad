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

#import "DOSPadBaseViewController.h"
#include "keys.h"
#import "DosPadViewController.h"
#import "DosPadViewController_iPhone.h"
#import "AppDelegate.h"

#define NOT_IMPLEMENTED(func) func { NSLog(@"Error: `%s' is not implemented!", #func); }

extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);

@implementation DOSPadBaseViewController
@synthesize autoExit;
@synthesize configPath;
@synthesize screenView;


- (bool)isInputSourceEnabled:(InputSourceType)type
{
	switch (type) {
		case InputSource_PCKeyboard:
		case InputSource_GamePad:
		case InputSource_MouseButtons:
			return true;
		case InputSource_Joystick:
			return DEFS_GET_BOOL(kJoystickEnabled);
		case InputSource_NumPad:
			return DEFS_GET_BOOL(kNumpadEnabled);
		default:
			return false;
	}
}

- (NSString*)currentCycles
{
    AppDelegate *d = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (d.maxPercent != 0)
    {
        return [NSString stringWithFormat:@"%3d%%", d.maxPercent];
    } 
    else
    {
        return [NSString stringWithFormat:@"%4d", d.cycles];
    }
}

- (int)currentFrameskip
{
    AppDelegate *d = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return d.frameskip;
}

+ (DOSPadBaseViewController*)dospadWithConfig:(NSString*)configPath
{
    if (ISIPAD())
    {
        DosPadViewController *ctrl = [[DosPadViewController alloc] init];
        ctrl.configPath = configPath;
        return [ctrl autorelease];
    }
    else
    {
        DosPadViewController_iPhone *ctrl = [[DosPadViewController_iPhone alloc] init];
        ctrl.configPath = configPath;
        return [ctrl autorelease];        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    screenView.alpha = 1; // Try to fix reboot problem on iPad 3.2.x
    dospad_resume();
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (ISIPAD() && [self isLandscape])
    {
        screenView.alpha = 0; // Try to fix reboot problem on iPad 3.2.x
    }
    dospad_pause();
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    screenView.delegate=self;
    screenView.mouseHoldDelegate=self;
    [self.view insertSubview:screenView atIndex:0];
    holdIndicator = [[HoldIndicator alloc] initWithFrame:CGRectMake(0,0,128,128)];
    holdIndicator.alpha = 0;
    holdIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [self.view addSubview:holdIndicator];

#ifdef IDOS
    self.title = @"iDOS";
#else
    self.title = @"DOSpad";
#endif

    if (configPath == nil)
    {
        self.configPath = [ConfigManager dospadConfigFile];
    }
    else
    {        
        if (dospad_command_line_ready)
        {
            strcpy(dospad_launch_config, [configPath UTF8String]);
            sprintf(dospad_launch_section, "[start.%s]", ISIPAD()?"ipad":"iphone");
            dospad_should_launch_game = 1;
            SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_RETURN);
            SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_RETURN);
        }
    }
    
    /* TODO: LITCHIE commented out by TVD
    vk = [[VKView alloc] initWithFrame:CGRectMake(0,0,1,1)];
    vk.alpha = 0;
    [self.view addSubview:vk];
     */
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)dealloc {
    [screenView release];
    [configPath release];
    [holdIndicator release];
    [self removeAllInputSources];
    
    //TODO LITCHIE commented out by TVD
    //[vk release];
    [super dealloc];
}

- (void)onLaunchExit
{
    if (self.autoExit)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onMouseLeftDown
{
    [screenView sendMouseEvent:0 left:YES down:YES];
}

- (void)onMouseLeftUp
{
    [screenView sendMouseEvent:0 left:YES down:NO];    
}

- (void)onMouseRightDown
{
    [screenView sendMouseEvent:0 left:NO down:YES];        
}

- (void)onMouseRightUp
{
    [screenView sendMouseEvent:0 left:NO down:NO];            
}

-(BOOL)onDoubleTap:(CGPoint)pt
{
    // Do nothing
    return NO;
}

-(void)onHold:(CGPoint)pt
{
    CGPoint pt2 = [self.screenView convertPoint:pt toView:self.view];
    holdIndicator.center=pt2;
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.3];
    holdIndicator.alpha=1;
    [UIView commitAnimations];
}

-(void)cancelHold:(CGPoint)pt
{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.3];
    holdIndicator.alpha=0;
    [UIView commitAnimations];    
}

- (MouseRightClickMode)currentRightClickMode
{
	if (DEFS_GET_INT(kDoubleTapAsRightClick) == 1) {
		return MouseRightClickWithDoubleTap;
	} else {
		return MouseRightClickDefault;
	}
}

-(void)onResize:(CGSize)sizeNew
{
    NSLog(@"Warning: onResize not implemented");
}

-(void)updateFrameskip:(NSNumber*)skip
{
    NSLog(@"Warning: updateFrameSkip not implemented");
}

-(void)updateCpuCycles:(NSString*)title
{
    NSLog(@"Warning: updateCpuCyles not implemented");
}    

- (void)sendCommandToDOS:(NSString *)cmd
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
            SDL_SendKeyboardKey( 0, SDL_RELEASED, code);
            [NSThread sleepForTimeInterval:0.05];
            if (shift) 
                SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_LSHIFT);
            
        } else {
            break;
        }
        p++;
    }
}

-(void)showOption
{
#if 1
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
#else
	UINavigationController *nav;
	OptionViewController *ctrl = [[OptionViewController alloc] initWithNibName:@"OptionViewController" bundle:nil];
	ctrl.configPath = configPath;
	nav = [[UINavigationController alloc] initWithRootViewController:ctrl];

	[self presentViewController:nav animated:YES completion:nil];
	[ctrl release];
	[nav release];
#endif
}

- (BOOL)isPortrait
{
    return (self.interfaceOrientation == UIInterfaceOrientationPortrait ||
            self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)isLandscape
{
    return (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (BOOL)isInputSourceActive:(InputSourceType)type
{
    switch (type) 
    {
        case InputSource_NumPad:
        {
            return numpad != nil;
            break;
        }
        case InputSource_PCKeyboard:
        {
            return kbd != nil;
            break;
        }
        case InputSource_GamePad:
        {
            return gamepad != nil;
            break;
        }
        case InputSource_Joystick:
        {
            return joystick != nil;
            break;
        }
        case InputSource_PianoKeyboard:
        {
            return piano != nil;
            break;
        }
        case InputSource_MouseButtons:
        {
            return btnMouseLeft != nil && btnMouseRight != nil;
            break;
        }
        default:;
    }    
    return NO;
}

- (void)NOT_IMPLEMENTED(createPCKeyboard);
- (void)NOT_IMPLEMENTED(createNumpad);
- (void)NOT_IMPLEMENTED(createGamepad);
- (void)NOT_IMPLEMENTED(createJoystick);
- (void)NOT_IMPLEMENTED(createMouseButtons);

- (void)createPianoKeyboard
{
    NSString *ui_cfg = [ConfigManager uiConfigFile];
    
    if (ui_cfg != nil)
    {
        piano = [[PianoKeyboard alloc] initWithConfig:ui_cfg section:@"[piano.keybinding]"];
        if (piano)
        {
            [self.view addSubview:piano];
        }
    }
}

- (void)addInputSource:(InputSourceType)type
{
    [self removeInputSource:type];
    switch (type) 
    {
        case InputSource_NumPad:
        {
            [self createNumpad];
            break;
        }
        case InputSource_PCKeyboard:
        {
            [self createPCKeyboard];
            break;
        }
        case InputSource_GamePad:
        {
            [self createGamepad];
            break;
        }
        case InputSource_Joystick:
        {
            [self createJoystick];
            break;
        }
        case InputSource_PianoKeyboard:
        {
            [self createPianoKeyboard];
            break;
        }
        case InputSource_MouseButtons:
        {
            [self createMouseButtons];
            break;
        }
        default:;
    }    
}

- (void)addInputSourceExclusively:(InputSourceType)type
{
    [self removeAllInputSources];
    [self addInputSource:type];
}

- (void)removeAllInputSources
{
    for (int i = 0; i < InputSource_TotalCount; i++) 
    {
        [self removeInputSource:i];
    } 
}

- (void)removeInputSource:(InputSourceType)type
{
    switch (type) 
    {
        case InputSource_NumPad:
        {
            if (numpad) 
            {
                [numpad removeFromSuperview];
                [numpad release];
                numpad = nil;
            }
            break;
        }
        case InputSource_PCKeyboard:
        {
            if (kbd) 
            {
                [kbd removeFromSuperview];
                [kbd release];
                kbd = nil;
            }
            break;
        }
        case InputSource_GamePad:
        {
            if (gamepad) 
            {
                [gamepad removeFromSuperview];
                [gamepad release];
                gamepad = nil;
            }
            break;
        }
        case InputSource_Joystick:
        {
            if (joystick) 
            {
                [joystick removeFromSuperview];
                [joystick release];
                joystick = nil;
            }
            break;
        }
        case InputSource_PianoKeyboard:
        {
            if (piano)
            {
                [piano removeFromSuperview];
                [piano release];
                piano = nil;
            }
            break;
        }
        case InputSource_MouseButtons:
        {
            if (btnMouseLeft) 
            {
                [btnMouseLeft removeFromSuperview];
                [btnMouseLeft release];
                btnMouseLeft = nil;
            }
            if (btnMouseRight) 
            {
                [btnMouseRight removeFromSuperview];
                [btnMouseRight release];
                btnMouseRight = nil;
            }
            break;
        }
        default:;
    }
}

@end
