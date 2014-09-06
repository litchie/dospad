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
#import "WebViewController.h"
#import "TextViewController.h"

/* Here we are assuming that there are not more than 8 groups
 and at most 32 items in a single group. 
 Doing so will help clever compiler to build efficient branch table.
 Although the performance doesn't matter here, yet
 no harm doing so.
 */
#define OPT_ID(section,row) (((section)<<5)|(row))
#define ROW_OF(id)          ((id)&0x1f)
#define SECTION_OF(id)      ((section)>>5)

//--------------------------------------------------------------
enum {
    #ifndef IDOS
    OPT_GROUP_DONATE,
    #endif
    OPT_GROUP_GENERAL,
    OPT_GROUP_LANDSCAPE_INPUTS,
    OPT_GROUP_SUPPORT,
    OPT_GROUP_COUNT
};

//--------------------------------------------------------------
#ifndef IDOS
#define OPT_DONATE                   OPT_ID(OPT_GROUP_DONATE,0)
#define OPT_GROUP_DONATE_COUNT 1
#endif

#define OPT_GAME_CONTROL             OPT_ID(OPT_GROUP_GENERAL,0)
#define OPT_OVERLAY_TRANSPARENCY     OPT_ID(OPT_GROUP_GENERAL,1)
#define OPT_DPAD_MOVABLE             OPT_ID(OPT_GROUP_GENERAL,2)
#define OPT_KEY_SOUND                OPT_ID(OPT_GROUP_GENERAL,3)
#define OPT_GAMEPAD_SOUND            OPT_ID(OPT_GROUP_GENERAL,4)
#define OPT_MOUSE_SPEED              OPT_ID(OPT_GROUP_GENERAL,5)
#define OPT_GROUP_GENERAL_COUNT 6

#define OPT_INPUT_NUMPAD             OPT_ID(OPT_GROUP_LANDSCAPE_INPUTS, 0)
#define OPT_INPUT_JOYSTICK           OPT_ID(OPT_GROUP_LANDSCAPE_INPUTS, 1)
#ifndef IDOS
#define OPT_INPUT_PIANO              OPT_ID(OPT_GROUP_LANDSCAPE_INPUTS, 2)
#define OPT_GROUP_LANDSCAPE_INPUTS_COUNT 3
#else
#define OPT_GROUP_LANDSCAPE_INPUTS_COUNT 2
#endif

#define OPT_CREDITS                  OPT_ID(OPT_GROUP_SUPPORT,0)
#define OPT_HOMEPAGE                 OPT_ID(OPT_GROUP_SUPPORT,1)
#define OPT_FEEDBACK                 OPT_ID(OPT_GROUP_SUPPORT,2)
#define OPT_FORUM                    OPT_ID(OPT_GROUP_SUPPORT,3)
#define OPT_GROUP_SUPPORT_COUNT 4

#define CELL_HEIGHT_NORMAL  50
#define CELL_HEIGHT_SLIDER  72

@implementation OptionViewController
@synthesize cellTrans,slider;
@synthesize cellMouseSpeed;
@synthesize sliderMouseSpeed;
@synthesize configPath;

#pragma mark Event Handlers


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

-(IBAction)switchValueChanged:(UISwitch*)sw
{
    switch (sw.tag)
    {
        case OPT_DPAD_MOVABLE:
            DEFS_SET_INT(kDPadMovable, sw.on);
            break;
        case OPT_GAMEPAD_SOUND:
            DEFS_SET_INT(kDisableGamePadSound, sw.on);
            break;
        case OPT_KEY_SOUND:
            DEFS_SET_INT(kDisableKeySound, sw.on);
            break;
#ifndef IDOS
        case OPT_INPUT_PIANO:
            DEFS_SET_INT(InputSource_KeyName(InputSource_PianoKeyboard), sw.on);
            break;
#endif            
        case OPT_INPUT_NUMPAD:
            DEFS_SET_INT(InputSource_KeyName(InputSource_NumPad), sw.on);
            break;
        case OPT_INPUT_JOYSTICK:
            DEFS_SET_INT(InputSource_KeyName(InputSource_Joystick), sw.on);
            break;            
    }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults*defs=[NSUserDefaults standardUserDefaults];
    self.slider.value=[defs floatForKey:kTransparency];
    self.sliderMouseSpeed.value=[defs floatForKey:kMouseSpeed];
    self.title = @"Settings";
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}


-(void) mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error 
{
    [controller dismissModalViewControllerAnimated:YES];
}


-(void)sendFeedback
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	if (controller == nil)
		return;
    controller.mailComposeDelegate = self;
    #ifndef IDOS
    [controller setSubject:@"Feedback on DOSPad"];
    #else
    [controller setSubject:@"Feedback on iDOS"];
    #endif
    NSArray *recip = [NSArray arrayWithObject:@"support@litchie.com"];
    [controller setToRecipients:recip];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return OPT_GROUP_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    switch (section)
    {
#ifndef IDOS
        case OPT_GROUP_DONATE:
            return OPT_GROUP_DONATE_COUNT;
#endif            
        case OPT_GROUP_GENERAL:
            return OPT_GROUP_GENERAL_COUNT;
        case OPT_GROUP_LANDSCAPE_INPUTS:
            return OPT_GROUP_LANDSCAPE_INPUTS_COUNT;
        case OPT_GROUP_SUPPORT:
            return OPT_GROUP_SUPPORT_COUNT;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
#ifndef IDOS
        case OPT_GROUP_DONATE:
            return @"";
#endif
        case OPT_GROUP_GENERAL:
            return @"General";
        case OPT_GROUP_LANDSCAPE_INPUTS:
            return @"Optional Input Sources";
        case OPT_GROUP_SUPPORT:
            return @"Support";
        default:
            return @"";
    }    
}

