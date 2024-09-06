/*
 *  Copyright (C) 2010-2024 Chaoji Li
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

#import <Foundation/Foundation.h>


@interface FileSystemObject : NSObject {

}
+ (FileSystemObject*)sharedObject;
-(NSString*)bundleDirectory;
-(NSString*)documentsDirectory;
-(NSString*)homeDirectory;
-(bool)ensureDirectoryExists:(NSString*)path;
-(bool)createDirectory:(NSString*)path;
-(bool)fileExists:(NSString*)path;
-(bool)directoryExists:(NSString*)path;
-(NSArray*)contentsOfDirectory:(NSString*)path;
-(bool)removeFileAtPath:(NSString*)path;
-(NSArray*)contentsOfDirectoryWithSuffix:(NSString*)path suffix:(NSString*)suf;
-(unsigned long long)fileSize:(NSString *)path;
-(NSDate*)modificationDate:(NSString*)path;
-(BOOL)copyFile:(NSString*)from to:(NSString*)to;
-(BOOL)moveFile:(NSString*)from to:(NSString*)to;

@end
