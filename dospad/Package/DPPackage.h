/*
 *  Copyright (C) 2024-2024 Chaoji Li
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



typedef enum {
    DPPackageTypeUnknown,
    DPPackageTypeDefault,
    DPPackageTypeIDOS,
    DPPackageTypeBOXER,
} DPPackageType;

typedef enum {
    DPDriveTypeInvalid,
    DPDriveTypeFloppy,
    DPDriveTypeCdrom,
    DPDriveTypeHarddisk,
} DPDriveType;

typedef enum {
    DPDriveSourceTypeFolder,
    DPDriveSourceTypeImage,  // disk image files, .img, .ima
    DPDriveSourceTypeISO,
    DPDriveSourceTypeCUE,    // should have a accompanying .bin
} DPDriveSourceType;

@interface DPDrive: NSObject

@property (nonatomic, assign) DPDriveSourceType sourceType;
@property (nonatomic, strong) NSURL *sourceUrl;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, assign) unichar driveLetter;
@property (nonatomic, assign) DPDriveType type;

@end

@interface DPLauncher: NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *title;

@end

@interface DPPackageInfo: NSObject

@property (nonatomic, strong) NSURL* baseUrl;
@property (nonatomic, strong) NSURL* infoUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *intro;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *homepage;
@property (nonatomic, strong) NSString *autorun;
@property (nonatomic, strong) NSDictionary *automount;

- (id)initWithURL:(NSURL*)url;

@end

@interface DPPackage: NSObject
@property (nonatomic, strong) DPPackageInfo *info;
@property (nonatomic, strong) NSMutableArray<NSError *>* errors;
@property (nonatomic, strong) NSURL *baseUrl;
@property (nonatomic, assign) DPPackageType type;
@property (nonatomic, strong) NSMutableArray<NSURL*>* dosboxPreferences;
@property (nonatomic, strong) NSMutableArray<DPDrive*>* driveList; // For automount
@property (nonatomic, strong) NSString *defaultProgramPath;
@property (nonatomic, strong) NSMutableArray<DPLauncher*> *launchers;

+(DPPackage*)packageWithURL:(NSURL*)url;
- (DPDrive*)findDrive:(unichar)driveLetter;
- (NSString*)findFileInDrives:(NSURL*)url;

- (id)initWithURL:(NSURL*)url;


@end
