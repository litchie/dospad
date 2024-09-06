/*
 *  Copyright (C) 2020-2024 Chaoji Li
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

#define DPFSettingsChangedNotification @"DPSettingsChanged"

typedef NS_ENUM(NSInteger, DPScreenScaleMode) {
	DPScreenScaleModeNone,
	DPScreenScaleModeFill,
	DPScreenScaleModeAspectFit4x3,
	// Allow for 16:10, but if 4:3 is better, will use it instead
	DPScreenScaleModeAspectFit16x10,
	DPScreenScaleModeAspectFit16x9
};

NS_ASSUME_NONNULL_BEGIN

@interface DPSettings : NSObject

// If true, treat tap on screen as mouse clicks.
@property (readonly) BOOL keyPressSound;
@property (readonly) BOOL gamepadSound;
@property (readonly) BOOL tapAsClick;
@property (readonly) BOOL doubleTapAsRightClick;
@property (readonly) float mouseSpeed;
@property (readonly) DPScreenScaleMode screenScaleMode;
@property (readonly) float floatAlpha; // overlay controls
@property (readonly) BOOL showMouseHold;
@property (readonly) BOOL autoOpenLastPackage;
@property (readonly) BOOL pixelatedScaling;
@property (readonly) BOOL mouseAbsEnable;

+ (DPSettings*)shared;


@end

NS_ASSUME_NONNULL_END