- (UITableViewCell*)createBooleanOptionCell:(NSString*)title on:(BOOL)on tag:(int)tag
{
    UITableViewCell *cell;

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = title;
    
    // Switch size: 90x30
    CGRect rect = CGRectMake(220, (CELL_HEIGHT_NORMAL-30)/2, 90, 30);
    UISwitch *sw = [[UISwitch alloc] initWithFrame:rect];
    sw.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|
                           UIViewAutoresizingFlexibleBottomMargin|
                           UIViewAutoresizingFlexibleLeftMargin);
    sw.tag = tag;
    sw.on = on;
    [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:sw];
    [sw release];
    return cell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = nil;

    int section = [indexPath section];
    int row = [indexPath row];
    switch (OPT_ID(section, row)) 
    {
        case OPT_GAME_CONTROL:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text=@"Customize config";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            return [cell autorelease];
        }
        case OPT_OVERLAY_TRANSPARENCY:
        {
            return cellTrans;
        }
        case OPT_DPAD_MOVABLE:
        {
            cell = [self createBooleanOptionCell:@"DPad Movable" 
                                              on:DEFS_GET_INT(kDPadMovable)
                                             tag:OPT_DPAD_MOVABLE];
            return [cell autorelease];
        }
        case OPT_KEY_SOUND:
        {
            cell = [self createBooleanOptionCell:@"Disable Key Sound" 
                                              on:DEFS_GET_INT(kDisableKeySound)
                                             tag:OPT_KEY_SOUND];
            return [cell autorelease];
        }            
        case OPT_MOUSE_SPEED:
        {
            return cellMouseSpeed;
        }
        case OPT_GAMEPAD_SOUND:
        {
            cell = [self createBooleanOptionCell:@"Disable GamePad Sound"
                                              on:DEFS_GET_INT(kDisableGamePadSound)
                                             tag:OPT_GAMEPAD_SOUND];
            return [cell autorelease];
        }
#ifndef IDOS            
        case OPT_INPUT_PIANO:
        {
            cell = [self createBooleanOptionCell:@"Piano Keyboard"
                                              on:DEFS_GET_INT(InputSource_KeyName(InputSource_PianoKeyboard))
                                             tag:OPT_INPUT_PIANO];
            return [cell autorelease];
        }
#endif        
        case OPT_INPUT_NUMPAD:
        {
            cell = [self createBooleanOptionCell:@"Number Pad"
                                              on:DEFS_GET_INT(InputSource_KeyName(InputSource_NumPad))
                                             tag:OPT_INPUT_NUMPAD];
            return [cell autorelease];
        }
        case OPT_INPUT_JOYSTICK:
        {
            cell = [self createBooleanOptionCell:@"Joystick"
                                              on:DEFS_GET_INT(InputSource_KeyName(InputSource_Joystick))
                                             tag:OPT_INPUT_JOYSTICK];
            return [cell autorelease];
        }
#ifndef IDOS           
        case OPT_DONATE:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.textLabel.text=@"Donate to development";
			cell.imageView.image = [UIImage imageNamed:@"gift"];
            return [cell autorelease];
        }
#endif            
        case OPT_CREDITS:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text=@"Credits and Thanks";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            return [cell autorelease];
        }
            
        case OPT_FORUM:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.textLabel.text=@"iDOS/DOSPad Forum";
            cell.detailTextLabel.text=@"Ask for help in our community";
            return [cell autorelease];
        }
        case OPT_HOMEPAGE:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.textLabel.text=@"DOSPad Home Page";
            cell.detailTextLabel.text=@"Getting Started";
            return [cell autorelease];            
        }
        case OPT_FEEDBACK:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text=@"Send Feedback/Bug Report";
            return [cell autorelease];            
        }
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section)
    {
		case OPT_GROUP_SUPPORT:
			return [NSString stringWithFormat:@"version %@", BUILD_VERSION];

        default:
            return @"";
    }
}

-(CGFloat) tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSUInteger rowNumber = [indexPath row];
    NSUInteger section = [indexPath section];
    switch (OPT_ID(section,rowNumber))
    {
        case OPT_OVERLAY_TRANSPARENCY:
        case OPT_MOUSE_SPEED:
            return CELL_HEIGHT_SLIDER;
        default:
            return CELL_HEIGHT_NORMAL;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    int section = [indexPath section];
    int row = [indexPath row];
    switch (OPT_ID(section, row))
    {
        case OPT_GAME_CONTROL: 
        {
            TextViewController *ctrl = [[TextViewController alloc] initWithNibName:@"TextViewController"
                                                                            bundle:nil];
            ctrl.filePath = configPath == nil ? get_dospad_config() : configPath;
            [self.navigationController pushViewController:ctrl animated:YES];
            [ctrl release];
            break;
        }
        case OPT_CREDITS:
        {
            WebViewController *webctrl=[[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil] autorelease];
            webctrl.url=[NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"credits.html"]];
            webctrl.title=@"Credits";
            [self.navigationController pushViewController:webctrl animated:YES];
            break;
        }
        case OPT_FORUM:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.litchie.com/forum/viewforum.php?f=8"]];
            break;
        }
        case OPT_HOMEPAGE:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.litchie.com/blog/?page_id=123"]];
            break;
        }
		
		case OPT_FEEDBACK:
		{
		   [self sendFeedback];
		   break;
		}
			
#ifndef IDOS
        case OPT_DONATE:
        {
            NSString *url = @"http://www.litchie.com/dospad/donate";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
#endif        
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
    self.sliderMouseSpeed=nil;
    
    self.cellTrans=nil;
    self.slider=nil;
    [configPath release];
    [super dealloc];
}


@end

