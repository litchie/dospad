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

#import "Common.h"
#import "DOSPadEmulator.h"
#import "KeyboardView.h"
#import "KeyView.h"
#import "FrameskipIndicator.h"
#import "FloatPanel.h"
#import "HoldIndicator.h"
#import "PianoKeyboard.h"
#import "DPSettings.h"
#import "DPScreenView.h"

typedef enum {
	DriveMount_Default,
	DriveMount_Folder,
	DriveMount_Packages,
	DriveMount_DiskImage,
	DriveMount_CDImage
} DriveMountType;

@interface DPEmulatorViewController : UIViewController

@property (nonatomic, strong) DPScreenView *screenView;

- (NSString*)currentCycles;
- (int)currentFrameskip;

-(void)updateFrameskip:(NSNumber*)skip;
-(void)updateCpuCycles:(NSString*)title;
-(void)willResignActive;
@end
