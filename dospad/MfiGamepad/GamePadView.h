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

#import <UIKit/UIKit.h>

typedef enum
{
    DPadNone,
    DPadRight,
    DPadRightUp,
    DPadUp,
    DPadLeftUp,
    DPadLeft,
    DPadLeftDown,
    DPadDown,
    DPadRightDown
} DPadDirection;

@interface DPadView : UIView
{
    DPadDirection currentDirection;
    float minDistance;
    BOOL useArrowsKeys;
    BOOL quiet;
    UIImage *backgroundImage;
    UIImage *centerStickImage;
    UIImage *sidedStickImage;
    NSArray *images;
}

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *centerStickImage;
@property (nonatomic, strong) UIImage *sidedStickImage;
@property (nonatomic, assign) DPadDirection currentDirection;
@property (nonatomic, assign) BOOL useArrowKeys;
@property (nonatomic, assign) BOOL quiet;

@end

typedef enum
{
    GamePadButtonStyleRoundedRectangle,
    GamePadButtonStyleCircle,
} GamePadButtonStyle;
    

@interface GamePadButton : UIView
{
    int keyCode;
    int keyCode2;
    int buttonIndex;
    BOOL pressed;
    NSString *title;
    GamePadButtonStyle style;
    NSArray *images;
    BOOL quiet;
    BOOL joy;
    BOOL showFire;
    UIColor *textColor;
}

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) int buttonIndex;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL pressed;
@property (nonatomic, assign) int keyCode;
@property (nonatomic, assign) int keyCode2;
@property (nonatomic, assign) GamePadButtonStyle style;
@property (nonatomic, assign) BOOL joy;
@property (nonatomic, assign) BOOL quiet;
@property (nonatomic, assign) BOOL showFire;
@end


#define MAX_GAMEPAD_BUTTON  10

typedef enum
{
    GamePadDefault = 0,
    GamePadJoystick
} GamePadMode;

@interface GamePadView : UIView {
    DPadView *dpad;
    GamePadButton* btn[MAX_GAMEPAD_BUTTON];
    BOOL floating;
    GamePadMode mode;
    BOOL dpadMovable; /* Only effective in floating mode */
}

@property (nonatomic,assign) BOOL floating;
@property (nonatomic,assign) BOOL dpadMovable;
@property (nonatomic,assign) GamePadMode mode;

- (id)initWithConfig:(NSString*)path section:(NSString*)section;

@end
