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

@implementation DosPadViewController_iPhone
@synthesize emuThread;
@synthesize screenView;
@synthesize kbd;
@synthesize navController;
@synthesize k1,k2,k3,k4,k5,k6,k7,k8,k9;
@synthesize labTitle,labCycles,btnMouseLeft,btnMouseRight,fsIndicator;


-(void)updateFrameskip:(NSNumber*)skip
{
    self.fsIndicator.count=[skip intValue];
}

-(void)updateCpuCycles:(NSString*)title
{
    self.labCycles.text=title;
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

-(float)floatAlpha
{
    NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
    return 1-[defs floatForKey:kTransparency];    
}

-(IBAction)donate
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:DONATE_URL]];
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


-(void)viewDidAppear:(BOOL)animated
{
#ifdef THREADED
    [self performSelector:@selector(start) withObject:nil afterDelay:0.5];
#endif
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.labCycles.font=[UIFont fontWithName:@"DBLCDTempBlack" size:12];
    self.labCycles.text=@"3000";
    self.labCycles.textAlignment=UITextAlignmentLeft;
    self.labCycles.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
    self.view.backgroundColor =[UIColor blackColor];
    self.fsIndicator = [[[FrameskipIndicator alloc] initWithFrame:CGRectMake(self.labCycles.frame.size.width-8,0,8,20)
                                                           style:FrameskipIndicatorStyleVertical] autorelease];
    [self.labCycles addSubview:self.fsIndicator];
    
    [self.kbd createIphoneKeys];
    k1.alpha = 0; 
    k2.alpha = 0; 
    k3.alpha = 0; 
    k4.alpha = 0; 
    k5.alpha = 0; 
    k6.alpha = 0; 
    k7.alpha = 0; 
    k8.alpha = 0; 
    k9.alpha = 0; 
    self.kbd.alpha=0;
    k1.delegate = self.kbd;
    k2.delegate = self.kbd;
    k3.delegate = self.kbd;
    k4.delegate = self.kbd;
    k5.delegate = self.kbd;
    k6.delegate = self.kbd;
    k7.delegate = self.kbd;
    k8.delegate = self.kbd;
    k9.delegate = self.kbd;

    [self onResize:CGSizeMake(640,400)];
    self.screenView.delegate=self;
    self.screenView.mouseHoldDelegate=self;
    
    hi = [[HoldIndicator alloc] initWithFrame:CGRectMake(0,0,128,128)];
    hi.alpha=0;
    hi.transform=CGAffineTransformMakeScale(1.5, 1.5);
    [self.view addSubview:hi];
    self.labTitle.alpha=0;
    
    [btnMouseLeft addTarget:self action:@selector(onMouseLeftDown) forControlEvents:UIControlEventTouchDown];
    [btnMouseLeft addTarget:self action:@selector(onMouseLeftUp) forControlEvents:UIControlEventTouchUpInside];
    [btnMouseRight addTarget:self action:@selector(onMouseRightDown) forControlEvents:UIControlEventTouchDown];
    [btnMouseRight addTarget:self action:@selector(onMouseRightUp) forControlEvents:UIControlEventTouchUpInside];    
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
    kbd.alpha = kbd.alpha==0?0:a;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateAlpha];
    [self updateTitles];
    [self onResize:self.screenView.bounds.size];
}
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
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
    self.labTitle=nil;
    self.k1 =nil;
    self.k2 =nil;
    self.k3 =nil;
    self.k4 =nil;
    self.k5 =nil;
    self.k6 =nil;
    self.k7 =nil;
    self.k8 =nil;
    self.k9 =nil;
    
    self.kbd=nil;
    self.navController=nil;
    self.screenView=nil;
    self.labCycles=nil;
    self.btnMouseLeft=nil;
    self.btnMouseRight=nil;
    self.fsIndicator=nil;
    [hi release];
    [super dealloc];
}

-(IBAction)showOption
{
    optionIsShowing = YES;
    [self presentModalViewController:self.navController animated:YES];
}

-(IBAction)hideOption
{
    [self.navController dismissModalViewControllerAnimated:YES];
    optionIsShowing=NO;
}


-(IBAction)toggleKeyboard
{
    if (self.kbd.alpha != 0) {
        self.kbd.alpha = 0;
    } else {
        if (k1.alpha > 0) [self toggleKeypad];
        self.kbd.alpha = [self floatAlpha];
    }
}

-(IBAction)toggleKeypad
{
    float a = [self floatAlpha];
    k1.alpha = k1.alpha==0?a:0;
    k2.alpha = k2.alpha==0?a:0;
    k3.alpha = k3.alpha==0?a:0;
    k4.alpha = k4.alpha==0?a:0;
    k5.alpha = k5.alpha==0?a:0;
    k6.alpha = k6.alpha==0?a:0;
    k7.alpha = k7.alpha==0?a:0;
    k8.alpha = k8.alpha==0?a:0;
    k9.alpha = k9.alpha==0?a:0;
    if (k1.alpha > 0) {
        if (kbd.alpha >0) [self toggleKeyboard];
    }
}

-(void)onResize:(CGSize)sizeNew
{
    self.screenView.bounds = CGRectMake(0, 0, sizeNew.width, sizeNew.height);
    CGAffineTransform t = CGAffineTransformIdentity;
    float scalex = 480 / sizeNew.width;
    float scaley = 300 / sizeNew.height;
    float scale = MIN(scalex, scaley);
    
    float sh = self.screenView.bounds.size.height;
    float sw = self.screenView.bounds.size.width;
    float additionalScaleY = 1.0;
    if (sh/sw!=0.75 && DEFS_GET_INT(kForceAspect)) {
        additionalScaleY = 0.75 / (sh/sw);
    } 
    t = CGAffineTransformScale(t, scale/additionalScaleY, scale);
    self.screenView.transform = t;
    self.screenView.center = CGPointMake(240, 150);
}

-(BOOL)onDoubleTap:(CGPoint)pt
{
    // Do nothing
    return NO;
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
