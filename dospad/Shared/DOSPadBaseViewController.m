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
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+Alert.h"
#import "MfiGamepadManager.h"
#import "MfiGamepadMapperView.h"

#define NOT_IMPLEMENTED(func) func { NSLog(@"Error: `%s' is not implemented!", #func); }

extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);

@interface DOSPadBaseViewController()
<MfiGamepadManagerDelegate,
MfiGamepadMapperDelegate>
{
	MfiGamepadConfiguration *_mfiConfig;
	MfiGamepadManager *_mfiManager;
	MfiGamepadMapperView *_mfiMapper;
}

@end


@implementation DOSPadBaseViewController
@synthesize autoExit;
@synthesize screenView;

- (void)updateScreen
{
	NSAssert(FALSE, @"Must be implemented by subclass");
}


// MARK: opengles view delegate
// Screen Resize
-(void)onResize:(CGSize)sizeNew
{
    self.screenView.bounds = CGRectMake(0, 0, sizeNew.width, sizeNew.height);
    [self updateScreen];
}

// scale the screen view to fill the available rect,
// and keep it at 4:3 unless it's a wide screen (16:10).
// Return the occupied rect.
- (CGRect)putScreen:(CGRect)availRect
{
	CGFloat cx = CGRectGetMidX(availRect);
	CGFloat cy = CGRectGetMidY(availRect);
	CGFloat w = availRect.size.width;
	CGFloat h = availRect.size.height;
    CGFloat sw = self.screenView.bounds.size.width;
    CGFloat sh = self.screenView.bounds.size.height;
	if (w * 3 / 4 > h)
	{
		// Make it 16:10 if this is a wide screen
		CGFloat maxWidth = h * 16 / 10;
		if (w >= maxWidth)
			w = maxWidth;
		else
			w = h * 4 / 3;
	}
	else
	{
		h = w * 3 / 4;
	}
    self.screenView.transform = CGAffineTransformMakeScale(w/sw,h/sh);
	self.screenView.center = CGPointMake(cx, cy);
    return CGRectMake(cx-w/2, cy-h/2, w, h);
}

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

