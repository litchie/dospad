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
#import "ModalViewController.h"
#import "CommandListView.h"

#include "SDL.h"

#define TAG_CMD 1
#define TAG_INPUT 2

@implementation DosPadViewController

- (BOOL)isFullscreen
{
    return [self isLandscape];
}

- (void)loadView
{
    //---------------------------------------------------
    // 1. Create View
    //---------------------------------------------------
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,1024)];
    self.view.backgroundColor = [UIColor blackColor];
    
    //---------------------------------------------------
    // 2. Create Cycles and Frameskip Indicator
    //---------------------------------------------------    
    labCycles = [[UILabel alloc] initWithFrame:CGRectMake(521,597,86,37)];
    labCycles.backgroundColor = [UIColor clearColor];
    labCycles.textColor=[UIColor colorWithRed:74/255.0 green:1 blue:55/255.0 alpha:1];
    labCycles.text = [self currentCycles];
    labCycles.textAlignment=UITextAlignmentCenter;
    labCycles.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
    labCycles.font=[UIFont fontWithName:@"DBLCDTempBlack" size:30];
    fsIndicator = [[FrameskipIndicator alloc] initWithFrame:CGRectMake(0,labCycles.frame.size.height-4,labCycles.frame.size.width, 4)
                                                      style:FrameskipIndicatorStyleHorizontal];
    fsIndicator.count = [self currentFrameskip];
    [labCycles addSubview:fsIndicator];
    [self.view addSubview:labCycles];
    
    //---------------------------------------------------
    // 3. Create Keyboard
    //---------------------------------------------------     
    keyboard = [[KeyboardView alloc] initWithType:KeyboardTypePortrait
                                            frame:CGRectMake(14,648,740,360)];
    [self.view addSubview:keyboard];
    
    //---------------------------------------------------
    // 4. Create Slider
    //---------------------------------------------------    
    sliderInput=[[SliderView alloc] initWithFrame:CGRectMake(405,967,146,32)];
    [sliderInput setActionOnSliderChange:@selector(onSliderChange) target:self];
    [self.view addSubview:sliderInput];
    
    //---------------------------------------------------
    // 5. Create Mouse Buttons
    //---------------------------------------------------    
    btnMouseLeft=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
    btnMouseRight=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [btnMouseLeft addTarget:self action:@selector(onMouseLeftDown) forControlEvents:UIControlEventTouchDown];
    [btnMouseLeft addTarget:self action:@selector(onMouseLeftUp) forControlEvents:UIControlEventTouchUpInside];
    [btnMouseRight addTarget:self action:@selector(onMouseRightDown) forControlEvents:UIControlEventTouchDown];
    [btnMouseRight addTarget:self action:@selector(onMouseRightUp) forControlEvents:UIControlEventTouchUpInside];    
    [self.view addSubview:btnMouseLeft];
    [self.view addSubview:btnMouseRight];
    
    //---------------------------------------------------
    // 6. Create Virtual keyboard
    //---------------------------------------------------    
    vk = [[VKView alloc] initWithFrame:CGRectMake(0,0,1,1)];
    vk.alpha=0;
    [self.view addSubview:vk];
    
    //---------------------------------------------------
    // 7. Create Option Button
    //---------------------------------------------------    
    btnOption = [[UIButton alloc] initWithFrame:CGRectMake(632,592,79,46)];
    [btnOption addTarget:self action:@selector(showOption) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnOption];
    
    //---------------------------------------------------
    // 8. Create Command List Button
    //---------------------------------------------------    
    UIButton *btnShowCommands = [[[UIButton alloc] initWithFrame:CGRectMake(69, 581, 85, 70)] autorelease];
    [btnShowCommands addTarget:self
                        action:@selector(showCommandList)
              forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnShowCommands];
    
    //---------------------------------------------------
    // 9. Create back Button
    //---------------------------------------------------  
#ifdef IDOS
    if (!autoExit)
    {
        btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0,0,140,44)];
        [btnBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnBack];
    }
