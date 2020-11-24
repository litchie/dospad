//
//  MfiGamepadConfiguration.h
//  iDOS
//
//  Created by Chaoji Li on 2020/10/12.
//

typedef NS_ENUM(NSInteger, MfiGamepadButtonIndex) {
    MFI_GAMEPAD_BUTTON_A,
    MFI_GAMEPAD_BUTTON_B,
    MFI_GAMEPAD_BUTTON_X,
    MFI_GAMEPAD_BUTTON_Y,
    MFI_GAMEPAD_BUTTON_L1,
    MFI_GAMEPAD_BUTTON_L2,// trigger
    MFI_GAMEPAD_BUTTON_L3,
    MFI_GAMEPAD_BUTTON_R1,
    MFI_GAMEPAD_BUTTON_R2,
    MFI_GAMEPAD_BUTTON_R3,
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
