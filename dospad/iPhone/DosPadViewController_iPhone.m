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

#import "DosPadViewController_iPhone.h"
#import "FileSystemObject.h"
#import "Common.h"
#import "AppDelegate.h"
#import "ColorTheme.h"


static struct {
	InputSourceType type;
	const char *onImageName;
	const char *offImageName;
} toggleButtonInfo [] = {
	{InputSource_PCKeyboard,    "modekeyon.png",          "modekeyoff.png"    },
	{InputSource_MouseButtons,  "mouseon.png",            "mouseoff.png"      },
	{InputSource_GamePad,       "modegamepadpressed.png", "modegamepad.png"   },
	{InputSource_Joystick,      "modejoypressed.png",     "modejoy.png"       },
	{InputSource_NumPad,        "modenumpadpressed.png",  "modenumpad.png"    },
	{InputSource_PianoKeyboard, "modepianopressed.png",   "modepiano.png"     },
};
#define NUM_BUTTON_INFO (sizeof(toggleButtonInfo)/sizeof(toggleButtonInfo[0]))

// TODO color with pattern image doesn't work well with transparency
// so we need to invent a new View subclass.
// Do we really need to do this?
@implementation ToolPanelView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	UIImage *backgroundImage = [UIImage imageNamed:@"bar-portrait-iphone"];
	[backgroundImage drawInRect:rect];
}

@end



@implementation DosPadViewController_iPhone


- (void)initUI
{
	//---------------------------------------------------
	// 1. Root View
	//---------------------------------------------------
	//    UIImageView *baseView = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,480)] autorelease];
	//    self.view.contentMode = UIViewContentModeCenter;
	self.view.backgroundColor = HexColor(0x585458);
	self.view.userInteractionEnabled = YES;
	CGRect viewRect = self.view.bounds;
	
	//---------------------------------------------------
	// 2. Create the toolbar in portrait mode
	//---------------------------------------------------
	
	toolPanel = [[ToolPanelView alloc] initWithFrame:CGRectMake(0,240,320,25)];
	
	UIButton *btnOption = [[[UIButton alloc] initWithFrame:CGRectMake(0,0,32,25)] autorelease];
	UIButton *btnLeft = [[[UIButton alloc] initWithFrame:CGRectMake(33,0,67,25)] autorelease];
	UIButton *btnRight = [[[UIButton alloc] initWithFrame:CGRectMake(100,0,67,25)] autorelease];
	[btnLeft setImage:[UIImage imageNamed:@"leftmouse"] forState:UIControlStateHighlighted];
	[btnRight setImage:[UIImage imageNamed:@"rightmouse"] forState:UIControlStateHighlighted];
	
	
	[btnOption addTarget:self action:@selector(showOption) forControlEvents:UIControlEventTouchUpInside];
	[btnLeft addTarget:self action:@selector(onMouseLeftDown) forControlEvents:UIControlEventTouchDown];
	[btnLeft addTarget:self action:@selector(onMouseLeftUp) forControlEvents:UIControlEventTouchUpInside];
	[btnRight addTarget:self action:@selector(onMouseRightDown) forControlEvents:UIControlEventTouchDown];
	[btnRight addTarget:self action:@selector(onMouseRightUp) forControlEvents:UIControlEventTouchUpInside];
	
	labCycles = [[UILabel alloc] initWithFrame:CGRectMake(272,6,43,12)];
	labCycles.backgroundColor = [UIColor clearColor];
	labCycles.textColor=[UIColor colorWithRed:74/255.0 green:1 blue:55/255.0 alpha:1];
	labCycles.font=[UIFont fontWithName:@"DBLCDTempBlack" size:12];
	labCycles.text=[self currentCycles];
	labCycles.textAlignment=UITextAlignmentCenter;
	labCycles.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
	fsIndicator = [FrameskipIndicator alloc];
	fsIndicator = [fsIndicator initWithFrame:CGRectMake(labCycles.frame.size.width-8,2,4,labCycles.frame.size.height-4)
									   style:FrameskipIndicatorStyleVertical];
	fsIndicator.count = [self currentFrameskip];
	[labCycles addSubview:fsIndicator];
	
	[toolPanel addSubview:btnOption];
	[toolPanel addSubview:btnLeft];
	[toolPanel addSubview:btnRight];
	[toolPanel addSubview:labCycles];
	[self.view addSubview:toolPanel];
	
	//---------------------------------------------------
	// 3. <null>
	//---------------------------------------------------
	
	//---------------------------------------------------
	// 4. <null>
	//---------------------------------------------------
	
	//---------------------------------------------------
	// 6. Keyboard Show Button
	//---------------------------------------------------
	btnShowKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(190,0,44,25)];
	[btnShowKeyboard setImage:[UIImage imageNamed:@"kbd"] forState:UIControlStateNormal];
	[btnShowKeyboard addTarget:self action:@selector(togglePCKeyboard)
			  forControlEvents:UIControlEventTouchUpInside];
	[toolPanel addSubview:btnShowKeyboard];
	
	//---------------------------------------------------
	// 7. Banner at the top
	//---------------------------------------------------
	banner = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,44)];
	banner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	banner.backgroundColor = [UIColor clearColor];
	banner.text = @"Quit Game First";
	banner.textColor = [UIColor whiteColor];
	banner.textAlignment = UITextAlignmentCenter;
	banner.alpha = 0;
	[self.view addSubview:banner];
	
	//---------------------------------------------------
	// 8. Navigation Bar Show Button
	//---------------------------------------------------
