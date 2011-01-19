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

#import <UIKit/UIKit.h>
#import "FileSystemObject.h"
#import "Common.h"
#import "ZipArchive.h"

extern char automount_path[];

char dospad_error_msg[1000];
char diskc[256];
char diskd[256];
cmd_entry *cmd_list=0;
int cmd_count=0;
int dospad_pause_flag = 0;
int dospad_should_launch_game=0;
int dospad_command_line_ready=0;
char dospad_launch_config[256];
char dospad_launch_section[256];

void dospad_pause()
{
    dospad_pause_flag = 1;
}

void dospad_resume()
{
    dospad_pause_flag = 0;
}

void dospad_launch_done()
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(onLaunchExit)])
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(onLaunchExit)];
    }
}

NSString *get_temporary_merged_file(NSString *f1, NSString *f2)
{
    NSString *f = [NSTemporaryDirectory() stringByAppendingPathComponent:@"cfgtmp"];
    NSString *s = [NSString stringWithContentsOfFile:f1
                                            encoding:NSUTF8StringEncoding
                                               error:NULL];
    s = [s stringByAppendingString:@"\n"];
    s = [s stringByAppendingString:[NSString stringWithContentsOfFile:f2
                                                             encoding:NSUTF8StringEncoding
                                                                error:NULL]];
    [s writeToFile:f
        atomically:YES  
          encoding:NSUTF8StringEncoding
             error:NULL];  
    return f;
}


NSString *get_default_config()
{
    NSString *srcpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"configs"];
    srcpath = [srcpath stringByAppendingPathComponent:@"default.cfg"];  
    return srcpath;
}

NSString *get_dospad_config()
{
    NSString *cfg;
    FileSystemObject *fso = [[FileSystemObject alloc] autorelease];
    NSString *cfgDir = [NSString stringWithUTF8String:diskc];
    NSString *filename= @"dospad.cfg";
    cfg = [cfgDir stringByAppendingPathComponent:filename];
    NSString *cfg_uc = [cfgDir stringByAppendingPathComponent:[filename uppercaseString]];
    if ([fso fileExists:cfg]) 
    {
        /* This is good */
    } 
    else if ([fso fileExists:cfg_uc]) 
    {
        cfg = cfg_uc;
    } 
    else 
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *srcpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"configs"];
        srcpath = [srcpath stringByAppendingPathComponent:(ISIPAD()?@"dospad-ipad.cfg":@"dospad-iphone.cfg")];  
        if (![fso fileExists:srcpath])
            return nil;
        cfg = [cfgDir stringByAppendingPathComponent:@"dospad.cfg"];
        [fileManager copyItemAtPath:srcpath toPath:cfg error:NULL];
    }

    return cfg;
}

static int strcmp_case_insensitive(const char *cs, const char *ct)
{
    while (*cs && *ct) {
        if (toupper(*cs) < toupper(*ct)) 
            return -1;
        else if (toupper(*cs) > toupper(*ct))
            return 1;
        cs++, ct++;
    }
    if (*cs == 0 && *ct == 0) return 0;
    else if (*cs) return 1;
    else return -1;
}

#define ISBLANK(c) (c==' '||c=='\t'||c=='\n'||c=='\r')

void dospad_add_history(const char* cmd)
{
    int i;
    if (strlen(cmd) < 2) {
        return;
    }
    cmd_entry *entry = malloc(sizeof(cmd_entry));
    memset(entry, 0, sizeof(cmd_entry));
    for (i = 0; cmd[i]; i++) {
        entry->cmd[i] = cmd[i];
        if (i > 250) {
            entry->cmd[i]=0;
            break;
        }
    }
    while (--i>=0) {
        if (!ISBLANK(entry->cmd[i]))
            break;
        else
            entry->cmd[i]=0;
    }
    if (cmd_list==0) {
        cmd_list=entry;
        cmd_count++;
    } else {
        cmd_entry *p;
        entry->next=cmd_list;
        cmd_list=entry;
        cmd_count++;
        for (p = cmd_list; p && p->next; p=p->next) {
            if (strcmp_case_insensitive(cmd, p->next->cmd)==0) {
                cmd_entry *tmp = p->next;
                p->next = tmp->next;
                free(tmp);
                cmd_count--;
            }
        }
    }
}

