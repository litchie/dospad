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

extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);

void enter_string_to_dos(const char *s)
{
    const char *p=s;
    if (s == 0) return;
    while (*p!=0) {
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

#define TAG_CMD 1
#define TAG_INPUT 2

@implementation DosPadViewController
@synthesize emuThread;
@synthesize screenView,keyboard;
@synthesize btnOption,btnFullscreen;
@synthesize navController;
@synthesize k1,k2,k3,k4,k5,k6,k7,k8,k9;
@synthesize labTitle,labCycles;
@synthesize fsIndicator;
@synthesize tip;

-(void)updateFrameskip:(NSNumber*)skip
{
    self.fsIndicator.count=[skip intValue];
}

-(void)updateCpuCycles:(NSString*)title
{
    self.labCycles.text=title;
}

-(IBAction)hideOption
{
    [self.navController dismissModalViewControllerAnimated:YES];
}

-(IBAction)showOption
{
    [self presentModalViewController:self.navController animated:YES];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

-(IBAction)start {
  if (self.emuThread == nil) {
    self.emuThread = [[DosEmuThread alloc] autorelease];
  }
  if (!self.emuThread.started) {
      [self.emuThread start];
  }
}


-(void)updateTitles
{
    NSUserDefaults*defs=[NSUserDefaults standardUserDefaults];
    k1.title=[NSString stringWithUTF8String:get_key_title([defs integerForKey:kK1])];
    k2.title=[NSString stringWithUTF8String:get_key_title([defs integerForKey:kK2])];
    k3.title=[NSString stringWithUTF8String:get_key_title([defs integerForKey:kK3])];
    k4.title=[NSString stringWithUTF8String:get_key_title([defs integerForKey:kK4])];
    k5.title=[NSString stringWithUTF8String:get_key_title([defs integerForKey:kK5])];
    k6.title=[NSString stringWithUTF8String:get_key_title([defs integerForKey:kK6])];
    k7.title=[NSString stringWithUTF8String:get_key_title([defs integerForKey:kK7])];
    k8.title=[NSString stringWithUTF8String:get_key_title([defs integerForKey:kK8])];
    k9.title=[NSString stringWithUTF8String:get_key_title([defs integerForKey:kK9])];
    k1.code = [defs integerForKey:kK1];
    k2.code = [defs integerForKey:kK2];
    k3.code = [defs integerForKey:kK3];
    k4.code = [defs integerForKey:kK4];
    k5.code = [defs integerForKey:kK5];
    k6.code = [defs integerForKey:kK6];
    k7.code = [defs integerForKey:kK7];
    k8.code = [defs integerForKey:kK8];
    k9.code = [defs integerForKey:kK9];
}

-(float)floatAlpha
{
    NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
    return 1-[defs floatForKey:kTransparency];    
}

-(void)updateAlpha
{
    float a = [self floatAlpha];
    k1.alpha = k1.alpha==0?0:a;
    k2.alpha = k2.alpha==0?0:a;
    k3.alpha = k3.alpha==0?0:a;
    k4.alpha = k4.alpha==0?0:a;
    k5.alpha = k5.alpha==0?0:a;
    k6.alpha = k6.alpha==0?0:a;
    k7.alpha = k7.alpha==0?0:a;
    k8.alpha = k8.alpha==0?0:a;
    k9.alpha = k9.alpha==0?0:a;
}


- (void)updateBackground:(UIInterfaceOrientation)interfaceOrientation
{
    UIImage *img;
    if (interfaceOrientation==UIInterfaceOrientationPortrait||
        interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) 
    {
        img = [UIImage imageNamed:@"dospadportrait.jpg"];
    } else {
        img = [UIImage imageNamed:@"dospadlandscape.jpg"];
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:img];
}

- (void)updateBackground
{
    [self updateBackground:self.interfaceOrientation];
}

-(void)adjust:(BOOL)animated
{
    animated=NO;
    if (animated) {
        [UIView beginAnimations:@"Adj" context:nil];
        [UIView setAnimationDuration:0.5];
    }
    float sh = self.screenView.bounds.size.height;
    float sw = self.screenView.bounds.size.width;
    float additionalScaleY = 1.0;
    if (sh/sw!=0.75 && DEFS_GET_INT(kForceAspect)) {
        additionalScaleY = 0.75 / (sh/sw);
    } 
    if (fullscreen) {
        sliderInput.alpha=0;
        self.btnFullscreen.alpha=0;
        self.btnOption.alpha=0;
        self.labCycles.alpha=0;
        self.view.backgroundColor = [UIColor blackColor];
        float sx = self.view.bounds.size.width/sw;
        float sy = self.view.bounds.size.height/sh;
       
        float scale = MIN(sx,sy);
        self.screenView.transform = CGAffineTransformMakeScale(scale,scale*additionalScaleY);
        self.screenView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    } else {
        [self updateBackground];
        float vh = self.view.bounds.size.height;
        float kh = self.keyboard.bounds.size.height;
        float scale=1;
        if (sw < 640) { scale = 640.0f/sw; }
        self.screenView.transform=CGAffineTransformMakeScale(scale,scale*additionalScaleY);

        if (self.interfaceOrientation==UIInterfaceOrientationPortrait||
            self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
        {
            self.screenView.center=CGPointMake(384, 314);
            self.keyboard.frame=CGRectMake(14,648,740,360);
            self.btnOption.center=CGPointMake(670, 614);
            self.labCycles.center=CGPointMake(564, 615);
            
            self.btnOption.alpha=1;
            self.labCycles.alpha=1;
            self.btnFullscreen.alpha=0; 
            sliderInput.alpha=1;
            btnMouseRight.frame=CGRectMake(736,210,23,86);
            btnMouseLeft.frame=CGRectMake(736,310,23,86);
        } else {
            self.screenView.center=CGPointMake(650, 247);
            self.keyboard.frame=CGRectMake(0,505,1024,262);
            self.btnOption.center=CGPointMake(52, 42);
            self.labCycles.center=CGPointMake(214, 375);
            self.btnFullscreen.frame=CGRectMake(232,2,34,34);
            sliderInput.alpha=0;
            self.btnOption.alpha=1;
            self.labCycles.alpha=1;
            self.btnFullscreen.alpha=1;
            btnMouseRight.frame=CGRectMake(994,154,23,86);
            btnMouseLeft.frame=CGRectMake(994,255,23,86);
        }
    }
    if (animated) {
        [UIView commitAnimations];
    }
    //NSLog(@"option %f %f, cycles %f %f", btnOption.center.x,
//          btnOption.center.y,
//          labCycles.center.x,
//          labCycles.center.y);
    
    if (fullscreen) {
        if (DEFS_GET_INT(kFullscreenKeypad)) {
            float a = [self floatAlpha];
            k1.alpha=a;
            k2.alpha=a;
            k3.alpha=a;
            k4.alpha=a;
            k5.alpha=a;
            k6.alpha=a;
            k7.alpha=a;
            k8.alpha=a;
            k9.alpha=a;
        }
        self.keyboard.alpha=0;
    } else {
        k1.alpha=0;
        k2.alpha=0;
        k3.alpha=0;
        k4.alpha=0;
        k5.alpha=0;
        k6.alpha=0;
        k7.alpha=0;
        k8.alpha=0;
        k9.alpha=0;
        
        self.keyboard.alpha=1;
        self.keyboard.asOverlay=YES;
        if (self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown ||
            self.interfaceOrientation==UIInterfaceOrientationPortrait)
        {
            [self.keyboard createKeys];
        } else {
            [self.keyboard createLandscapeKeys];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateBackground];
    [self updateAlpha];
    [self updateTitles];
    [self onResize:self.screenView.bounds.size];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.labCycles.font=[UIFont fontWithName:@"DBLCDTempBlack" size:30];
    [self.fsIndicator removeFromSuperview];
    self.fsIndicator.frame=CGRectMake(0,self.labCycles.frame.size.height-self.fsIndicator.frame.size.height,
                                      self.fsIndicator.frame.size.width,
                                      self.fsIndicator.frame.size.height);
    [self.labCycles addSubview:self.fsIndicator];
    
    self.screenView.delegate=self;
    self.screenView.mouseHoldDelegate=self;
    
    [self adjust:NO];
    
    hi = [[HoldIndicator alloc] initWithFrame:CGRectMake(0,0,128,128)];
    hi.alpha=0;
    hi.transform=CGAffineTransformMakeScale(1.5, 1.5);
    [self.view addSubview:hi];
    
    k1.alpha = 0; 
    k2.alpha = 0; 
    k3.alpha = 0; 
    k4.alpha = 0; 
    k5.alpha = 0; 
    k6.alpha = 0; 
    k7.alpha = 0; 
    k8.alpha = 0; 
    k9.alpha = 0; 
    k1.delegate = self.keyboard;
    k2.delegate = self.keyboard;
    k3.delegate = self.keyboard;
    k4.delegate = self.keyboard;
    k5.delegate = self.keyboard;
    k6.delegate = self.keyboard;
    k7.delegate = self.keyboard;
    k8.delegate = self.keyboard;
    k9.delegate = self.keyboard;
    self.labTitle.alpha=0;
    
    sliderInput=[[SliderView alloc] initWithFrame:CGRectMake(405,961,146,26)];
    [sliderInput setActionOnSliderChange:@selector(onSliderChange) target:self];
    [self.view addSubview:sliderInput];
    
    btnMouseLeft=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
    btnMouseRight=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [btnMouseLeft addTarget:self action:@selector(onMouseLeftDown) forControlEvents:UIControlEventTouchDown];
    [btnMouseLeft addTarget:self action:@selector(onMouseLeftUp) forControlEvents:UIControlEventTouchUpInside];
    [btnMouseRight addTarget:self action:@selector(onMouseRightDown) forControlEvents:UIControlEventTouchDown];
    [btnMouseRight addTarget:self action:@selector(onMouseRightUp) forControlEvents:UIControlEventTouchUpInside];    
    [self.view addSubview:btnMouseLeft];
    [self.view addSubview:btnMouseRight];
}

- (void)onMouseLeftDown
{
    [self.screenView sendMouseEvent:0 left:YES down:YES];
}
- (void)onMouseLeftUp
{
    [self.screenView sendMouseEvent:0 left:YES down:NO];    
}

- (void)onMouseRightDown
{
    [self.screenView sendMouseEvent:0 left:NO down:YES];        
}
- (void)onMouseRightUp
{
    [self.screenView sendMouseEvent:0 left:NO down:NO];            
}

- (void)onSliderChange
{
    sliderInput.position=0;
    
    FloatingView *flt=[[FloatingView alloc] initWithParent:self.view];
    UIImageView *imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"modesel.png"]];
    [flt addSubview:imgView];
    [flt setTag:TAG_INPUT];
    [flt setDelegate:self];
    imgView.center=CGPointMake(self.view.bounds.size.width/2, 
                               self.view.bounds.size.height-400);
    [imgView release];
    [flt show];
}

-(void)viewDidAppear:(BOOL)animated
{
#ifdef THREADED
    [self performSelector:@selector(start) withObject:nil afterDelay:0.5];
#endif
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (!fullscreen) {
        self.keyboard.alpha=0;
        self.screenView.alpha=0;
        self.labCycles.alpha=0;
        self.btnFullscreen.alpha=0;
        [self updateBackground:toInterfaceOrientation];
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.keyboard.alpha=1;
    self.screenView.alpha=1;
    [self adjust:YES];
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
    self.k1 =nil;
    self.k2 =nil;
    self.k3 =nil;
    self.k4 =nil;
    self.k5 =nil;
    self.k6 =nil;
    self.k7 =nil;
    self.k8 =nil;
    self.k9 =nil;
    self.navController=nil;
    self.btnOption=nil;
    self.btnFullscreen=nil;
    self.emuThread = nil;
    self.screenView = nil;
    self.keyboard=nil;
    self.labTitle=nil;
    self.labCycles=nil;
    self.fsIndicator=nil;
    self.tip=nil;
    [sliderInput release];
    [hi release];
    [btnMouseLeft release];
    [btnMouseRight release];
    [super dealloc];
}

-(void)onResize:(CGSize)sizeNew
{
    self.screenView.bounds = CGRectMake(0, 0, sizeNew.width, sizeNew.height);
    [self adjust:YES];
}

- (void)didFloatingView:(FloatingView *)fltView
{
    if ([fltView tag] == TAG_CMD) {
        CommandListView *v = (CommandListView*) fltView;
        if (v.selected) {
            NSLog(@"%@", v.selectedCommand);
            enter_string_to_dos([v.selectedCommand UTF8String]);
        }
    } else if ([fltView tag] == TAG_INPUT) {
        
    }
    [fltView release];
}


// Double tap at the background in fullscreen mode will quit fullscreen
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!fullscreen && [touches count]==1 && [[touches anyObject] tapCount]==1)
    {
        CGPoint location = [[touches anyObject] locationInView:self.view];
        BOOL hit=NO;
        if (self.interfaceOrientation==UIInterfaceOrientationPortrait ||
            self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
        {
            CGRect rect=CGRectMake(69, 581, 85, 70);
            hit=CGRectContainsPoint(rect, location);
        } 
        else {
            CGRect rect=CGRectMake(14, 339, 85, 70);
            hit=CGRectContainsPoint(rect, location);            
        }
        if (hit)
        {
            CommandListView *v = [[CommandListView alloc] initWithParent:self.view];
            [v setTag:TAG_CMD];
            [v setDelegate:self];
            [v show];   
        }
    } else if (fullscreen && [touches count]==1 && [[touches anyObject] tapCount]==2) {
        fullscreen = !fullscreen;
        [self adjust:NO];        
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

-(void)hideTip
{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.5];
    self.tip.alpha=0;
    [UIView commitAnimations];
}


-(void)showTip
{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.3];
    self.tip.alpha=1;
    [UIView commitAnimations];
}

-(IBAction)switchToFullscreen
{
    if (!fullscreen) {
        fullscreen=YES;
        [self adjust:NO];
        if (self.tip==nil) {
            self.tip = [[[TipView alloc] initWithFrame:CGRectMake(15, 30, 300, 100)
                                                 style:TipViewUpward
                                               pointTo:CGPointMake(30,30)] autorelease];
            self.tip.label.text=@"Double tap HERE to exit fullscreen";
        }            
        [self.view addSubview:self.tip];
        self.tip.alpha=0;
        [self showTip];
        [self performSelector:@selector(hideTip) withObject:nil afterDelay:5];
    }
}

-(BOOL)onDoubleTap:(CGPoint)pt
{
    // Tap at the top left corner to toggle fullscreen
    if (0 < pt.x && pt.x < 60 && 0 < pt.y && pt.y < 60 && fullscreen)
    {
        [self.tip removeFromSuperview];
        fullscreen = !fullscreen;
        [self adjust:NO];        
        return YES;
    }
    else 
    {
        return NO;
    }
}

-(void)hideModalView
{
    if (modalView == nil) {
        return;
    }
    [UIView beginAnimations:@"hideModalView" context:nil];
    [UIView setAnimationDuration:0.5];
    modalView.alpha=0;
    [UIView commitAnimations];
}

-(void)showModalView
{
    if (modalView == nil) {
        modalView = [[UIView alloc] initWithFrame:self.view.bounds];
        modalView.backgroundColor=[UIColor clearColor];
    }
    modalView.alpha=0;
    [UIView beginAnimations:@"showModalView" context:nil];
    [UIView setAnimationDuration:0.5];
    modalView.alpha=1;
    [UIView commitAnimations];
}


-(void)onHold:(CGPoint)pt
{
    CGPoint pt2 = [self.screenView convertPoint:pt toView:self.view];
    hi.center=pt2;
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.3];
    hi.alpha=1;
    [UIView commitAnimations];
}

-(void)cancelHold:(CGPoint)pt
{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.3];
    hi.alpha=0;
    [UIView commitAnimations];    
}



@end