#ifdef IDOS
	if (!autoExit)
	{
		UIButton *btnTop = [[[UIButton alloc] initWithFrame:CGRectMake(0,0,320,30)] autorelease];
		btnTop.backgroundColor=[UIColor clearColor];
		btnTop.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[btnTop addTarget:self action:@selector(showNavigationBar) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:btnTop];
	}
#endif
	
	//---------------------------------------------------
	// 9. Fullscreen Panel
	//---------------------------------------------------
	fullscreenPanel = [[FloatPanel alloc] initWithFrame:CGRectMake(0,0,480,32)];
	UIButton *btnExitFS = [[UIButton alloc] initWithFrame:CGRectMake(0,0,48,24)];
	btnExitFS.center=CGPointMake(44, 13);
	[btnExitFS setImage:[UIImage imageNamed:@"exitfull"] forState:UIControlStateNormal];
	[btnExitFS addTarget:self action:@selector(toggleScreenSize) forControlEvents:UIControlEventTouchUpInside];
	[fullscreenPanel.contentView addSubview:btnExitFS];
	[btnExitFS release];
	
	
	// Create the button larger than the image, so we have a bigger clickable area,
	// while visually takes smaller place
	btnDPadSwitch = [[[UIButton alloc] initWithFrame:CGRectMake(viewRect.size.width/2-38,viewRect.size.height-25,76,25)] autorelease];
	UIImageView *imgTmp = [[[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 72, 16)] autorelease];
	imgTmp.image = [UIImage imageNamed:@"switch"];
	[btnDPadSwitch addSubview:imgTmp];
	slider = [[UIImageView alloc] initWithFrame:CGRectMake(21,7,17,8)];
	slider.image = [UIImage imageNamed:@"switchbutton"];
	[btnDPadSwitch addSubview:slider];
	[btnDPadSwitch addTarget:self action:@selector(onGamePadModeSwitch:)
		forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnDPadSwitch];
}

- (void)toggleInputSource:(id)sender
{
	UIButton *btn = (UIButton*)sender;
	InputSourceType type = (InputSourceType)[btn tag];
	if ([self isInputSourceActive:type]) {
		[self removeInputSource:type];
	} else {
		[self addInputSourceExclusively:type];
	}
	[self refreshFullscreenPanel];
}

