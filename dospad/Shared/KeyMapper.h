//
//  KeyMapper.h
//  
//
//  Created by Yoshi Sugawara on 4/9/16.
//
//

#import <Foundation/Foundation.h>
#include "SDL_scancode.h"

typedef NS_ENUM(NSInteger, KeyMapMappableButton) {
    MFI_BUTTON_X,
    MFI_BUTTON_A,
    MFI_BUTTON_B,
    MFI_BUTTON_Y,
    MFI_BUTTON_LT,
    MFI_BUTTON_RT,
    MFI_BUTTON_LS,
    MFI_BUTTON_RS,
    MFI_DPAD_UP,
    MFI_DPAD_DOWN,
    MFI_DPAD_LEFT,
    MFI_DPAD_RIGHT,
    ICADE_BUTTON_1,
    ICADE_BUTTON_2,
    ICADE_BUTTON_3,
    ICADE_BUTTON_4,
    ICADE_BUTTON_5,
    ICADE_BUTTON_6,
    ICADE_BUTTON_7,
    ICADE_BUTTON_8,
    ICADE_DPAD_UP,
    ICADE_DPAD_DOWN,
    ICADE_DPAD_LEFT,
    ICADE_DPAD_RIGHT
};


@interface KeyMapper : NSObject<NSCopying>

-(void)loadFromDefaults;
-(void) resetToDefaults;
-(void) saveKeyMapping;
-(void) mapKey:(SDL_scancode)keyboardKey ToControl:(KeyMapMappableButton)button;
-(void) unmapKey:(SDL_scancode)keyboardKey;
-(NSInteger) getMappedKeyForControl:(KeyMapMappableButton)button;
+(NSString*) controlToDisplayName:(KeyMapMappableButton)button;
-(NSArray*) getControlsForMappedKey:(SDL_scancode) keyboardKey;

@end
