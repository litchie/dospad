//
//  ConfigFileListController.m
//  dospad
//
//  Created by Chaoji Li on 11/25/14.
//
//

#import "ConfigFileListController.h"
#import "Common.h"
#import "AlertPrompt.h"
#import "TextViewController.h"

@interface ConfigFileListController ()
{
	NSString *_configDirectory;
	NSArray *_fileList;
}
@end

@implementation ConfigFileListController
@synthesize configDirectory = _configDirectory;

- (void)dealloc
{
	[_configDirectory release];
	[_fileList release];
	[super dealloc];
}
- (void)onUse
{
	[ConfigManager setActiveConfig:_configDirectory.lastPathComponent];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[AlertMessage show:@"App Restart Required"];
}

- (UIBarButtonItem*)activeButtonItem
{
	return [[[UIBarButtonItem alloc] initWithTitle:@"Use"
		style:UIBarButtonItemStyleDone
		target:self action:@selector(onUse)] autorelease];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_fileList = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_configDirectory error:nil] retain];

    self.navigationItem.rightBarButtonItem = [self activeButtonItem];
	if ([_configDirectory.lastPathComponent isEqualToString:[ConfigManager activeConfig]]) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	self.title = _configDirectory.lastPathComponent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
	}
	cell.textLabel.text = [_fileList objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *filename = [_fileList objectAtIndex:indexPath.row];
	if ([filename.pathExtension isEqualToString:@"cfg"]) {
		TextViewController *ctrl = [[TextViewController alloc] initWithNibName:@"TextViewController"
																				bundle:nil];
		ctrl.filePath = [_configDirectory stringByAppendingPathComponent:filename];
		[self.navigationController pushViewController:ctrl animated:YES];
		[ctrl release];
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