- (void)refreshFullscreenPanel
{
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:16];
	
	UIImageView *cpuWindow = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,48,24)] autorelease];
	cpuWindow.image = [UIImage imageNamed:@"cpuwindow"];
	
	if (labCycles2 == nil)
	{
		labCycles2 = [[UILabel alloc] initWithFrame:CGRectMake(1,8,43,12)];
		labCycles2.backgroundColor = [UIColor clearColor];
		labCycles2.textColor=[UIColor colorWithRed:74/255.0 green:1 blue:55/255.0 alpha:1];
		labCycles2.font=[UIFont fontWithName:@"DBLCDTempBlack" size:12];
		labCycles2.text=[self currentCycles];
		labCycles2.textAlignment=UITextAlignmentCenter;
		labCycles2.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
		fsIndicator2 = [FrameskipIndicator alloc];
		fsIndicator2 = [fsIndicator2 initWithFrame:CGRectMake(labCycles2.frame.size.width-8,2,4,labCycles2.frame.size.height-4)
											 style:FrameskipIndicatorStyleVertical];
		fsIndicator2.count = [self currentFrameskip];
		[labCycles2 addSubview:fsIndicator2];
	}
	[cpuWindow addSubview:labCycles2];
	[items addObject:cpuWindow];
	
	for (int i = 0; i < NUM_BUTTON_INFO; i++) {
		if ([self isInputSourceEnabled:toggleButtonInfo[i].type]) {
			UIButton *btn = [[[UIButton alloc] initWithFrame:CGRectMake(0,0,48,24)] autorelease];
			NSString *on = [NSString stringWithUTF8String:toggleButtonInfo[i].onImageName];
			NSString *off = [NSString stringWithUTF8String:toggleButtonInfo[i].offImageName];
			BOOL active = [self isInputSourceActive:toggleButtonInfo[i].type];
			[btn setImage:[UIImage imageNamed:active?on:off] forState:UIControlStateNormal];
			[btn setImage:[UIImage imageNamed:on] forState:UIControlStateHighlighted];
			[btn setTag:toggleButtonInfo[i].type];
			[btn addTarget:self action:@selector(toggleInputSource:) forControlEvents:UIControlEventTouchUpInside];
			[items addObject:btn];
		}
	}
	
	UIButton *btnOption = [[[UIButton alloc] initWithFrame:CGRectMake(380,0,48,24)] autorelease];
	[btnOption setImage:[UIImage imageNamed:@"options"] forState:UIControlStateNormal];
	[btnOption addTarget:self action:@selector(showOption) forControlEvents:UIControlEventTouchUpInside];
	[items addObject:btnOption];
	
	[fullscreenPanel setItems:items];
}

- (void)hideNavigationBar
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)showNavigationBar
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNavigationBar) object:nil];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[self performSelector:@selector(hideNavigationBar) withObject:nil afterDelay:3];
}

-(void)updateFrameskip:(NSNumber*)skip
{
	fsIndicator.count=[skip intValue];
	fsIndicator2.count=[skip intValue];
	if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
		self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[fullscreenPanel showContent];
	}
}

-(void)updateCpuCycles:(NSString*)title
{
	labCycles.text=title;
	labCycles2.text=title;
	if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
		self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[fullscreenPanel showContent];
	}
}

-(float)floatAlpha
{
	NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
	return 1-[defs floatForKey:kTransparency];
}


-(void)updateAlpha
{
	float a = [self floatAlpha];
	kbd.alpha = a;
	if ([self isLandscape])
	{
		gamepad.alpha=a;
		gamepad.dpadMovable = DEFS_GET_BOOL(kDPadMovable);
	}
	numpad.alpha=a;
	btnMouseLeft.alpha=a;
	btnMouseRight.alpha=a;
}

- (void)createMouseButtons
{
	// Left Mouse Button
	btnMouseLeft = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-48,160,48,80)];
	[btnMouseLeft setTitle:@"L" forState:UIControlStateNormal];
	[btnMouseLeft setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	[btnMouseLeft setBackgroundImage:[UIImage imageNamed:@"longbutton"]
							forState:UIControlStateNormal];
	[btnMouseLeft addTarget:self
					 action:@selector(onMouseLeftDown)
		   forControlEvents:UIControlEventTouchDown];
	[btnMouseLeft addTarget:self
					 action:@selector(onMouseLeftUp)
		   forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnMouseLeft];
	
	// Right Mouse Button
	btnMouseRight = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-48,80,48,80)];
	[btnMouseRight setTitle:@"R" forState:UIControlStateNormal];
	[btnMouseRight setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	[btnMouseRight setBackgroundImage:[UIImage imageNamed:@"longbutton"]
							 forState:UIControlStateNormal];
	[btnMouseRight addTarget:self
					  action:@selector(onMouseRightDown)
			forControlEvents:UIControlEventTouchDown];
	[btnMouseRight addTarget:self
					  action:@selector(onMouseRightUp)
			forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnMouseRight];
	
	// Transparency
	btnMouseLeft.alpha=[self floatAlpha];
	btnMouseRight.alpha=[self floatAlpha];
}