+ (DOSPadBaseViewController*)dospadController
{
    if (ISIPAD())
    {
        DosPadViewController *ctrl = [[DosPadViewController alloc] init];
        return ctrl;
    }
    else
    {
        DosPadViewController_iPhone *ctrl = [[DosPadViewController_iPhone alloc] init];
        return ctrl;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    screenView.alpha = 1; // Try to fix reboot problem on iPad 3.2.x
    dospad_resume();
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (self.kbdspy)
    {
    	[self.kbdspy becomeFirstResponder];
		[self.view bringSubviewToFront:self.kbdspy];
	}
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
    
    [[DOSPadEmulator sharedInstance] setDelegate:self];
    
    screenView.delegate=self;
    screenView.mouseHoldDelegate=self;
    [self.view insertSubview:screenView atIndex:0];
    holdIndicator = [[HoldIndicator alloc] initWithFrame:CGRectMake(0,0,100,100)];
    holdIndicator.alpha = 0;
    //holdIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5);
   // [self.view addSubview:holdIndicator];
    
#ifdef APPSTORE
    // For non appstore builds, we should use private API to support
    // external keyboard.
    self.kbdspy = [[KeyboardSpy alloc] initWithFrame:CGRectMake(0,0,60,40)];
    [self.view addSubview:self.kbdspy];
#endif
    
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
    [self removeAllInputSources];
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

// MARK: Mouse Hold
-(void)onHold:(CGPoint)pt
{
#if 0 // Disable hold indicator
    CGPoint pt2 = [self.screenView convertPoint:pt toView:self.view];
    holdIndicator.center=pt2;
    [self.view bringSubviewToFront:holdIndicator];
    [UIView animateWithDuration:0.3 animations:^{
		holdIndicator.alpha = 1;
	}];
#endif
}

-(void)cancelHold:(CGPoint)pt
{
    holdIndicator.alpha=0;
}

-(void)onHoldMoved:(CGPoint)pt
{
    CGPoint pt2 = [self.screenView convertPoint:pt toView:self.view];
    holdIndicator.center=pt2;
}

- (MouseRightClickMode)currentRightClickMode
{
	if (DEFS_GET_INT(kDoubleTapAsRightClick) == 1) {
		return MouseRightClickWithDoubleTap;
	} else {
		return MouseRightClickDefault;
	}
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
	[[DOSPadEmulator sharedInstance] sendCommand:cmd];
}

-(void)showOption:(id)sender
{
	[self alert:@"Action" message:@"Please choose an option"
		actions:@[
	 		[UIAlertAction actionWithTitle:@"Screenshot"
	 			style:UIAlertActionStyleDefault
	 			handler:^(UIAlertAction * _Nonnull action) {
	 				[[DOSPadEmulator sharedInstance] takeScreenshot];
                }],
	 		[UIAlertAction actionWithTitle:@"Settings"
	 			style:UIAlertActionStyleDefault
	 			handler:^(UIAlertAction * _Nonnull action) {
					[[UIApplication sharedApplication]
					 openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
					 options:@{} completionHandler:nil];
                }]
		]
		source:sender];
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
    }    
    return NO;
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)NOT_IMPLEMENTED(createPCKeyboard);
- (void)NOT_IMPLEMENTED(createNumpad);
- (void)NOT_IMPLEMENTED(createGamepad);
- (void)NOT_IMPLEMENTED(createJoystick);
- (void)NOT_IMPLEMENTED(createMouseButtons);

- (void)createPianoKeyboard
{
    NSString *ui_cfg = 0;//get_temporary_merged_file(configPath, get_default_config());
    
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
        default:
        	break;
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
                numpad = nil;
            }
            break;
        }
        case InputSource_PCKeyboard:
        {
            if (kbd) 
            {
                [kbd removeFromSuperview];
                kbd = nil;
            }
            break;
        }
        case InputSource_GamePad:
        {
            if (gamepad) 
            {
                [gamepad removeFromSuperview];
                gamepad = nil;
            }
            break;
        }
        case InputSource_Joystick:
        {
            if (joystick) 
            {
                [joystick removeFromSuperview];
                joystick = nil;
            }
            break;
        }
        case InputSource_PianoKeyboard:
        {
            if (piano)
            {
                [piano removeFromSuperview];
                piano = nil;
            }
            break;
        }
        case InputSource_MouseButtons:
        {
            if (btnMouseLeft) 
            {
                [btnMouseLeft removeFromSuperview];
                btnMouseLeft = nil;
            }
            if (btnMouseRight) 
            {
                [btnMouseRight removeFromSuperview];
                btnMouseRight = nil;
            }
            break;
        }            
    }
}

-(void) openMfiMapper:(id)sender
{
	// Sometimes we press too early before the emulator sets up
	// configuration file.
	if (![DOSPadEmulator sharedInstance].started)
		return;
		
	if (_mfiMapper) {
		[self.view bringSubviewToFront:_mfiMapper];
		return;
	}

	[self addInputSourceExclusively:InputSource_PCKeyboard];
	CGRect rect = self.view.bounds;
	rect.size.height -= kbd.frame.size.height+4;
	
	CGFloat maxHeight = 400;
	if (rect.size.height > maxHeight)
	{
		rect.origin.y += (rect.size.height - maxHeight)/2;
		rect.size.height = maxHeight;
	}

	CGFloat maxWidth = rect.size.height * 2;
	if (rect.size.width > maxWidth)
	{
		rect.origin.x = (rect.size.width-maxWidth)/2;
		rect.size.width = maxWidth;
	}

	_mfiMapper = [[MfiGamepadMapperView alloc] initWithFrame:rect configuration:_mfiConfig];
	[self.view addSubview:_mfiMapper];
    kbd.externKeyDelegate = self;
	_mfiMapper.delegate = self;
}

// MARK: MfiGamepadMapperDelegate

