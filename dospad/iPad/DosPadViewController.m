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

#import "DosPadViewController.h"
#import "FileSystemObject.h"
#include <assert.h>
#include <string.h>
#import "Common.h"
#import "CommandListView.h"

#include "SDL.h"

#define TAG_CMD 1
#define TAG_INPUT 2

static struct {
    InputSourceType type;
    const char *onImageName;
    const char *offImageName;
} toggleButtonInfo [] = {
    {InputSource_PCKeyboard, "modekeyon~ipad.png", "modekeyoff~ipad.png"},
    {InputSource_MouseButtons, "mouseon~ipad.png", "mouseoff~ipad.png"},
    {InputSource_GamePad, "modegamepadpressed~ipad.png", "modegamepad~ipad.png"},
    {InputSource_Joystick, "modejoypressed~ipad.png", "modejoy~ipad.png"},
    {InputSource_PianoKeyboard, "modepianopressed~ipad.png", "modepiano~ipad.png"},
};
#define NUM_BUTTON_INFO (sizeof(toggleButtonInfo)/sizeof(toggleButtonInfo[0]))

@interface DosPadViewController()
{
    UIImageView *baseView;
}

@end

@implementation DosPadViewController

- (BOOL)isFullscreen
{
    return [self isLandscape];
}

- (void)initView
{
    //---------------------------------------------------
    // 1. Create View
    //---------------------------------------------------
    baseView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,768,1024)];
    baseView.contentMode = UIViewContentModeCenter;
    baseView.userInteractionEnabled = YES;
    [self.view addSubview:baseView];
    self.view.backgroundColor = [UIColor blackColor];
    baseView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    baseView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin;
    //---------------------------------------------------
    // 2. Create Cycles and Frameskip Indicator
    //---------------------------------------------------    
    labCycles = [[UILabel alloc] initWithFrame:CGRectMake(521,597,86,37)];
    labCycles.backgroundColor = [UIColor clearColor];
    labCycles.textColor=[UIColor colorWithRed:74/255.0 green:1 blue:55/255.0 alpha:1];
    labCycles.text = [self currentCycles];
    labCycles.textAlignment = NSTextAlignmentCenter;
    labCycles.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
    labCycles.font=[UIFont fontWithName:@"DBLCDTempBlack" size:30];
    fsIndicator = [[FrameskipIndicator alloc] initWithFrame:CGRectMake(0,labCycles.frame.size.height-4,labCycles.frame.size.width, 4)
                                                      style:FrameskipIndicatorStyleHorizontal];
    fsIndicator.count = [self currentFrameskip];
    [labCycles addSubview:fsIndicator];
    [baseView addSubview:labCycles];
    
    //---------------------------------------------------
    // 3. Create Keyboard
    //---------------------------------------------------     
    keyboard = [[KeyboardView alloc] initWithType:KeyboardTypePortrait
                                            frame:CGRectMake(14,648,740,360)];
    [baseView addSubview:keyboard];
    
    //---------------------------------------------------
    // 4. Create Slider
    //---------------------------------------------------    
    sliderInput=[[SliderView alloc] initWithFrame:CGRectMake(405,967,146,32)];
    [sliderInput setActionOnSliderChange:@selector(onSliderChange) target:self];
    [baseView addSubview:sliderInput];
    
    //---------------------------------------------------
    // 5. Create Mouse Buttons
    //---------------------------------------------------    
    btnMouseLeftP=[[UIButton alloc] initWithFrame:CGRectMake(735, 310, 23, 89)];
    btnMouseRightP=[[UIButton alloc] initWithFrame:CGRectMake(735, 209, 23, 89)];
    [btnMouseLeftP addTarget:self action:@selector(onMouseLeftDown) forControlEvents:UIControlEventTouchDown];
    [btnMouseLeftP addTarget:self action:@selector(onMouseLeftUp) forControlEvents:UIControlEventTouchUpInside];
    [btnMouseRightP addTarget:self action:@selector(onMouseRightDown) forControlEvents:UIControlEventTouchDown];
    [btnMouseRightP addTarget:self action:@selector(onMouseRightUp) forControlEvents:UIControlEventTouchUpInside];    
    [baseView addSubview:btnMouseLeftP];
    [baseView addSubview:btnMouseRightP];
    
    
    //---------------------------------------------------
    // 7. Create Option Button
    //---------------------------------------------------    
    btnOption = [[UIButton alloc] initWithFrame:CGRectMake(632,592,79,46)];
    [btnOption addTarget:self action:@selector(showOption:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:btnOption];
    
    //---------------------------------------------------
    // 8. Create Command List Button
    //---------------------------------------------------    
    UIButton *btnShowCommands = [[UIButton alloc] initWithFrame:CGRectMake(69, 581, 85, 70)];
    [btnShowCommands addTarget:self
                        action:@selector(showCommandList)
              forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:btnShowCommands];
    
    //---------------------------------------------------
    // 9. Create back Button
    //---------------------------------------------------  
#ifdef IDOS
    if (!autoExit)
    {
        btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0,0,140,44)];
        [btnBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [baseView addSubview:btnBack];
    }
