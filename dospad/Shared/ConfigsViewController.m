//
//  ConfigsViewController.m
//  dospad
//
//  Created by Chaoji Li on 11/25/14.
//
//

#import "ConfigsViewController.h"
#import "Common.h"
#import "ConfigFileListController.h"

@interface ConfigsViewController ()
{
	NSArray *_configs;
}
@end

@implementation ConfigsViewController

- (void)dealloc
{
	[_configs release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_configs = [[ConfigManager availableConfigs] retain];
	self.title = @"Configurations";
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return _configs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
	}
	
	NSString *cname =[_configs objectAtIndex:indexPath.row];
	cell.textLabel.text = cname;
	if ([[ConfigManager activeConfig] isEqualToString:cname]) {
		cell.textLabel.textColor = [UIColor blueColor];
	} else {
		cell.textLabel.textColor = [UIColor blackColor];
	}
	NSString *iconFile = [[[ConfigManager configsDirectory] stringByAppendingPathComponent:cname] stringByAppendingPathComponent:@"icon.png"];
	//UIImage *image = [UIImage imageWithContentsOfFile:iconFile];
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:iconFile] scale:2.0];
	cell.imageView.image = image;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *cname =[_configs objectAtIndex:indexPath.row];
	ConfigFileListController *ctrl = [[ConfigFileListController alloc] initWithStyle:UITableViewStylePlain];
	ctrl.configDirectory = [[ConfigManager configsDirectory] stringByAppendingPathComponent:cname];
	[self.navigationController pushViewController:ctrl animated:YES];
	[ctrl release];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		NSString *configName = [_configs objectAtIndex:indexPath.row];
		NSString *fullPath = [[ConfigManager configsDirectory] stringByAppendingPathComponent:configName];
		[[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
		_configs = [[ConfigManager availableConfigs] retain];		
		[tableView reloadData];
    }
}

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