#endif
    
    //---------------------------------------------------
    // 10. Create light of input controls
    //---------------------------------------------------    
    gamepadLight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"light.png"]];
    joystiqLight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"light.png"]];
    gamepadLight.frame=CGRectMake(236,976,20,14);
    joystiqLight.frame=CGRectMake(328,976,20,14);
    gamepadLight.alpha=0;
    joystiqLight.alpha=0;
    [self.view addSubview:gamepadLight];
    [self.view addSubview:joystiqLight];
    
    //---------------------------------------------------
    // 11. Portrait GamePad/Joystick switch
    //---------------------------------------------------   
    
    UIButton *btnToGamePad = [[UIButton alloc] initWithFrame:CGRectMake(237,968,72,34)];
    [btnToGamePad addTarget:self
                     action:@selector(toggleGamePad)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnToGamePad];
    [btnToGamePad release];
    
    UIButton *btnToJoy = [[UIButton alloc] initWithFrame:CGRectMake(326,968,72,34)];
    [btnToJoy addTarget:self
                     action:@selector(toggleJoystick)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnToJoy];
    
    [btnToJoy release];
    
    //---------------------------------------------------
    // 12. Fullscreen Panel
    //---------------------------------------------------    
    fullscreenPanel = [[FloatPanel alloc] initWithFrame:CGRectMake(0,0,700,47)];
    btnToggleGamePad = [[UIButton alloc] initWithFrame:CGRectMake(278,0,72,36)];
    btnToggleJoystiq = [[UIButton alloc] initWithFrame:CGRectMake(250,0,72,36)];
    btnToggleNumpad = [[UIButton alloc] initWithFrame:CGRectMake(250,0,72,36)];
    btnToggleKeyboard =  [[UIButton alloc] initWithFrame:CGRectMake(150,0,72,36)];
    btnToggleMouse =  [[UIButton alloc] initWithFrame:CGRectMake(150,0,72,36)];

    [btnToggleGamePad setImage:[UIImage imageNamed:@"modegamepad~ipad.png"] forState:UIControlStateNormal];
    [btnToggleGamePad setImage:[UIImage imageNamed:@"modegamepadpressed~ipad.png"] forState:UIControlStateHighlighted];
    [btnToggleJoystiq setImage:[UIImage imageNamed:@"modejoy~ipad.png"] forState:UIControlStateNormal];
    [btnToggleJoystiq setImage:[UIImage imageNamed:@"modejoypressed~ipad.png"] forState:UIControlStateHighlighted];
    [btnToggleNumpad setImage:[UIImage imageNamed:@"modenumpad~ipad.png"] forState:UIControlStateNormal];
    [btnToggleNumpad setImage:[UIImage imageNamed:@"modenumpadpressed~ipad.png"] forState:UIControlStateHighlighted];
    [btnToggleKeyboard setImage:[UIImage imageNamed:@"modekeyoff~ipad.png"] forState:UIControlStateNormal];
    [btnToggleKeyboard setImage:[UIImage imageNamed:@"modekeyon~ipad.png"] forState:UIControlStateHighlighted];
    [btnToggleMouse setImage:[UIImage imageNamed:@"mouseoff~ipad.png"] forState:UIControlStateNormal];
    [btnToggleMouse setImage:[UIImage imageNamed:@"mouseon~ipad.png"] forState:UIControlStateHighlighted];

    [btnToggleGamePad addTarget:self action:@selector(toggleGamePad) forControlEvents:UIControlEventTouchUpInside];
    [btnToggleJoystiq addTarget:self action:@selector(toggleJoystick) forControlEvents:UIControlEventTouchUpInside];
    [btnToggleKeyboard addTarget:self action:@selector(toggleOverlayKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [btnToggleMouse addTarget:self action:@selector(toggleMouse) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *cpuWindow = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,72,36)];
    cpuWindow.image = [UIImage imageNamed:@"cpuwindow.png"];
    
    labCycles2 = [[UILabel alloc] initWithFrame:CGRectMake(2,11,64,18)];
    labCycles2.backgroundColor = [UIColor clearColor];
    labCycles2.textColor=[UIColor colorWithRed:74/255.0 green:1 blue:55/255.0 alpha:1];
    labCycles2.font=[UIFont fontWithName:@"DBLCDTempBlack" size:17];
    labCycles2.text=[self currentCycles];
    labCycles2.textAlignment=UITextAlignmentCenter;
    labCycles2.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
    fsIndicator2 = [FrameskipIndicator alloc];
    fsIndicator2 = [fsIndicator2 initWithFrame:CGRectMake(labCycles2.frame.size.width-8,0,8,labCycles2.frame.size.height)
                                         style:FrameskipIndicatorStyleVertical];
    fsIndicator2.count = [self currentFrameskip];
    [labCycles2 addSubview:fsIndicator2];
    [cpuWindow addSubview:labCycles2];
    
    UIButton * btnOption2 = [[[UIButton alloc] initWithFrame:CGRectMake(0,0,72,36)] autorelease];
    [btnOption2 setImage:[UIImage imageNamed:@"options~ipad.png"] forState:UIControlStateNormal];
    [btnOption2 addTarget:self action:@selector(showOption) forControlEvents:UIControlEventTouchUpInside];

    [fullscreenPanel setItems:[NSArray arrayWithObjects:
                               cpuWindow,
                               btnToggleKeyboard, 
                               btnToggleMouse,
                               btnToggleGamePad,
                               btnToggleJoystiq,
                               //btnToggleNumpad,
                               btnOption2,  //Crash!!! iPad reboots..
                               nil]];
    
    UIButton *btnExitFS = [[UIButton alloc] initWithFrame:CGRectMake(0,0,72,36)];
    btnExitFS.center=CGPointMake(63, 18);
    [btnExitFS setImage:[UIImage imageNamed:@"exitfull~ipad.png"] forState:UIControlStateNormal];
    [btnExitFS addTarget:self action:@selector(toggleScreenSize) forControlEvents:UIControlEventTouchUpInside];
    [fullscreenPanel.contentView addSubview:btnExitFS];

    [btnExitFS release];
    [cpuWindow release];
    [btnToggleKeyboard release];
    [btnToggleGamePad release];
    [btnToggleJoystiq release];
    [btnToggleNumpad release];    
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
        overlayKeyboard.alpha = a;
        gamepad.alpha = a;
        fsMouseLeft.alpha= a;
        gamepad.dpadMovable = DEFS_GET_INT(kDPadMovable);
    }
}