#endif
    
    //---------------------------------------------------
    // 10. Create light of input controls
    //---------------------------------------------------    
    gamepadLight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"light"]];
    joystiqLight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"light"]];
    gamepadLight.frame=CGRectMake(236,976,20,14);
    joystiqLight.frame=CGRectMake(328,976,20,14);
    gamepadLight.alpha=0;
    joystiqLight.alpha=0;
    [baseView addSubview:gamepadLight];
    [baseView addSubview:joystiqLight];
    
    //---------------------------------------------------
    // 11. Portrait GamePad/Joystick switch
    //---------------------------------------------------   
    
    UIButton *btnToGamePad = [[UIButton alloc] initWithFrame:CGRectMake(237,968,72,34)];
    [btnToGamePad addTarget:self
                     action:@selector(toggleGamePad)
           forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:btnToGamePad];
    
    UIButton *btnToJoy = [[UIButton alloc] initWithFrame:CGRectMake(326,968,72,34)];
    [btnToJoy addTarget:self
                     action:@selector(toggleJoystick)
           forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:btnToJoy];
    
    
    //---------------------------------------------------
    // 12. Fullscreen Panel
    //---------------------------------------------------    
    fullscreenPanel = [[FloatPanel alloc] initWithFrame:CGRectMake(0,0,700,47)];
    UIButton *btnExitFS = [[UIButton alloc] initWithFrame:CGRectMake(0,0,72,36)];
    btnExitFS.center=CGPointMake(63, 18);
    [btnExitFS setImage:[UIImage imageNamed:@"exitfull~ipad"] forState:UIControlStateNormal];
    [btnExitFS addTarget:self action:@selector(toggleScreenSize) forControlEvents:UIControlEventTouchUpInside];
    [fullscreenPanel.contentView addSubview:btnExitFS];
}

- (void)toggleGamePad
{
    sliderInput.position = 0.5;
    [self onSliderChange];
}
- (void)toggleJoystick
{
    sliderInput.position = 1.0;
    [self onSliderChange];
}


- (void)toggleInputSource:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    InputSourceType type = (int)[btn tag];
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
    
    UIImageView *cpuWindow = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,72,36)];
    cpuWindow.image = [UIImage imageNamed:@"cpuwindow.png"];
    
    if (labCycles2 == nil)
    {
        labCycles2 = [[UILabel alloc] initWithFrame:CGRectMake(2,11,64,18)];
        labCycles2.backgroundColor = [UIColor clearColor];
        labCycles2.textColor=[UIColor colorWithRed:74/255.0 green:1 blue:55/255.0 alpha:1];
        labCycles2.font=[UIFont fontWithName:@"DBLCDTempBlack" size:17];
        labCycles2.text=[self currentCycles];
        labCycles2.textAlignment = NSTextAlignmentCenter;
        labCycles2.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
        fsIndicator2 = [FrameskipIndicator alloc];
        fsIndicator2 = [fsIndicator2 initWithFrame:CGRectMake(labCycles2.frame.size.width-8,0,8,labCycles2.frame.size.height-4)
                                             style:FrameskipIndicatorStyleVertical];
        fsIndicator2.count = [self currentFrameskip];
        [labCycles2 addSubview:fsIndicator2];
    }
    [cpuWindow addSubview:labCycles2];
    [items addObject:cpuWindow];
    
    for (int i = 0; i < NUM_BUTTON_INFO; i++) {
		if ([self isInputSourceEnabled:toggleButtonInfo[i].type]) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,72,36)];
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
    
    UIButton *btnOpt = [[UIButton alloc] initWithFrame:CGRectMake(0,0,72,36)];
    [btnOpt setImage:[UIImage imageNamed:@"options.png"] forState:UIControlStateNormal];
    [btnOpt addTarget:self action:@selector(showOption:) forControlEvents:UIControlEventTouchUpInside];
    [items addObject:btnOpt];

    // Remap controls button
    UIButton *btnRemap = [[UIButton alloc] initWithFrame:CGRectMake(0,0,72,36)];
    [btnRemap setTitle:@"R" forState:UIControlStateNormal];
    [btnRemap addTarget:self action:@selector(openMfiMapper:) forControlEvents:UIControlEventTouchUpInside];
    [items addObject:btnRemap];
    
    [fullscreenPanel setItems:items];
}


- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateFrameskip:(NSNumber*)skip
{
    fsIndicator.count=[skip intValue];
    fsIndicator2.count=[skip intValue];
    if ([self isFullscreen])
    {
        [fullscreenPanel showContent];
    }
}

- (void)updateCpuCycles:(NSString*)title
{
    labCycles.text=title;
    labCycles2.text=title;
    if ([self isFullscreen])
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
    if ([self isFullscreen])
    {
        int a = [self floatAlpha];
        kbd.alpha = a;
        gamepad.alpha = a;
        joystick.alpha = a;
        btnMouseLeft.alpha= a;
        btnMouseRight.alpha = a;
        gamepad.dpadMovable = DEFS_GET_INT(kDPadMovable);
        joystick.dpadMovable = DEFS_GET_INT(kDPadMovable);
    }
}

- (void)createPCKeyboard
{
    CGFloat x = (self.view.frame.size.width - 1024)/2;
    kbd = [[KeyboardView alloc] initWithType:KeyboardTypeLandscape
        frame:CGRectMake(x,self.view.bounds.size.height-250,1024,250)];
    kbd.alpha = [self floatAlpha];
    [self.view addSubview:kbd];
    CGPoint ptOld = kbd.center;
    kbd.center = CGPointMake(ptOld.x, ptOld.y+kbd.frame.size.height);
    [UIView beginAnimations:nil context:NULL];
    kbd.center = ptOld;
    [UIView commitAnimations];
}

- (void)createMouseButtons
{
    CGFloat x = self.view.frame.size.width - 44;
    CGFloat y = self.view.frame.size.height - (768-460);
    btnMouseRight = [[UIButton alloc] initWithFrame:CGRectMake(x,y,48,90)];
    btnMouseLeft = [[UIButton alloc] initWithFrame:CGRectMake(x,y+90,48,90)];
    [btnMouseLeft setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnMouseLeft setTitle:@"L" forState:UIControlStateNormal];
    [btnMouseLeft setBackgroundImage:[UIImage imageNamed:@"longbutton"] 
                           forState:UIControlStateNormal];
    [btnMouseLeft addTarget:self
                    action:@selector(onMouseLeftDown)
          forControlEvents:UIControlEventTouchDown];
    [btnMouseLeft addTarget:self
                    action:@selector(onMouseLeftUp)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnMouseLeft];
    [btnMouseRight setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnMouseRight setTitle:@"R" forState:UIControlStateNormal];
    [btnMouseRight setBackgroundImage:[UIImage imageNamed:@"longbutton"] 
                            forState:UIControlStateNormal];
    [btnMouseRight addTarget:self
                     action:@selector(onMouseRightDown)
           forControlEvents:UIControlEventTouchDown];
    [btnMouseRight addTarget:self
                     action:@selector(onMouseRightUp)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnMouseRight];
    btnMouseLeft.alpha=[self floatAlpha];
    btnMouseRight.alpha=[self floatAlpha];   
}