- (void)createNumpad
{
	
	numpad = [[KeyboardView alloc] initWithType:KeyboardTypeNumPad frame:CGRectMake(self.view.bounds.size.width-160,120,160,200)];
	numpad.alpha = [self floatAlpha];
	[self.view addSubview:numpad];
	
	CGPoint ptOld = numpad.center;
	numpad.center = CGPointMake(ptOld.x, ptOld.y+numpad.frame.size.height);
	[UIView beginAnimations:nil context:NULL];
	numpad.center = ptOld;
	[UIView commitAnimations];
}

- (void)togglePCKeyboard
{
	if (kbd != nil)
	{
		[kbd removeFromSuperview];
		[kbd release];
		kbd = nil;
	}
	else
	{
		[self createPCKeyboard];
	}
}

- (void)createPCKeyboard
{
	if (kbd != nil)
	{
		[kbd removeFromSuperview];
		[kbd release];
		kbd = nil;
	}
	CGRect rect;
	if ([self isPortrait]) {
		rect = CGRectMake(0, 265, self.view.bounds.size.width, self.view.bounds.size.height - 265);
	} else {
		rect = CGRectMake(0, self.view.bounds.size.height-175, self.view.bounds.size.width, 175);
	}
	kbd = [[KeyboardView alloc] initWithType:[self isPortrait]?KeyboardTypePortrait: KeyboardTypeLandscape
									   frame:rect];
	if ([self isLandscape]) {
		kbd.alpha = [self floatAlpha];
	} else {
		kbd.backgroundColor = [[ColorTheme defaultTheme] colorByName:@"keyboard-background"];
	}
	
	[self.view addSubview:kbd];
}

- (GamePadView*)createGamepadHelper:(GamePadMode)mod
{
	GamePadView * gpad = nil;
	
	if (configPath == nil) return nil;
	
	CGRect rect = self.view.bounds;
	float maxSize = MAX(rect.size.width, rect.size.height);
	NSString *section = [NSString stringWithFormat:@"[gamepad.%@.%@]",
		maxSize > 480 ? @"iphone5" : @"iphone",
		[self isPortrait] ? @"portrait" : @"landscape"];
	
	NSString *ui_cfg = [ConfigManager uiConfigFile];
	if (ui_cfg != nil)
	{
		gpad = [[GamePadView alloc] initWithConfig:ui_cfg section:section];
		gpad.mode = mod;
		DEBUGLOG(@"mode %d  rect: %f %f %f %f", gpad.mode,
				 gpad.frame.origin.x, gpad.frame.origin.y,
				 gpad.frame.size.width, gpad.frame.size.height);
		if ([self isPortrait])
		{
			[self.view insertSubview:gpad belowSubview:toolPanel];
		}
		else
		{
			gpad.dpadMovable = DEFS_GET_INT(kDPadMovable);
			[self.view insertSubview:gpad belowSubview:fullscreenPanel];
		}
	}
	return gpad;
}

- (void)createJoystick
{
	if (joystick != nil) {
		[joystick removeFromSuperview];
		[joystick release];
		joystick = nil;
	}
	joystick = [self createGamepadHelper:GamePadJoystick];
}

- (void)createGamepad
{
	if (gamepad != nil) {
		[gamepad removeFromSuperview];
		[gamepad release];
		gamepad = nil;
	}
	gamepad = [self createGamepadHelper:GamePadDefault];
}

