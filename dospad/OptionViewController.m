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

#import "OptionViewController.h"
#import "Common.h"
#import "KeyPadCustomizeViewController.h"
#import "WebViewController.h"

@implementation OptionViewController
@synthesize cellTrans,slider;
@synthesize cellFullScreenKeypad,cellForceAspect;
@synthesize swFullscreenKeypad,swForceAspect;
@synthesize cellMouseSpeed;
@synthesize cellDisableKeySound;
@synthesize sliderMouseSpeed;
@synthesize swDisableKeySound;

#pragma mark -
#pragma mark View lifecycle

-(IBAction)switchValueChanged:(UISwitch*)sw
{
    if (sw==self.swForceAspect) {
        DEFS_SET_INT(kForceAspect, self.swForceAspect.on);
    } else if (sw==self.swFullscreenKeypad) {
        DEFS_SET_INT(kFullscreenKeypad, self.swFullscreenKeypad.on);
    } else if (sw==self.swDisableKeySound) {
        DEFS_SET_INT(kDisableKeySound, self.swDisableKeySound.on);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults*defs=[NSUserDefaults standardUserDefaults];
    self.slider.value=[defs floatForKey:kTransparency];
    self.sliderMouseSpeed.value=[defs floatForKey:kMouseSpeed];
    self.swFullscreenKeypad.on=DEFS_GET_INT(kFullscreenKeypad);
    self.swForceAspect.on=DEFS_GET_INT(kForceAspect);
    self.swDisableKeySound.on=DEFS_GET_INT(kDisableKeySound);
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if (ISIPAD()) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 7;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    int row = [indexPath row];
    switch (row) {
        case 0:
        {
            cell.textLabel.text=@"Customize Key Pad";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1:
        {
            return cellTrans;
        }
        case 2:
        {
            return cellFullScreenKeypad;
        }
        case 3:
        {
            return cellForceAspect;
        }
        case 4:
        {
            return cellDisableKeySound;
        }
        case 5:
        {
            return cellMouseSpeed;
        }
        case 6:
        {
            cell.textLabel.text=@"Credits";
            break;
        }
    }
    return cell;
}


-(CGFloat) tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSUInteger rowNumber = [indexPath row];
    NSUInteger section = [indexPath section];
    if (section == 0 && (rowNumber==1||rowNumber==5)) {
        return cellTrans.bounds.size.height;
    } else {
        return 50;
    }
}

- (IBAction)sliderValueChanged:(UISlider *)slidr
{
    if (slidr==self.slider) {
        NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
        [defs setFloat:slidr.value forKey:kTransparency];
    } else if (slidr==self.sliderMouseSpeed) {
        NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
        [defs setFloat:slidr.value>0?slidr.value:0.01 forKey:kMouseSpeed];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
    int row = [indexPath row];
    switch (row) {
        case 0: 
        {
            KeyPadCustomizeViewController *ctrl;
            if (ISIPAD()) {
                ctrl = [[[KeyPadCustomizeViewController alloc] initWithNibName:@"KeyPadCustomizeViewController_iPad"
                                                                        bundle:nil] autorelease];
            } else {
                ctrl = [[[KeyPadCustomizeViewController alloc] initWithNibName:@"KeyPadCustomizeViewController"
                                                                        bundle:nil] autorelease];
            }
            [self.navigationController pushViewController:ctrl animated:YES];
            break;
        }
        case 6:
        {
            //NSString *url = @"http://www.litchie.net/donate/dospad-donate.html";
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            WebViewController *webctrl=[[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil] autorelease];
            webctrl.url=[NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"credits.html"]];
            webctrl.title=@"Credits";
            [self.navigationController pushViewController:webctrl animated:YES];
            break;
        }
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    self.cellMouseSpeed=nil;
    self.cellDisableKeySound=nil;
    self.sliderMouseSpeed=nil;
    self.swDisableKeySound=nil;
    
    self.cellTrans=nil;
    self.slider=nil;
    self.cellFullScreenKeypad=nil;
    self.cellForceAspect=nil;
    self.swFullscreenKeypad=nil;
    self.swForceAspect=nil;
    [super dealloc];
}


@end