- (void)removeOverlayKeyboard
{
    if (overlayKeyboard)
    {
        [overlayKeyboard removeFromSuperview];
        [overlayKeyboard release];
        overlayKeyboard = nil;
        [btnToggleKeyboard setImage:[UIImage imageNamed:@"modekeyoff~ipad.png"] forState:UIControlStateNormal];
    }
}


- (void)createOverlayKeyboard
{
    if (overlayKeyboard)
        [self removeOverlayKeyboard];

    overlayKeyboard = [[KeyboardView alloc] initWithType:KeyboardTypeLandscape
                                                   frame:CGRectMake(0,480,1024,288)];
    overlayKeyboard.alpha = [self floatAlpha];
    [self.view addSubview:overlayKeyboard];
    CGPoint ptOld = overlayKeyboard.center;
    overlayKeyboard.center = CGPointMake(ptOld.x, ptOld.y+overlayKeyboard.frame.size.height);
    [UIView beginAnimations:nil context:NULL];
    overlayKeyboard.center = ptOld;
    [UIView commitAnimations];
    [btnToggleKeyboard setImage:[UIImage imageNamed:@"modekeyon~ipad.png"] forState:UIControlStateNormal];
}


- (void)removeMouseButtons
{
    if (fsMouseLeft || fsMouseRight)
    {
        [fsMouseLeft removeFromSuperview];
        [fsMouseRight removeFromSuperview];
        [fsMouseLeft release];
        [fsMouseRight release];
        fsMouseLeft=nil;
        fsMouseRight=nil;
        [btnToggleMouse setImage:[UIImage imageNamed:@"mouseoff~ipad.png"] forState:UIControlStateNormal];
    }
}

