//
//  DPPackage.m
//  iDOS
//
//  Created by Chaoji Li on 2024/8/17.
//

#import <Foundation/Foundation.h>
#import "DPPackage.h"

#define IDOS_INFO_FILE @"idos.json"

@implementation DPDrive
@end

@implementation DPLauncher
@end


@interface DPPackageInfo ()
{
	BOOL _modified;
}
@end

@implementation DPPackageInfo

- (id)initWithURL:(NSURL*)url {
    if (self = [super init]) {
        self.baseUrl = url;
        self.infoUrl = [url URLByAppendingPathComponent:IDOS_INFO_FILE];
        NSData *data = [NSData dataWithContentsOfURL:self.infoUrl];
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data
            options:NSJSONReadingMutableContainers error:&error];
        if (!error && [jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)jsonObject;
            self.name = dict[@"name"]; // The name of the package
            self.version = dict[@"version"]; // The version of the package
            self.intro = dict[@"intro"]; // introduction of the package
            self.autorun = dict[@"autorun"]; // default program to run on start up
            self.homepage = dict[@"homepage"];
            self.author = dict[@"author"];
            
            for (NSString *iconName in @[@"icon.png", @"cover.png"]) {
                NSString *iconPath = [self.baseUrl.path stringByAppendingPathComponent:iconName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
                    self.icon = iconName;
                }
            }
            
            if (!self.autorun) {
                for (NSString *name in @[@"autorun.bat", @"AUTORUN.BAT"]) {
                    NSString *path = [self.baseUrl.path stringByAppendingPathComponent:name];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                        self.autorun = name;
                    }
                }
            }
            
            // TODO load automount drive list here
            // TODO load gamepad configuration
            // TODO load custom keyboard
            // TODO load theme
            
            if (!self.name || !self.version) {
                return nil;
            }
        } else {
            return nil;
        }
    }
    return self;
}

- (void)setIcon:(NSString *)icon
{
    _icon = icon;
    _modified = YES;
}

- (void)setAutorun:(NSString *)filename
{
    _autorun = filename;
    _modified = YES;
}

@end

@implementation DPPackage

- (id)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        self.baseUrl = url;
        self.errors = [NSMutableArray array];
        self.driveList = [NSMutableArray array];
        if ([self.baseUrl.path.pathExtension isEqualToString:@"idos"]) {
            self.type = DPPackageTypeIDOS;
        } else if ([self.baseUrl.path.pathExtension isEqualToString:@"boxer"]) {
            self.type = DPPackageTypeBOXER;
        } else {
            NSURL *docsUrl = [NSURL fileURLWithPath:[
                NSSearchPathForDirectoriesInDomains(
                    NSDocumentDirectory, NSUserDomainMask, YES
                )
                lastObject
            ]];
            if ([url.path isEqualToString:docsUrl.path]) {
                self.type = DPPackageTypeDefault;
            } else {
                self.type = DPPackageTypeUnknown;
            }
        }
        [self scan];
        
        if (self.driveList.count == 0) {
            DPDrive *drive = [[DPDrive alloc] init];
            drive.type = DPDriveTypeHarddisk;
            drive.driveLetter = 'C';
            drive.sourceUrl = url;
            drive.sourceType = DPDriveSourceTypeFolder;
            [self.driveList addObject:drive];
        }
    }
    return self;
}

