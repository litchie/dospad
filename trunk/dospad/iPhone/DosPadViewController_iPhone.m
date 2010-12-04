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
#import "OptionViewController.h"
#import "Common.h"
#import "AppDelegate.h"

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
    UIImage *backgroundImage = [UIImage imageNamed:@"bar-portrait-iphone.png"];
    [backgroundImage drawInRect:rect];
}

@end



@implementation DosPadViewController_iPhone


- (void)loadView
{
    //---------------------------------------------------
    // 1. Create View
    //---------------------------------------------------
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
    self.view.backgroundColor = [UIColor blackColor];

    //---------------------------------------------------
    // 2. Create the toolbar in portrait mode
    //---------------------------------------------------

    toolPanel = [[ToolPanelView alloc] initWithFrame:CGRectMake(0,240,320,25)];

    UIButton *btnOption = [[[UIButton alloc] initWithFrame:CGRectMake(0,0,32,25)] autorelease];
    UIButton *btnLeft = [[[UIButton alloc] initWithFrame:CGRectMake(33,0,67,25)] autorelease];
    UIButton *btnRight = [[[UIButton alloc] initWithFrame:CGRectMake(100,0,67,25)] autorelease];
    [btnLeft setImage:[UIImage imageNamed:@"leftmouse.png"] forState:UIControlStateHighlighted];
    [btnRight setImage:[UIImage imageNamed:@"rightmouse.png"] forState:UIControlStateHighlighted];
    
    // Create the button larger than the image, so we have a bigger clickable area,
    // while visually takes smaller place
    UIButton *btnDPadSwitch = [[[UIButton alloc] initWithFrame:CGRectMake(170,0,76,25)] autorelease];
    UIImageView *imgTmp = [[[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 72, 16)] autorelease];
    imgTmp.image = [UIImage imageNamed:@"switch.png"];
    [btnDPadSwitch addSubview:imgTmp];
    slider = [[UIImageView alloc] initWithFrame:CGRectMake(21,7,17,8)];
    slider.image = [UIImage imageNamed:@"switchbutton.png"];
    [btnDPadSwitch addSubview:slider];
    
    [btnOption addTarget:self action:@selector(showOption) forControlEvents:UIControlEventTouchUpInside];
    [btnLeft addTarget:self action:@selector(onMouseLeftDown) forControlEvents:UIControlEventTouchDown];
    [btnLeft addTarget:self action:@selector(onMouseLeftUp) forControlEvents:UIControlEventTouchUpInside];
    [btnRight addTarget:self action:@selector(onMouseRightDown) forControlEvents:UIControlEventTouchDown];
    [btnRight addTarget:self action:@selector(onMouseRightUp) forControlEvents:UIControlEventTouchUpInside];    
    [btnDPadSwitch addTarget:self action:@selector(onGamePadModeSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
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
    [toolPanel addSubview:btnDPadSwitch];
    [self.view addSubview:toolPanel];     
    
    //---------------------------------------------------
    // 3. <null>
    //---------------------------------------------------
    
    //---------------------------------------------------
    // 4. <null>
    //---------------------------------------------------    
    
    //---------------------------------------------------
    // 5. Virtual Keyboard
    //---------------------------------------------------        
    vk = [[VKView alloc] initWithFrame:CGRectMake(0,0,1,1)];
    vk.alpha=0;
    [self.view addSubview:vk];
    
    //---------------------------------------------------
    // 6. Keyboard Show Button
    //---------------------------------------------------        
    btnShowKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(184,440,100,38)];
    [btnShowKeyboard addTarget:self action:@selector(showNativeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnShowKeyboard];

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
    btnToggleGamePad = [[UIButton alloc] initWithFrame:CGRectMake(278,0,48,24)];
    btnToggleJoystiq = [[UIButton alloc] initWithFrame:CGRectMake(250,0,48,24)];
    btnToggleNumpad = [[UIButton alloc] initWithFrame:CGRectMake(250,0,48,24)];
    btnToggleKeyboard =  [[UIButton alloc] initWithFrame:CGRectMake(150,0,48,24)];
    btnToggleMouse =  [[UIButton alloc] initWithFrame:CGRectMake(150,0,48,24)];
    
    [btnToggleGamePad setImage:[UIImage imageNamed:@"modegamepad.png"] forState:UIControlStateNormal];
    [btnToggleGamePad setImage:[UIImage imageNamed:@"modegamepadpressed.png"] forState:UIControlStateHighlighted];
    [btnToggleJoystiq setImage:[UIImage imageNamed:@"modejoy.png"] forState:UIControlStateNormal];
    [btnToggleJoystiq setImage:[UIImage imageNamed:@"modejoypressed.png"] forState:UIControlStateHighlighted];
    [btnToggleNumpad setImage:[UIImage imageNamed:@"modenumpad.png"] forState:UIControlStateNormal];
    [btnToggleNumpad setImage:[UIImage imageNamed:@"modenumpadpressed.png"] forState:UIControlStateHighlighted];
    [btnToggleKeyboard setImage:[UIImage imageNamed:@"modekeyoff.png"] forState:UIControlStateNormal];
    [btnToggleKeyboard setImage:[UIImage imageNamed:@"modekeyon.png"] forState:UIControlStateHighlighted];
    [btnToggleMouse setImage:[UIImage imageNamed:@"mouseoff.png"] forState:UIControlStateNormal];
    [btnToggleMouse setImage:[UIImage imageNamed:@"mouseon.png"] forState:UIControlStateHighlighted];
    
    [btnToggleGamePad addTarget:self action:@selector(toggleGamePad) forControlEvents:UIControlEventTouchUpInside];
    [btnToggleJoystiq addTarget:self action:@selector(toggleJoystick) forControlEvents:UIControlEventTouchUpInside];
    [btnToggleKeyboard addTarget:self action:@selector(toggleKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [btnToggleNumpad addTarget:self action:@selector(toggleNumpad) forControlEvents:UIControlEventTouchUpInside];
    [btnToggleMouse addTarget:self action:@selector(toggleMouse) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *cpuWindow = [[UIImageView alloc] initWithFrame:CGRectMake(72,4,48,24)];
    cpuWindow.image = [UIImage imageNamed:@"cpuwindow.png"];
    
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
    [cpuWindow addSubview:labCycles2];
    
    btnOption = [[[UIButton alloc] initWithFrame:CGRectMake(380,0,48,24)] autorelease];
    [btnOption setImage:[UIImage imageNamed:@"options.png"] forState:UIControlStateNormal];
    [btnOption addTarget:self action:@selector(showOption) forControlEvents:UIControlEventTouchUpInside];
    
    [fullscreenPanel setItems:[NSArray arrayWithObjects:
                               cpuWindow,
                               btnToggleKeyboard, 
                               btnToggleMouse,
                               btnToggleGamePad,
                               btnToggleJoystiq,
                               btnToggleNumpad,
                               btnOption,
                               nil]];

    UIButton *btnExitFS = [[UIButton alloc] initWithFrame:CGRectMake(0,0,48,24)];
    btnExitFS.center=CGPointMake(44, 13);
    [btnExitFS setImage:[UIImage imageNamed:@"exitfull.png"] forState:UIControlStateNormal];
    [btnExitFS addTarget:self action:@selector(toggleScreenSize) forControlEvents:UIControlEventTouchUpInside];
    [fullscreenPanel.contentView addSubview:btnExitFS];

    [btnExitFS release];
    
    [cpuWindow release];
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
        gamepad.dpadMovable = DEFS_GET_INT(kDPadMovable);
    }
    numpad.alpha=a;
    fsMouseLeft.alpha=a;
    fsMouseRight.alpha=a;
}

- (void)removeNativeKeyboard
{
    // Hide the virtual native keyboard
    // However, we are still listening to external keyboard input
    vk.active = NO;
    vk.useNativeKeyboard=NO;
    vk.active = YES;    
}

- (void)showNativeKeyboard
{
    if (vk.active)
        vk.active=NO;
    vk.useNativeKeyboard = YES;
    vk.active = YES;
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
    
    // Left Mouse Button
    fsMouseLeft = [[UIButton alloc] initWithFrame:CGRectMake(440,160,48,80)];
    [fsMouseLeft setTitle:@"L" forState:UIControlStateNormal];
    [fsMouseLeft setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [fsMouseLeft setBackgroundImage:[UIImage imageNamed:@"longbutton.png"] 
                           forState:UIControlStateNormal];
    [fsMouseLeft addTarget:self
                    action:@selector(onMouseLeftDown)
          forControlEvents:UIControlEventTouchDown];
    [fsMouseLeft addTarget:self
                    action:@selector(onMouseLeftUp)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fsMouseLeft];
    
    // Right Mouse Button
    fsMouseRight = [[UIButton alloc] initWithFrame:CGRectMake(440,80,48,80)];
    [fsMouseRight setTitle:@"R" forState:UIControlStateNormal];
    [fsMouseRight setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [fsMouseRight setBackgroundImage:[UIImage imageNamed:@"longbutton.png"] 
                            forState:UIControlStateNormal];
    [fsMouseRight addTarget:self
                     action:@selector(onMouseRightDown)
           forControlEvents:UIControlEventTouchDown];
    [fsMouseRight addTarget:self
                    action:@selector(onMouseRightUp)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fsMouseRight];
    
    // Transparency
    fsMouseLeft.alpha=[self floatAlpha];
    fsMouseRight.alpha=[self floatAlpha];   
    [btnToggleMouse setImage:[UIImage imageNamed:@"mouseon.png"] forState:UIControlStateNormal];
}


- (void)removeNumpad
{
    if (numpad)
    {
        [numpad removeFromSuperview];
        [numpad release];
        numpad = nil;
        [btnToggleNumpad setImage:[UIImage imageNamed:@"modenumpad.png"] forState:UIControlStateNormal];
    }
}

- (void)createNumpad
{
    [self removeNumpad];
    numpad = [[KeyboardView alloc] initWithType:KeyboardTypeNumPad frame:CGRectMake(320,120,160,200)];
    numpad.alpha = [self floatAlpha];
    [self.view addSubview:numpad];
    
    CGPoint ptOld = numpad.center;
    numpad.center = CGPointMake(ptOld.x, ptOld.y+numpad.frame.size.height);
    [UIView beginAnimations:nil context:NULL];
    numpad.center = ptOld;
    [UIView commitAnimations];
    [btnToggleNumpad setImage:[UIImage imageNamed:@"modenumpadpressed.png"] forState:UIControlStateNormal];
}

- (void)removeKeyboard
{
    if (kbd)
    {
        [kbd removeFromSuperview];
        [kbd release];
        kbd = nil;
        [btnToggleKeyboard setImage:[UIImage imageNamed:@"modekeyoff.png"] forState:UIControlStateNormal];
    }    
}

- (void)createKeyboard
{
    [self removeKeyboard];

    kbd = [[KeyboardView alloc] initWithType:KeyboardTypeLandscape 
                                       frame:CGRectMake(0, 120, 480, 200)];
    kbd.alpha = [self floatAlpha];    
    [self.view addSubview:kbd];  
    
    CGPoint ptOld = kbd.center;
    kbd.center = CGPointMake(ptOld.x, ptOld.y+kbd.frame.size.height);
    [UIView beginAnimations:nil context:NULL];
    kbd.center = ptOld;
    [UIView commitAnimations];
    [btnToggleKeyboard setImage:[UIImage imageNamed:@"modekeyon.png"] forState:UIControlStateNormal];
}

- (void)removeGamePad
{
    if (gamepad) 
    {
        [gamepad removeFromSuperview];
        [gamepad release];
        gamepad = nil;
        [btnToggleGamePad setImage:[UIImage imageNamed:@"modegamepad.png"] forState:UIControlStateNormal];
        [btnToggleJoystiq setImage:[UIImage imageNamed:@"modejoy.png"] forState:UIControlStateNormal];
    }
}

- (void)createGamePad
{
    [self removeGamePad];
    if (configPath == nil) return ;
    NSString *section = ([self isPortrait] ?
                         @"[gamepad.iphone.portrait]" : 
                         @"[gamepad.iphone.landscape]");
    NSString *ui_cfg = get_temporary_merged_file(configPath, get_default_config());
    if (ui_cfg != nil)
    {
        gamepad = [[GamePadView alloc] initWithConfig:ui_cfg section:section];
        gamepad.mode = mode;
        DEBUGLOG(@"mode %d", gamepad.mode);
        if ([self isPortrait])
        {
            [self.view insertSubview:gamepad belowSubview:toolPanel];
        }
        else
        {
            gamepad.dpadMovable = DEFS_GET_INT(kDPadMovable);
            [self.view insertSubview:gamepad belowSubview:fullscreenPanel];
        }
    }

    if (mode == GamePadDefault)
    {
        [btnToggleGamePad setImage:[UIImage imageNamed:@"modegamepadpressed.png"] 
                          forState:UIControlStateNormal];
    }
    else
    {
        [btnToggleJoystiq setImage:[UIImage imageNamed:@"modejoypressed.png"] 
                          forState:UIControlStateNormal];
    }
}

- (void)toggleNumpad
{
    if (numpad)
    {
        [self removeNumpad];
    }
    else
    {
        [self removeMouseButtons];
        [self removeGamePad];
        [self removeKeyboard];
        [self createNumpad];
    }    
}

- (void)toggleKeyboard
{
    if (kbd)
    {
        [self removeKeyboard];
    }
    else
    {
        [self removeMouseButtons];
        [self removeGamePad];
        [self removeNumpad];
        [self createKeyboard];
    }
}

- (void)toggleGamePad
{
    if (gamepad == nil || mode != GamePadDefault)
    {
        [self removeMouseButtons];
        [self removeNumpad];
        [self removeKeyboard];
        mode = GamePadDefault;
        [self createGamePad];
    }
    else
    {
        [self removeGamePad];
    }
}

- (void)toggleJoystick
{
    if (gamepad == nil || mode != GamePadJoystick)
    {
        [self removeMouseButtons];
        [self removeNumpad];
        [self removeKeyboard];
        mode = GamePadJoystick;
        [self createGamePad];
    }
    else
    {
        [self removeGamePad];
    }    
}

- (void)toggleMouse
{
    if (fsMouseLeft == nil || fsMouseRight == nil)
    {
        [self removeNumpad];
        [self removeKeyboard];
        [self removeGamePad];
        [self createMouseButtons];
    }
    else
    {
        [self removeMouseButtons];
    }
}

- (void)updateBackground:(UIInterfaceOrientation)interfaceOrientation
{
    UIImage *img;
    if (interfaceOrientation==UIInterfaceOrientationPortrait||
        interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) 
    {
        img = [UIImage imageNamed:@"iphone-portrait.jpg"];
        self.view.backgroundColor = [UIColor colorWithPatternImage:img];
    } else {
        self.view.backgroundColor = [UIColor blackColor];
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
        [self removeKeyboard];
        [self createGamePad];
        [fullscreenPanel removeFromSuperview];
    }
    else
    {
        [self removeNativeKeyboard];
        if (self.view != fullscreenPanel.superview)
        {
            [self.view addSubview:fullscreenPanel];
            [fullscreenPanel showContent];
        }
        toolPanel.alpha=0;
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

- (void)viewDidLoad 
{
    [super viewDidLoad];
    mode = GamePadDefault;
    [self removeNativeKeyboard];
}

-(void)didFloatingView:(FloatingView*)fltView
{
    [self removeNativeKeyboard];
    [overlay release];
    overlay = nil;
}

-(void) keyboardWillShow:(NSNotification *)note
{
    if (overlay == nil)
    {
        overlay = [[FloatingView alloc] initWithParent:self.view];
        [overlay setDelegate:self];
        [overlay show];
    }
}

-(void) keyboardWillHide:(NSNotification *)note
{
    // Do nothing..
}

-(void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
        
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
#endif
}

-(void)viewWillDisappear:(BOOL)animated
{    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillHideNotification
     object:nil];    

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
        [self removeGamePad];
        [self removeKeyboard];
        [self removeNumpad];
        [self removeMouseButtons];
    }
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
    [btnToggleGamePad release];
    [btnToggleJoystiq release];
    [btnToggleNumpad release];
    [btnToggleKeyboard release];
    [btnToggleMouse release];
    [fsMouseLeft release];
    [fsMouseRight release];
    [gamepad release];
    [numpad release];
    [kbd release];
    [overlay release];
    [banner release];
    
    [labCycles release];
    [labCycles2 release];
    [fsIndicator release];
    [fsIndicator2 release];
    [toolPanel release];
    [vk release];
    [btnShowKeyboard release];
    [slider release];
    [fullscreenPanel release];
    [super dealloc];
}

-(void)onResize:(CGSize)sizeNew
{
    screenView.bounds = CGRectMake(0, 0, sizeNew.width, sizeNew.height);
    CGAffineTransform t = CGAffineTransformIdentity;
    int maxWidth, maxHeight;
    float scalex, scaley;
    CGPoint ptCenter;
    BOOL forceAspect = DEFS_GET_INT(kForceAspect); /* width:height = 4:3 */
    if ([self isPortrait])
    {
            maxWidth = 320;
            maxHeight = 240;
            ptCenter = CGPointMake(160, 120);
    }
    else
    {
        if (useOriginalScreenSize)
        {
            maxWidth = 320;
            maxHeight= 240;
            ptCenter = CGPointMake(240, 120);
        }
        else
        {
            maxWidth = 480;
            maxHeight= 320;
            ptCenter = CGPointMake(240, 160);
        }
    }

    if (forceAspect && (sizeNew.width * 0.75f != sizeNew.height))
    {
        if (maxWidth * 0.75f > maxHeight)
        {
            maxWidth = floor(maxHeight / 0.75f);
        } else {
            maxHeight = floor(maxWidth * 0.75f);
        }
        scalex = maxWidth / sizeNew.width;
        scaley = maxHeight / sizeNew.height;
    }
    else
    {
        scalex = maxWidth / sizeNew.width;
        scaley = maxHeight / sizeNew.height;
        scalex = MIN(scalex, scaley);
        scaley = scalex;
    }

    t = CGAffineTransformScale(t, scalex, scaley);
    screenView.transform = t;
    screenView.center=ptCenter;
}

@end
