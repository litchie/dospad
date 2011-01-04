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
#import "Common.h"
#import "FileSystemObject.h"
#import "HoldIndicator.h"
#import "SDL_uikitopenglview.h"

@interface DOSPadBaseViewController : UIViewController
<SDL_uikitopenglview_delegate,MouseHoldDelegate>
{
    NSString *configPath;
    BOOL autoExit;
    SDL_uikitopenglview *screenView;
    HoldIndicator *holdIndicator;
}

@property (nonatomic, retain) NSString *configPath;
@property (nonatomic, assign) BOOL autoExit;
@property (nonatomic, retain) SDL_uikitopenglview *screenView;

+ (DOSPadBaseViewController*)dospadWithConfig:(NSString*)configPath;

- (void)onMouseLeftDown;
- (void)onMouseLeftUp;
- (void)onMouseRightDown;
- (void)onMouseRightUp;
- (void)onLaunchExit;
- (void)sendCommandToDOS:(NSString*)cmd;
- (void)showOption;
- (NSString*)currentCycles;
- (int)currentFrameskip;
- (BOOL)isPortrait;
- (BOOL)isLandscape;
@end