- (GamePadView*)createGamepadHelper:(GamePadMode)mod
{    
    GamePadView *gpad = nil;
    
    //if (configPath == nil) return nil;

	BOOL isPortrait = [self isPortrait];
    NSString *section = (isPortrait ? @"[gamepad.ipad.portrait]" : @"[gamepad.ipad.landscape]");
    NSString *ui_cfg = [[DOSPadEmulator sharedInstance] uiConfigFile];

    gpad = [[GamePadView alloc] initWithConfig:ui_cfg section:section];
	
    // In portrait mode, we need to insert two background images
    if (isPortrait)
    {
        UIImageView *left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipadleftside"]];
        UIImageView *right = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipadrightside"]];
		left.frame = CGRectMake(1,19,280,378);
		right.frame = CGRectMake(441,30,327,315);
		gpad.backgroundColor=[UIColor clearColor];
		[gpad insertSubview:left atIndex:0];
		[gpad insertSubview:right atIndex:0];
    }
	

    gpad.mode = mod;    
    if (isPortrait)
    {
		// Make adjustment for screen sizes that are not 768x1024 or 1024x768
		// Shift all down towards the bottom,
		// and pull right part towards the right edge.
		CGPoint leftPartOffset = CGPointMake(0, self.view.bounds.size.height - 1024);
		CGPoint rightPartOffset = CGPointMake(self.view.bounds.size.width - 768,
			self.view.bounds.size.height - 1024);
		for (UIView *v in gpad.subviews)
		{
			if (v.center.x < (isPortrait?768:1024)/2) // left
			{
				v.frame = CGRectOffset(v.frame, leftPartOffset.x, leftPartOffset.y);
			}
			else
			{
				v.frame = CGRectOffset(v.frame, rightPartOffset.x, rightPartOffset.y);
			}
		}

        [self.view addSubview:gpad];
    }
    else
    {
    	CGFloat vw = self.view.bounds.size.width;
		CGRect r = gpad.frame;
		float offset = vw - r.size.width;
		for (UIView *v in gpad.subviews) {
			if (v.center.x > r.size.width/2)
				v.center = CGPointMake(v.center.x+offset, v.center.y);
		}
		r.size.width = vw;
		gpad.frame = r;
    	
        gpad.dpadMovable = DEFS_GET_INT(kDPadMovable);
        gpad.alpha = [self floatAlpha];
        [self.view insertSubview:gpad belowSubview:fullscreenPanel];
    }
    return gpad;
}

- (void)createGamepad
{
    NSAssert(gamepad == nil, @"gamepad should not exist");
    gamepad = [self createGamepadHelper:GamePadDefault];
}

- (void)createJoystick
{
    NSAssert(joystick == nil, @"joystick should not exist");
    joystick = [self createGamepadHelper:GamePadJoystick];
}

- (void)updateBackground:(UIInterfaceOrientation)interfaceOrientation
{
    UIImage *img;
    if (interfaceOrientation==UIInterfaceOrientationPortrait||
        interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) 
    {
#ifdef IDOS
        img = [UIImage imageNamed:@"idos-portrait.jpg"]; 
#else
        img = [UIImage imageNamed:@"dospadportrait.jpg"];        
#endif
        [baseView setImage:img];
    } else {
        [baseView setImage:nil];
    }
}

- (void)updateBackground
{
    [self updateBackground:self.interfaceOrientation];
}

- (void)updateScreen
{
	CGFloat vw = self.view.bounds.size.width;
	CGFloat vh = self.view.bounds.size.height;

    if ([self isFullscreen])
        [self putScreen:CGRectMake(0, 0, vw, shouldShrinkScreen ? vh-260 : vh)];
	else
		[self putScreen:CGRectMake(64, 78, 640, 480)];
}