void dospad_save_history()
{
    NSString *path=[[NSString stringWithUTF8String:diskc] stringByAppendingPathComponent:@"HISTORY"];
    FILE *fp = fopen([path UTF8String], "w");
    if (fp == NULL) {
        return;
    }
    cmd_entry *p = cmd_list;
    int cnt=MAX_HISTORY_ITEMS;
    while (p && cnt-- > 0) {
        fprintf(fp, "%s\n", p->cmd);
        p = p->next;
    }
    fclose(fp);
}

void dospad_init_history()
{
    char buf[256];
    
    NSString *path=[[NSString stringWithUTF8String:diskc] stringByAppendingPathComponent:@"HISTORY"];
    FILE *fp = fopen([path UTF8String], "r");
    if (fp == NULL) {
        return;
    }
    
    while (fgets(buf, 256, fp)) {
        dospad_add_history(buf);
    }
    
    fclose(fp);
}

void dospad_should_pause()
{
    while (dospad_pause_flag)
    {
        [NSThread sleepForTimeInterval:0.5];
    }
}

const char *dospad_config_dir()
{
    return diskc;
}

static void fixsep(char*path)
{
    char *p = path;
    while (*p) {
        if (*p == '\\') *p = '/';
        p++;
    }    
}

int dospad_unzip(const char *file, const char *path)
{
    // Convert \ to /
    char destPath[256];
    char srcFile[256];
    strcpy(srcFile, file);
    strcpy(destPath, path);
    fixsep(destPath);
    fixsep(srcFile);
    
    // Data Path is where we put the extracted files
    FileSystemObject *fso = [[FileSystemObject alloc] autorelease];
    NSString *dataPath = [[NSString stringWithUTF8String:diskc]
                          stringByAppendingPathComponent:[NSString stringWithUTF8String:destPath]];
    dataPath = [dataPath stringByStandardizingPath];
    
    // Zip file is the source
    // we need to do special things when the zip file has absolute path
    NSString *zipFile = [NSString stringWithUTF8String:srcFile];
    if ([zipFile hasPrefix:@"c:/"] || [zipFile hasPrefix:@"c:/"]) {
        zipFile = [zipFile substringFromIndex:3];
        zipFile = [[NSString stringWithUTF8String:diskc]stringByAppendingPathComponent:zipFile];
    } else if ([zipFile hasPrefix:@"/"]) {
        zipFile = [zipFile substringFromIndex:1];
        zipFile = [[NSString stringWithUTF8String:diskc]stringByAppendingPathComponent:zipFile];
    }  else {
        zipFile = [dataPath stringByAppendingPathComponent:zipFile];
    }
    zipFile = [zipFile stringByStandardizingPath];
    if (![fso fileExists:zipFile]) {
        NSString *f = [zipFile lastPathComponent];
        NSString *d = [zipFile stringByDeletingLastPathComponent];
        f = [f lowercaseString];
        if ([fso fileExists:[d stringByAppendingPathComponent:f]]) {
            zipFile = [d stringByAppendingPathComponent:f];
        } else {
            f = [f uppercaseString];
            if ([fso fileExists:[d stringByAppendingPathComponent:f]]) {
                zipFile = [d stringByAppendingPathComponent:f];
            } else {
                sprintf(dospad_error_msg, 
                        "File not found: `%s'.",
                        srcFile);
                return 0;
            }
        }
    }
    // Do unzip
    ZipArchive *archive = [[ZipArchive alloc] autorelease];
    BOOL bRet = [archive UnzipOpenFile:zipFile];
    if (!bRet) {
        sprintf(dospad_error_msg, "Error unzip open file `%s'", [zipFile UTF8String]);
        return 0;
    }
    bRet = [archive UnzipFileTo:dataPath overWrite:YES];
    if (!bRet) {
        sprintf(dospad_error_msg, "Error unzip `%s' to %s", [zipFile UTF8String], [dataPath UTF8String]);
        return 0;
    }
    bRet = [archive UnzipCloseFile];
    if (!bRet) {
        sprintf(dospad_error_msg, "Error unzip close file `%s'", [zipFile UTF8String]);
        return 0;
    }
    return 1;
}

