//
//  ConfigManager.h
//  dospad
//
//  Created by Chaoji Li on 11/25/14.
//
//

#import <Foundation/Foundation.h>

#define kActiveConfig @"ActiveConfig"

@interface ConfigManager : NSObject

+ (BOOL)init;
+ (NSString*)currentConfigDirectory;
+ (NSArray*)availableConfigs;
+ (NSString*)configsDirectory;
+ (NSString*)dospadConfigFile;
+ (NSString*)uiConfigFile;
+ (NSString*)activeConfig;
+ (BOOL)setActiveConfig:(NSString*)configName;

@end