- (void)scan {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:self.baseUrl
        includingPropertiesForKeys:nil
        options:NSDirectoryEnumerationSkipsHiddenFiles
        error:&error];
    
    if (error) {
        NSLog(@"Error listing directory contents: %@", error);
        [self.errors addObject:error];
        return;
    }
    
    for (NSURL *fileURL in contents) {
        BOOL isDirectory = NO;
        [fileManager fileExistsAtPath:[fileURL path] isDirectory:&isDirectory];
        NSString *basename = fileURL.lastPathComponent.stringByDeletingPathExtension;
        NSString *ext = fileURL.lastPathComponent.pathExtension;
        
        NSLog(@"DPPackage scan: %@ isDir=%d", [fileURL path], isDirectory);
        if (isDirectory) {
            if (self.type == DPPackageTypeIDOS && [fileURL.lastPathComponent isEqualToString:@"config"]) {
                [self scanIDOSConfigFolder:fileURL];
                continue;
            }
            
            if (self.type == DPPackageTypeUnknown) {
                continue; // Do not interpret special disk folder
            }
            
            DPDriveType driveType = DPDriveTypeInvalid;
            if ([ext isEqualToString:@"floppy"]) {
                driveType = DPDriveTypeFloppy;
            } else if ([ext isEqualToString:@"harddisk"]) {
                driveType = DPDriveTypeHarddisk;
            } else if ([ext isEqualToString:@"cdrom"]) {
                driveType = DPDriveTypeCdrom;
            }
            if (driveType != DPDriveTypeInvalid) {
                DPDrive *drive = [[DPDrive alloc] init];
                drive.type = driveType;
                drive.driveLetter = toupper([basename characterAtIndex:0]);
                                
                drive.label = [[basename substringFromIndex:1]
                stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"- "]
                ];
                drive.sourceUrl = fileURL;
                drive.sourceType = DPDriveSourceTypeFolder;
                [self.driveList addObject:drive];
            }
        } else {
            if (self.type == DPPackageTypeIDOS && [fileURL.lastPathComponent isEqualToString:IDOS_INFO_FILE]) {
                [self loadIDOSPackageInfo];
            } else if (self.type == DPPackageTypeBOXER && [fileURL.lastPathComponent isEqualToString:@"Game Info.plist"]) {
                [self loadBoxerGameInfo:fileURL];
            } else if ([basename isEqualToString:@"DOSBox Preferences"] ||
                [fileURL.lastPathComponent.lowercaseString isEqualToString:@"dosbox.conf"] ||
                [fileURL.lastPathComponent.lowercaseString isEqualToString:@"dospad.cfg"]) {
                [self.dosboxPreferences addObject:fileURL];
            }
        }
    }
}

- (void)scanIDOSConfigFolder:(NSURL*)url {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:url
                                   includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:&error];
    
    if (error) {
        NSLog(@"Error listing directory contents: %@", error);
        [self.errors addObject:error];
        return;
    }
    
    for (NSURL *fileURL in contents) {
        BOOL isDirectory = NO;
        [fileManager fileExistsAtPath:[fileURL path] isDirectory:&isDirectory];
        NSString *basename = fileURL.lastPathComponent.stringByDeletingPathExtension;
        NSString *ext = fileURL.lastPathComponent.pathExtension;
        if ([fileURL.lastPathComponent.lowercaseString isEqualToString:@"dospad.cfg"]) {
            [self.dosboxPreferences addObject:fileURL];
        }
    }
}

- (void)loadIDOSPackageInfo {
    self.info = [[DPPackageInfo alloc] initWithURL:self.baseUrl];
    if (self.info.autorun) {
        self.defaultProgramPath = self.info.autorun;
    }
}

- (void)loadBoxerGameInfo:(NSURL*)url {
   NSDictionary *gameInfo = [NSDictionary dictionaryWithContentsOfURL:url];
   
   self.defaultProgramPath = gameInfo[@"BXDefaultProgramPath"];
   NSArray *launchers = gameInfo[@"BXLaunchers"];
   if (launchers) {
        for (NSDictionary *l in launchers) {
            DPLauncher *x = [[DPLauncher alloc] init];
            x.title = l[@"BXLauncherTitle"];
            x.path = l[@"BXLauncherPath"];
            [self.launchers addObject:x];
        }
   }
}

- (DPDrive*)findDrive:(unichar)driveLetter {
    for (DPDrive *drv in self.driveList) {
        if (drv.driveLetter == driveLetter) {
            return drv;
        }
    }
    return nil;
}


// Given a URL of a file, search for it in the driveList and
// return a full path in DOS file system, e.g. "C:\foo\bar.exe".
// Return nil if the file is not found.
- (NSString*)findFileInDrives:(NSURL*)url {
    if (![[NSFileManager defaultManager] fileExistsAtPath:url.path])
        return nil;

    for (DPDrive *drv in self.driveList) {
        NSRange range = [url.path rangeOfString:drv.sourceUrl.path];
        
        if (range.location == 0 && range.length > 0) {
            // `url` starts with the drive source url
            if (url.path.length == range.length) {
                return [NSString stringWithFormat:@"%c:\\", drv.driveLetter];
            } else if (url.path.length > range.length &&
                [url.path characterAtIndex:range.length] == '/')
            {
                NSString *pathInDrive = [[url.path substringFromIndex:range.length+1].pathComponents componentsJoinedByString:@"\\"];
                return [NSString stringWithFormat:@"%c:\\%@", drv.driveLetter, pathInDrive];
            }
        }
    }
    return nil;
}

+ (DPPackage *)packageWithURL:(NSURL *)url {
    DPPackage *p = [[DPPackage alloc] initWithURL:url];
    return p;
}

@end
