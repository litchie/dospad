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


typedef NS_ENUM(NSInteger, MfiGamepadButtonIndex) {
    MFI_GAMEPAD_BUTTON_A,
    MFI_GAMEPAD_BUTTON_B,
    MFI_GAMEPAD_BUTTON_X,
    MFI_GAMEPAD_BUTTON_Y,
    MFI_GAMEPAD_BUTTON_L1,
    MFI_GAMEPAD_BUTTON_L2,// trigger
    MFI_GAMEPAD_BUTTON_R1,
    MFI_GAMEPAD_BUTTON_R2,
    MFI_GAMEPAD_BUTTON_UP,
    MFI_GAMEPAD_BUTTON_DOWN,
    MFI_GAMEPAD_BUTTON_LEFT,
    MFI_GAMEPAD_BUTTON_RIGHT,
    MFI_GAMEPAD_BUTTON_TOTAL
};

#define MFI_GAMEPAD_MAX_PLAYERS 4

NS_ASSUME_NONNULL_BEGIN

@interface MfiGamepadConfiguration : NSObject

- (id)initWithConfig:(NSString*)path;
- (int)scancodeForButton:(MfiGamepadButtonIndex)buttonIndex atPlayer:(NSInteger)playerIndex;
- (void)setScancode:(int)scancode forButton:(MfiGamepadButtonIndex)buttonIndex atPlayer:(NSInteger)playerIndex;
- (BOOL)isJoystickAtPlayer:(NSInteger)playerIndex;
- (void)setJoystick:(BOOL)value atPlayer:(NSInteger)playerIndex;

- (BOOL)save;

@end

NS_ASSUME_NONNULL_END
