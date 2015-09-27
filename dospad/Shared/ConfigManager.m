//
//  ConfigManager.m
//  dospad
//
//  Created by Chaoji Li on 11/25/14.
//
//

#import "ConfigManager.h"
#import "Common.h"

NSString *_currentConfigDirectory = nil;

const char *dospad_config_dir()
{
    return _currentConfigDirectory.UTF8String;
}

@implementation ConfigManager

+ (NSString*)dospadConfigFile
{
	return [_currentConfigDirectory stringByAppendingPathComponent:@"dospad.cfg"];
}

+ (NSString*)uiConfigFile
{
	return [_currentConfigDirectory stringByAppendingPathComponent:@"ui.cfg"];
}

+ (NSString*)configsDirectory
{
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString *configsDir = [docDir stringByAppendingPathComponent:@"config"];
	return configsDir;
}

+ (BOOL)init
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDir = NO;
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	
	// Make sure default config dir exists
	NSString *defaultDir = [[ConfigManager configsDirectory] stringByAppendingPathComponent:@"default"];
	if (![fileManager fileExistsAtPath:defaultDir isDirectory:&isDir]) {
		if (![fileManager createDirectoryAtPath:defaultDir withIntermediateDirectories:YES attributes:nil error:nil])
			return NO;
		
	}

	// Copy default files
	{
        NSString *bundleConfigs = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"configs"];
        NSString *srcpath;
		
		
		// copy dospad.cfg to default directory
		NSString* dospadConfigFile = [defaultDir stringByAppendingPathComponent:@"dospad.cfg"];
		NSString* oldDospadConfigFile = [docDir stringByAppendingPathComponent:@"dospad.cfg"];
		srcpath = [bundleConfigs stringByAppendingPathComponent:(ISIPAD()?@"dospad-ipad.cfg":@"dospad-iphone.cfg")];
		if (![fileManager fileExistsAtPath:dospadConfigFile isDirectory:NULL]) {
			if ([fileManager fileExistsAtPath:oldDospadConfigFile isDirectory:NULL]) {
				[fileManager copyItemAtPath:oldDospadConfigFile toPath:dospadConfigFile error:nil];
			} else {
				[fileManager copyItemAtPath:srcpath toPath:dospadConfigFile error:nil];
			}
		}

		// copy ui.cfg to default directory
		NSString* uiConfigFile = [defaultDir stringByAppendingPathComponent:@"ui.cfg"];
        srcpath = [bundleConfigs stringByAppendingPathComponent:@"ui.cfg"];
		if (![fileManager fileExistsAtPath:uiConfigFile isDirectory:NULL]) {
			[fileManager copyItemAtPath:srcpath toPath:uiConfigFile error:nil];
		}
		
		// copy icon.png to default directory
		NSString* iconFile = [defaultDir stringByAppendingPathComponent:@"icon.png"];
        srcpath = [bundleConfigs stringByAppendingPathComponent:@"icon.png"];
		if (![fileManager fileExistsAtPath:iconFile isDirectory:NULL]) {
			[fileManager copyItemAtPath:srcpath toPath:iconFile error:nil];
		}
	}
	
	NSString *configName = [[NSUserDefaults standardUserDefaults] stringForKey:kActiveConfig];
	if (configName == nil) {
		configName = @"default";
		[[NSUserDefaults standardUserDefaults] setObject:configName forKey:kActiveConfig];
	} else {
		NSString *dirPath = [[ConfigManager configsDirectory] stringByAppendingPathComponent:configName];
		if (![fileManager fileExistsAtPath:dirPath isDirectory:&isDir] || !isDir) {
			configName = @"default";
			[[NSUserDefaults standardUserDefaults] setObject:configName forKey:kActiveConfig];
		}
	}

	_currentConfigDirectory = [[[ConfigManager configsDirectory] stringByAppendingPathComponent:configName] retain];
	return YES;
}

+ (NSArray*)availableConfigs
{
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[ConfigManager configsDirectory] error:nil];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableArray *avail = [NSMutableArray array];
	for (NSString *configName in contents) {
		BOOL isDir = NO;
		NSString *fullPath = [[ConfigManager configsDirectory] stringByAppendingPathComponent:configName];
		if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) {
			[avail addObject:configName];
		}
	}
	return avail;
}

+ (NSString*)currentConfigDirectory
{
	return _currentConfigDirectory;
}

+ (NSString*)activeConfig
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:kActiveConfig];
}

@end