- (void)mfiGamepadMapperDidClose:(MfiGamepadMapperView *)mapper
{
	_mfiMapper = nil;
	[self removeInputSource:InputSource_PCKeyboard];
}

# pragma - mark KeyDelegate
-(void)onKeyDown:(KeyView*)k {
	if (_mfiMapper && k.code > 0)
	{
		[_mfiMapper onKey:k.code pressed:YES];
	}
}

-(void)onKeyUp:(KeyView*)k {
	if (_mfiMapper && k.code > 0)
	{
		[_mfiMapper onKey:k.code pressed:YES];
	}	
}

-(void) onKeyFunction:(KeyView *)k {
}

// MARK: DOSEmulatorDelegate

- (void)emulatorWillStart:(DOSPadEmulator *)emulator
{
	_mfiConfig = [[MfiGamepadConfiguration alloc] initWithConfig:emulator.mfiConfigFile];
	_mfiManager = [MfiGamepadManager defaultManager];
	_mfiManager.delegate = self;
}

- (void)emulator:(DOSPadEmulator *)emulator saveScreenshot:(NSString *)path
{
	UIImage *image = [self.screenView capture];
	if (image) {
		[UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
	}
}

- (void)emulator:(DOSPadEmulator *)emulator open:(NSString*)path
{
	if (path == nil)
	{
		NSArray *utis = @[
			(NSString *)kUTTypeFolder,
			@"com.litchie.idos-package"
		];
		UIDocumentPickerViewController *picker;
		picker = [[UIDocumentPickerViewController alloc]
			initWithDocumentTypes:utis
			inMode:UIDocumentPickerModeOpen];
		picker.delegate = self;
		if (@available(iOS 11.0, *)) {
			picker.allowsMultipleSelection = YES;
		}
		[self presentViewController:picker
			animated:YES
			completion:nil];
	}
}


#pragma mark - DocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller
	didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
	NSURL *url = [urls firstObject];
	[url startAccessingSecurityScopedResource];
	//[[DOSPadEmulator sharedInstance] sendCommand:@"mount -u d"];
	NSString *cmd=[NSString stringWithFormat:@"mount d \"%@\"", url.path];
	[[DOSPadEmulator sharedInstance] sendCommand:cmd];
	[[DOSPadEmulator sharedInstance] sendCommand:@"d:"];
	
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
	// Do nothing
}

// MARK: MfiGamepadManagerDelegate

- (void)mfiButton:(MfiGamepadButtonIndex)buttonIndex pressed:(BOOL)pressed atPlayer:(NSInteger)playerIndex
{
	if (_mfiMapper)
	{
		[_mfiMapper onButton:buttonIndex pressed:pressed atPlayer:playerIndex];
		return;
	}

	if (buttonIndex == MFI_GAMEPAD_BUTTON_A || buttonIndex == MFI_GAMEPAD_BUTTON_X)
	{
		if ([_mfiConfig isJoystickAtPlayer:playerIndex])
		{
			[[DOSPadEmulator sharedInstance] joystickButton:(buttonIndex == MFI_GAMEPAD_BUTTON_A?0:1)
				pressed:pressed joystickIndex:playerIndex];
			return;
		}
	}

	int scancode = [_mfiConfig scancodeForButton:buttonIndex atPlayer:playerIndex];
	if (scancode)
	{
		SDL_SendKeyboardKey( 0, pressed?SDL_PRESSED:SDL_RELEASED, scancode);
	}
}

- (void)mfiJoystickMoveWithX:(float)x y:(float)y atPlayer:(NSInteger)playerIndex
{
	if (_mfiMapper)
	{
		[_mfiMapper onJoystickMoveWithX:x y:y atPlayer:playerIndex];
		return;
	}
	if ([_mfiConfig isJoystickAtPlayer:playerIndex])
	{
		[[DOSPadEmulator sharedInstance] updateJoystick:playerIndex x:x y:y];
	}
}

- (void)mfiDidUpdatePlayers
{
	NSLog(@"mfi did update players");
	if (_mfiMapper) {
		[_mfiMapper update];
	}
}


@end
