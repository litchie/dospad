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
#import "SplashViewController.h"
#import "FileSystemObject.h"
#import "Common.h"

#define GIF_DURATION    2.5
#define SPLASH_DURATION 4  // Determined with the start up sound

@implementation SplashViewController

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
    self.view.backgroundColor = [UIColor blackColor];
    FileSystemObject *fso = [FileSystemObject sharedObject];
    NSString *path  = [[fso bundleDirectory] stringByAppendingPathComponent:@"idos-splash.gif"];
    
    gif = [[GIFAnimation alloc] initWithGIFFile:path];
    gif.duration = GIF_DURATION;
    if (!ISIPAD())
    {
        gif.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    }
    gif.animationRepeatCount = 1;
    [self.view addSubview:gif];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [gif removeFromSuperview];
    gif = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    [player pause];
    player = nil;
}

- (void)hideSplash
{
    gif.alpha = 0;
    [UIView beginAnimations:@"hideSplash" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDuration:1];
    self.view.alpha = 0;
    [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    FileSystemObject *fso = [FileSystemObject sharedObject];
    NSString *path  = [[fso bundleDirectory] stringByAppendingPathComponent:@"start-up.mp3"];
    player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:path]];
    [player play];
    gif.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [gif startAnimating];
    [self performSelector:@selector(hideSplash) withObject:nil afterDelay:SPLASH_DURATION];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