- (void)updateUI
{
	CGFloat vw = self.view.bounds.size.width;
	CGFloat vh = self.view.bounds.size.height;

    [self updateBackground];    
    if ([self isFullscreen]) 
    {
        [self.view insertSubview:self.screenView atIndex:0];
        baseView.alpha = 0;
        keyboard.alpha=0;
        sliderInput.alpha=0;
        btnOption.alpha=0;
        labCycles.alpha=0;
        btnMouseLeftP.alpha = 0;
        btnMouseRightP.alpha = 0;
		btnShowCommands.alpha = 0;
        [self putScreen:CGRectMake(0, 0, vw, shouldShrinkScreen ? vh-260 : vh)];
        if (fullscreenPanel.superview != self.view)
        {
            fullscreenPanel.center = CGPointMake(self.view.frame.size.width/2, fullscreenPanel.frame.size.height/2);
            [self.view addSubview:fullscreenPanel];
            [fullscreenPanel showContent];
        }
        piano.center = CGPointMake(vw/2, vh-110);
        [self refreshFullscreenPanel];
    }
    else 
    {
        [baseView insertSubview:self.screenView atIndex:0];
		baseView.alpha = 1;
		// Scaling baseView to fill self.view as much as possible
//		if (baseView.bounds.size.width != self.view.bounds.size.width ||
//			baseView.bounds.size.height != self.view.bounds.size.height)
		{
			float scaleX = self.view.bounds.size.width/baseView.bounds.size.width;
			float scaleY = self.view.bounds.size.height/baseView.bounds.size.height;
			float scale = MIN(scaleX, scaleY);
			baseView.transform = CGAffineTransformMakeScale(scaleX, scaleY);
			baseView.center = CGPointMake(self.view.bounds.size.width/2,
				self.view.bounds.size.height/2);
		}
		
		[self putScreen:CGRectMake(64, 78, 640, 480)];
        
        btnShowCommands.alpha = 1;
        btnOption.alpha=1;
        labCycles.alpha=1;
        sliderInput.alpha=1;
        btnMouseRightP.alpha = 1;
        btnMouseLeftP.alpha = 1;
        keyboard.alpha=1;
        [fullscreenPanel removeFromSuperview];
        piano.center = CGPointMake(vw/2, 800);
    }

    if (gamepad != nil)
    {
        [self addInputSource:InputSource_GamePad];
    }
    if (joystick != nil)
    {
        [self addInputSource:InputSource_Joystick];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [baseView insertSubview:self.screenView atIndex:0];
}


- (void)toggleScreenSize
{
    shouldShrinkScreen = !shouldShrinkScreen;
    [self updateUI];
}


- (void)onSliderChange
{
    [self removeInputSource:InputSource_PianoKeyboard];
    if ( fabs(sliderInput.position-0) < fabs(sliderInput.position-0.5)) {
        sliderInput.position=0;
        [self removeInputSource:InputSource_GamePad];
        [self removeInputSource:InputSource_Joystick];
        gamepadLight.alpha=0;
        joystiqLight.alpha=0;
    } else if (fabs(sliderInput.position-1) > fabs(sliderInput.position-0.5)) {
        sliderInput.position=0.5;
        [self removeInputSource:InputSource_Joystick];
        joystiqLight.alpha=0;
        [self addInputSource:InputSource_GamePad];
        gamepadLight.alpha=1;
    } else {
        sliderInput.position=1;
        [self removeInputSource:InputSource_GamePad];
        gamepadLight.alpha=0;
        [self addInputSource:InputSource_Joystick];
        joystiqLight.alpha=1;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    labCycles.alpha = 0; // Too intrusive in animation
    if ([self isLandscape] && ISPORTRAIT(toInterfaceOrientation))
    {
        // When rotating from landscape to portrait
        // we should remove the overlay controls except for gamepad
        [fullscreenPanel hideContent];
        [self removeInputSource:InputSource_PCKeyboard];
        [self removeInputSource:InputSource_MouseButtons];
    }
    gamepad.alpha = 0;
    joystick.alpha = 0;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateUI];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didFloatingView:(FloatingView *)fltView
{
    if ([fltView tag] == TAG_CMD) {
        CommandListView *v = (CommandListView*) fltView;
        if (v.selected) {
            DEBUGLOG(@"%@", v.selectedCommand);
            [self sendCommandToDOS:v.selectedCommand];
        }
    } else if ([fltView tag] == TAG_INPUT) {
        
    }
}

- (void)showCommandList
{
    CommandListView *v = [[CommandListView alloc] initWithParent:self.view];
    [v setTag:TAG_CMD];
    [v setDelegate:self];
    [v show];     
}

-(void) openMfiMapper:(id)sender {
    [super openMfiMapper:sender];
}


@end