- (void)createMouseButtons
{
    [self removeMouseButtons];
    
    fsMouseRight = [[UIButton alloc] initWithFrame:CGRectMake(980,460,48,90)];
    fsMouseLeft = [[UIButton alloc] initWithFrame:CGRectMake(980,550,48,90)];
    [fsMouseLeft setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [fsMouseLeft setTitle:@"L" forState:UIControlStateNormal];
    [fsMouseLeft setBackgroundImage:[UIImage imageNamed:@"longbutton.png"] 
                           forState:UIControlStateNormal];
    [fsMouseLeft addTarget:self
                    action:@selector(onMouseLeftDown)
          forControlEvents:UIControlEventTouchDown];
    [fsMouseLeft addTarget:self
                    action:@selector(onMouseLeftUp)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fsMouseLeft];
    [fsMouseRight setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [fsMouseRight setTitle:@"R" forState:UIControlStateNormal];
    [fsMouseRight setBackgroundImage:[UIImage imageNamed:@"longbutton.png"] 
                            forState:UIControlStateNormal];
    [fsMouseRight addTarget:self
                     action:@selector(onMouseRightDown)
           forControlEvents:UIControlEventTouchDown];
    [fsMouseRight addTarget:self
                     action:@selector(onMouseRightUp)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fsMouseRight];
    fsMouseLeft.alpha=[self floatAlpha];
    fsMouseRight.alpha=[self floatAlpha];   
    [btnToggleMouse setImage:[UIImage imageNamed:@"mouseon~ipad.png"] forState:UIControlStateNormal];
}


- (void)removeGamePad
{
    if (gamepad != nil)
    {
        [gamepad removeFromSuperview];
        [gamepad release];
        gamepad = nil;
        [btnToggleGamePad setImage:[UIImage imageNamed:@"modegamepad~ipad.png"] forState:UIControlStateNormal];
        [btnToggleJoystiq setImage:[UIImage imageNamed:@"modejoy~ipad.png"] forState:UIControlStateNormal];     
        sliderInput.position = 0;
    }
}


- (GamePadView*)createGamePad
{
    [self removeGamePad];
    
    if (configPath == nil) return nil;

    NSString *section = ([self isPortrait] ?
                         @"[gamepad.ipad.portrait]" : 
                         @"[gamepad.ipad.landscape]");
    
    NSString *ui_cfg = get_temporary_merged_file(configPath, get_default_config());

    gamepad = [[GamePadView alloc] initWithConfig:ui_cfg section:section];

    if (![self isFullscreen])
    {
        UIImageView *left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipadleftside.png"]];
        UIImageView *right = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipadrightside.png"]];
        left.frame = CGRectMake(1,19,280,378);
        right.frame = CGRectMake(441,30,327,315);
        gamepad.backgroundColor=[UIColor clearColor];
        [gamepad insertSubview:left atIndex:0];
        [gamepad insertSubview:right atIndex:0];
        [left release];
        [right release];
    }
    
    if (mode == GamePadDefault)
    {
        [btnToggleGamePad setImage:[UIImage imageNamed:@"modegamepadpressed~ipad.png"] 
                          forState:UIControlStateNormal];
        sliderInput.position = 0.5;
    }
    else
    {
        [btnToggleJoystiq setImage:[UIImage imageNamed:@"modejoypressed~ipad.png"]
                          forState:UIControlStateNormal];
        sliderInput.position = 1;
    }
    gamepad.mode = mode;    
    if ([self isFullscreen]) 
    {
        gamepad.dpadMovable = DEFS_GET_INT(kDPadMovable);
        gamepad.alpha = [self floatAlpha];
        [self.view insertSubview:gamepad belowSubview:fullscreenPanel];
    }
    else
    {
        [self.view addSubview:gamepad];
    }
    return gamepad;
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
        self.view.backgroundColor = [UIColor colorWithPatternImage:img];
    } else {
        self.view.backgroundColor = [UIColor blackColor];
    }
}

- (void)updateBackground
{
    [self updateBackground:self.interfaceOrientation];
}

-(void)updateUI
{
    float sh = self.screenView.bounds.size.height;
    float sw = self.screenView.bounds.size.width;
    float additionalScaleY = 1.0;
    if (sh / sw != 0.75 && DEFS_GET_INT(kForceAspect)) 
    {
        additionalScaleY = 0.75 / (sh/sw);
    } 
    [self updateBackground];    
    if ([self isFullscreen]) 
    {
        keyboard.alpha=0;
        sliderInput.alpha=0;
        btnOption.alpha=0;
        labCycles.alpha=0;
        btnMouseLeft.alpha = 0;
        btnMouseRight.alpha = 0;
        if (useOriginalScreenSize)
        {
            float maxWidth = 640;
            float maxHeight = 480;
            float sx = maxWidth/sw;
            float sy = maxHeight/sh;
            float scale = MIN(sx,sy);
            screenView.transform = CGAffineTransformMakeScale(scale,scale*additionalScaleY);
            screenView.center = CGPointMake(self.view.bounds.size.width/2, maxHeight/2);
        }
        else
        {
            float sx = self.view.bounds.size.width/sw;
            float sy = self.view.bounds.size.height/sh;
            float scale = MIN(sx,sy);
            screenView.transform = CGAffineTransformMakeScale(scale,scale*additionalScaleY);
            screenView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        }
        if (fullscreenPanel.superview != self.view)
        {
            fullscreenPanel.center = CGPointMake(self.view.frame.size.width/2, fullscreenPanel.frame.size.height/2);
            [self.view addSubview:fullscreenPanel];
            [fullscreenPanel showContent];
        }
    }
    else 
    {
        float vh = self.view.bounds.size.height;
        float kh = keyboard.bounds.size.height;
        float scale=1;
        if (sw < 640) { scale = 640.0f/sw; }
        screenView.transform=CGAffineTransformMakeScale(scale,scale*additionalScaleY);
        screenView.center=CGPointMake(384, 314);
            
        btnOption.alpha=1;
        labCycles.alpha=1;
        sliderInput.alpha=1;
        btnMouseRight.alpha = 1;
        btnMouseLeft.alpha = 1;
        keyboard.alpha=1;
        [fullscreenPanel removeFromSuperview];
    }

    if (gamepad != nil)
    {
        [self createGamePad];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateBackground];
    [self updateAlpha];
    [self onResize:self.screenView.bounds.size];
    
    [vk becomeFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    mode = GamePadDefault;
}

- (void)toggleOverlayKeyboard
{
    if (overlayKeyboard)
    {
        [self removeOverlayKeyboard];
    }
    else
    {
        [self removeGamePad];
        [self removeMouseButtons];
        [self createOverlayKeyboard];
    }
}

- (void)toggleJoystick
{
    if (gamepad == nil || gamepad.mode != GamePadJoystick)
    {
        [self removeMouseButtons];
        [self removeOverlayKeyboard];
        sliderInput.position=1;
        mode = GamePadJoystick;
        [self createGamePad];
        gamepadLight.alpha=0;
        joystiqLight.alpha=1;
    }
    else
    {
        sliderInput.position=0;
        [self removeGamePad];
        gamepadLight.alpha=0;
        joystiqLight.alpha=0;
    }
}

- (void)toggleGamePad
{
    if (gamepad == nil || gamepad.mode != GamePadDefault)
    {
        [self removeMouseButtons];
        [self removeOverlayKeyboard];
        mode = GamePadDefault;
        [self createGamePad];
        gamepadLight.alpha=1;
        joystiqLight.alpha=0;
    }
    else
    {
        [self removeGamePad];
        gamepadLight.alpha=0;
        joystiqLight.alpha=0;
    }    
}


- (void)toggleMouse
{
    if (fsMouseLeft == nil || fsMouseRight == nil)
    {
        [self removeOverlayKeyboard];
        [self removeGamePad];
        [self createMouseButtons];
    }
    else
    {
        [self removeMouseButtons];
    }
}


- (void)toggleScreenSize
{
    useOriginalScreenSize = !useOriginalScreenSize;
    [self updateUI];
}


- (void)onSliderChange
{
    if ( fabs(sliderInput.position-0) < fabs(sliderInput.position-0.5)) {
        sliderInput.position=0;
        [self removeGamePad];
        gamepadLight.alpha=0;
        joystiqLight.alpha=0;
    } else if (fabs(sliderInput.position-1) > fabs(sliderInput.position-0.5)) {
        sliderInput.position=0.5;
        mode = GamePadDefault;
        [self createGamePad];
        gamepadLight.alpha=1;
        joystiqLight.alpha=0;
    } else {
        sliderInput.position=1;
        mode = GamePadJoystick;
        [self createGamePad];
        gamepadLight.alpha=0;
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
        [self removeOverlayKeyboard];
        [self removeMouseButtons];
    }
    gamepad.alpha = 0;
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


- (void)dealloc {
    [btnToggleMouse release];
    [fsMouseLeft release];
    [fsMouseRight release];
    [btnToggleGamePad release];
    [btnToggleJoystiq release];
    [btnToggleNumpad release];
    [btnToggleKeyboard release];
    
    [labCycles2 release];
    [fsIndicator2 release];
    [fullscreenPanel release];
    [gamepadLight release];
    [joystiqLight release];
    [btnBack release];
    [btnOption release];
    [keyboard release];
    [labCycles release];
    [fsIndicator release];
    [vk release];
    [sliderInput release];
    [btnMouseLeft release];
    [btnMouseRight release];
    [gamepad release];
    [overlayKeyboard release];
    [super dealloc];
}

-(void)onResize:(CGSize)sizeNew
{
    self.screenView.bounds = CGRectMake(0, 0, sizeNew.width, sizeNew.height);
    [self updateUI];
}

- (void)didFloatingView:(FloatingView *)fltView
{
    if ([fltView tag] == TAG_CMD) {
        CommandListView *v = (CommandListView*) fltView;
        if (v.selected) {
            NSLog(@"%@", v.selectedCommand);
            [self sendCommandToDOS:v.selectedCommand];
        }
    } else if ([fltView tag] == TAG_INPUT) {
        
    }
    [fltView release];
}

- (void)showCommandList
{
    CommandListView *v = [[CommandListView alloc] initWithParent:self.view];
    [v setTag:TAG_CMD];
    [v setDelegate:self];
    [v show];     
}


@end
