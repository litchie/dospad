//
//  ConfigManager.h
//  dospad
//
//  Created by Chaoji Li on 11/25/14.
//
//

#import <Foundation/Foundation.h>

#define kActiveConfig @"config_dir"

@interface ConfigManager : NSObject

+ (BOOL)init;
+ (NSString*)currentConfigDirectory;
+ (NSArray*)availableConfigs;
+ (NSString*)configsDirectory;
+ (NSString*)dospadConfigFile;
+ (NSString*)uiConfigFile;
+ (NSString*)activeConfig;

@end