int dospad_get(const char *url, const char *path)
{
    char destPath[256];
    strcpy(destPath, path);
    fixsep(destPath);
    sprintf(dospad_error_msg, "Error");
#ifdef IDOS // You can't download games in iDOS (appstore version)
    sprintf(dospad_error_msg, "No such command:-(");
    return 0;
#endif
    // Hyperlinked URL
    NSString *fileUrl = [NSString stringWithUTF8String:url];
    if (![fileUrl hasPrefix:@"http://"] && ![fileUrl hasPrefix:@"ftp://"]) {
        fileUrl = [NSString stringWithFormat:@"http://%@",fileUrl];
    }
    
    // Synchronous Download
    NSURLRequest *q=[NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 timeoutInterval:30.0];    
    
    NSData *data = [NSURLConnection sendSynchronousRequest:q
                                         returningResponse:nil error:nil];    
    
    if (data == nil || [data length]==0) return 0;
    
    // Store it to local file
    FileSystemObject *fso = [[FileSystemObject alloc] autorelease];
    NSString *dataPath = [NSString stringWithUTF8String:diskc];
    dataPath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%s",destPath]];
    dataPath = [dataPath stringByStandardizingPath];
    NSString *filename = [fileUrl lastPathComponent];
    if (filename == nil || [filename isEqualToString:@"/"]) {
        filename = @"NONAME";
    }
    dataPath = [dataPath stringByAppendingPathComponent:filename];
    return [data writeToFile:dataPath atomically:NO];
}


int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    // Initialize Options
    NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
    int firstRun = [defs integerForKey:kFirstRun];
    if (firstRun==0) {
        [defs setFloat:kTransparencyDefault forKey:kTransparency];
        [defs setInteger:1 forKey:kFirstRun];
    }
    
    if ([defs floatForKey:kMouseSpeed]==0) {
        [defs setFloat:0.5 forKey:kMouseSpeed];
    }
    
    if (DEFS_GET_INT(kInputSource) < 1) {
        DEFS_SET_INT(kInputSource, 1);
        DEFS_SET_INT(InputSource_KeyName(InputSource_PCKeyboard), 1);
        DEFS_SET_INT(InputSource_KeyName(InputSource_MouseButtons), 1);
        DEFS_SET_INT(InputSource_KeyName(InputSource_NumPad), 1);
        DEFS_SET_INT(InputSource_KeyName(InputSource_GamePad), 1);
        DEFS_SET_INT(InputSource_KeyName(InputSource_Joystick), 1);
        DEFS_SET_INT(InputSource_KeyName(InputSource_PianoKeyboard), 0);
    }

    FileSystemObject *fso = [[FileSystemObject alloc] autorelease];

    // Auto mount
#ifndef IDOS // DOSPAD for CYDIA
    strcpy(diskc, "/var/mobile/Documents");
    strcpy(diskd, [[fso documentsDirectory] UTF8String]);
#else
    strcpy(diskc, [[fso documentsDirectory] UTF8String]);
    strcpy(diskd, "/var/mobile/Documents");
#endif
    
    NSString *cPath=[NSString stringWithUTF8String:diskc];
    NSString *dPath=[NSString stringWithUTF8String:diskd];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Copy files to C disk (documents)
    NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"diskc"];
    NSArray *items = [fso contentsOfDirectory:bundlePath];
    for (int i = 0; i < [items count]; i++) {
        NSString *dataPath = [cPath stringByAppendingPathComponent:[items objectAtIndex:i]];
        if (![fileManager fileExistsAtPath:dataPath]) {
            NSString *p = [bundlePath stringByAppendingPathComponent:[items objectAtIndex:i]];
            if (p) {
                [fileManager copyItemAtPath:p toPath:dataPath error:NULL];
            }
        }
    }
    
    // Initalize command history
    dospad_init_history();
    
    get_dospad_config();
     
    if ([fso ensureDirectoryExists:cPath]) {
        strcpy(automount_path, [cPath UTF8String]);
#ifndef IDOS
        strcat(automount_path, ";");
#endif
    }
#ifndef IDOS    
    if ([fso ensureDirectoryExists:dPath]) {
        strcat(automount_path, [dPath UTF8String]);
    }
#endif    
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
