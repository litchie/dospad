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

#import "KeyPadCustomizeViewController.h"
#import "Common.h"

@implementation KeyPadCustomizeViewController
@synthesize kbd;
@synthesize k1,k2,k3,k4,k5,k6,k7,k8,k9;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
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

-(void)onKeyDown:(KeyView*)k
{
    if (k == k1 || k == k2 || k == k3 || k == k4
        || k == k5 || k == k6 || k == k7 || k == k8 || k == k9)
    {
        if (k != hl) {
            k.highlight=YES;
            hl.highlight=NO;
            hl = k;
        }
    }
    else 
    {
        hl.code = k.code;
        hl.title=[NSString stringWithUTF8String:get_key_title(hl.code)];
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        if (hl == k1) {
            [defs setInteger:k.code forKey:kK1];
        } else if (hl == k2) {
            [defs setInteger:k.code forKey:kK2];
        } else if (hl == k3) {
            [defs setInteger:k.code forKey:kK3];
        } else if (hl == k4) {
            [defs setInteger:k.code forKey:kK4];
        } else if (hl == k5) {
            [defs setInteger:k.code forKey:kK5];
        } else if (hl == k6) {
            [defs setInteger:k.code forKey:kK6];
        } else if (hl == k7) {
            [defs setInteger:k.code forKey:kK7];
        } else if (hl == k8) {
            [defs setInteger:k.code forKey:kK8];
        } else if (hl == k9) {
            [defs setInteger:k.code forKey:kK9];            
        }
    }
}

-(void)onKeyUp:(KeyView*)k
{
    // KeyView by default set highlight to NO
    // when key is released. Here we want
    // to keep the highlight state
    if (k==hl) {
        k.highlight=YES;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    if (ISIPAD()) {
        [self.kbd createKeys];
    } else {
        [self.kbd createIphoneFullKeys];
    }    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Customize Key Pad";
    [self updateTitles];
    self.k1.highlight=YES;
    self.kbd.externKeyDelegate=self;
    hl = self.k1;
    k1.delegate = self;
    k2.delegate = self;
    k3.delegate = self;
    k4.delegate = self;
    k5.delegate = self;
    k6.delegate = self;
    k7.delegate = self;
    k8.delegate = self;
    k9.delegate = self;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (ISIPAD()) {
        [self.kbd createKeys];
    }
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if (ISIPAD()) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
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
    self.kbd=nil;
    [super dealloc];
}


@end
