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

#import "FileSystemObject.h"

@implementation FileSystemObject

+ (FileSystemObject*)sharedObject
{
    static FileSystemObject * sharedObj = nil;
    @synchronized ([FileSystemObject class]) 
    {
        if (sharedObj == nil)
        {
            sharedObj = [FileSystemObject alloc];
        }
        return sharedObj;
    }
    return nil;
}

- (NSString*)bundleDirectory
{
    return [[NSBundle mainBundle] bundlePath];
}

-(bool)ensureDirectoryExists:(NSString*)path
{
    if (![self directoryExists:path]) {
        return [self createDirectory:path];
    }
    return YES;
}

-(NSString*)homeDirectory
{
    return NSHomeDirectory();
}

-(NSString*)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    return docDirectory;
}

-(bool)createDirectory:(NSString*)path
{
    NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:0777],
                          NSFilePosixPermissions,nil];
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attr error:NULL];
}

-(bool)fileExists:(NSString*)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

-(bool)directoryExists:(NSString*)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

-(NSArray*)contentsOfDirectory:(NSString*)path
{
    NSArray *a = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    if (a==nil) return nil;
    a = [a sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return a;
}

-(NSArray*)contentsOfDirectoryWithSuffix:(NSString*)path suffix:(NSString*)suf
{
    NSArray *a = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    if (a==nil || [a count] == 0) return nil;
    NSMutableArray *ma = [NSMutableArray arrayWithCapacity:[a count]];
    for (int i = 0; i < [a count]; i++) {
        NSString *name = [a objectAtIndex:i];
        if ([name hasSuffix:suf]) {
            [ma addObject:[a objectAtIndex:i]];
        }
    }
    if ([ma count] < 1) return nil;
    return [NSArray arrayWithArray:ma];
}


-(bool)removeFileAtPath:(NSString*)path
{
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

-(unsigned long long)fileSize:(NSString *)path
{
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSNumber *number = [dict objectForKey:NSFileSize];
    return [number longLongValue];
}

-(NSDate*)modificationDate:(NSString*)path
{
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [dict objectForKey:NSFileModificationDate];
}

-(BOOL)copyFile:(NSString*)from to:(NSString*)to
{
    if ([self fileExists:to])
    {
        [self removeFileAtPath:to];
    }
    return [[NSFileManager defaultManager] copyItemAtPath:from toPath:to error:nil];
}

-(BOOL)moveFile:(NSString*)from to:(NSString*)to
{
    if (![self fileExists:from]) return NO;
    if ([self fileExists:to]) {
        [self removeFileAtPath:to];
    }
    return [[NSFileManager defaultManager] moveItemAtPath:from toPath:to error:nil];
}

@end