- (void)updateBackground:(UIInterfaceOrientation)interfaceOrientation
{
	UIImage *img;
	if (interfaceOrientation==UIInterfaceOrientationPortrait||
		interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
	{
		// img = [UIImage imageNamed:@"iphone-portrait.jpg"];
		// [(UIImageView*)self.view setImage:img];
	} else {
		
		// [(UIImageView*)self.view setImage:nil];
	}
}

- (void)updateBackground
{
	[self updateBackground:self.interfaceOrientation];
}

// Here is where the UI is defined. We decide what should be shown
// and where to show it.
- (void)updateUI
{
	if ([self isPortrait])
	{
		toolPanel.alpha=1;
		[self removeInputSource:InputSource_PCKeyboard];
		[self createGamepad];
		[fullscreenPanel removeFromSuperview];
	}
	else
	{
		if (self.view != fullscreenPanel.superview)
		{
			CGRect rc = fullscreenPanel.frame;
			rc.origin.x = (self.view.bounds.size.width-rc.size.width)/2;
			fullscreenPanel.frame = rc;
			[self.view addSubview:fullscreenPanel];
			[fullscreenPanel showContent];
		}
		toolPanel.alpha=0;
		[self refreshFullscreenPanel];
	}
	[self onResize:screenView.bounds.size];
	[self updateBackground];
	[self updateAlpha];
}

- (void)toggleScreenSize
{
	useOriginalScreenSize = !useOriginalScreenSize;
	[self updateUI];
}

- (void)onGamePadModeSwitch:(id)btn
{
	mode = (mode == GamePadDefault ? GamePadJoystick : GamePadDefault);
	gamepad.mode = mode;
	
	[UIView beginAnimations:nil context:nil];
	
	if (mode == GamePadDefault)
	{
		slider.frame = CGRectMake(21,7,17,8);
	}
	else
	{
		slider.frame = CGRectMake(40,7,17,8);
	}
	
	[UIView commitAnimations];
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	mode = GamePadDefault;
	[self initUI];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateUI];
	
#ifdef IDOS
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait||
		self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		if (!autoExit)
		{
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNavigationBar) object:nil];
			[self.navigationController setNavigationBarHidden:NO animated:YES];
			[self performSelector:@selector(hideNavigationBar) withObject:nil afterDelay:1];
		}
	}
#else
	[self hideNavigationBar];
#endif
}

-(void)viewWillDisappear:(BOOL)animated
{
#ifdef IDOS
	if (!autoExit)
	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNavigationBar) object:nil];
	}
#endif
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// Do a clean rotate animation
	if ([self isLandscape] && ISPORTRAIT(toInterfaceOrientation))
	{
		[fullscreenPanel hideContent];
		[self removeInputSource:InputSource_NumPad];
		[self removeInputSource:InputSource_MouseButtons];
		[self removeInputSource:InputSource_PianoKeyboard];
	}
	[self removeInputSource:InputSource_PCKeyboard];
	[self removeInputSource:InputSource_GamePad];
	[self removeInputSource:InputSource_Joystick];
	toolPanel.alpha=0;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self updateUI];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return YES;
}

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

- (void)dealloc {
	[banner release];
	[labCycles release];
	[labCycles2 release];
	[fsIndicator release];
	[fsIndicator2 release];
	[toolPanel release];
	[btnShowKeyboard release];
	[slider release];
	[fullscreenPanel release];
	[btnDPadSwitch release];
	[super dealloc];
}

/*
 * Handle dos screen resize.
 */
-(void)onResize:(CGSize)sizeNew
{
	CGRect viewRect = self.view.bounds;
	
	screenView.bounds = CGRectMake(0, 0, sizeNew.width, sizeNew.height);
	int maxWidth, maxHeight;
	float scalex, scaley;
	CGPoint ptCenter;
	
	if ([self isPortrait])
	{
		maxWidth = 320;
		maxHeight = 240;
		ptCenter = CGPointMake(viewRect.size.width/2, 120);
	}
	else
	{
		if (useOriginalScreenSize)
		{
			maxWidth = 320;
			maxHeight= 240;
			ptCenter = CGPointMake(viewRect.size.width/2, 120);
		}
		else
		{
			maxWidth = viewRect.size.width;
			maxHeight= viewRect.size.height;
			ptCenter = CGPointMake(viewRect.size.width/2, viewRect.size.height/2);
		}
	}
	
	scalex = maxWidth / sizeNew.width;
	scaley = maxHeight / sizeNew.height;
	
	CGAffineTransform t = CGAffineTransformIdentity;
	t = CGAffineTransformScale(t, scalex, scaley);
	screenView.transform = t;
	screenView.center=ptCenter;
}

@end
