//
//  MfiControllerInputHandler.m
//  dospad
//
//  Created by Yoshi Sugawara on 4/17/16.
//
//

#import <GameController/GameController.h>
#import "MfiControllerInputHandler.h"
#include "SDL_scancode.h"
#import "Common.h"
#import "SDL.h"

extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);
extern int SDL_PrivateJoystickButton(SDL_Joystick * joystick, Uint8 button, Uint8 state);
extern int SDL_PrivateJoystickAxis(SDL_Joystick * joystick, Uint8 axis, Sint16 value);

@interface MfiControllerInputHandler() {
    SDL_Joystick *joystick;
}
@end

@implementation MfiControllerInputHandler

-(void) startRemappingControlsForMfiControllerForKey:(SDL_scancode)key {
    if ( [[GCController controllers] count] == 0 ) {
        NSLog(@"Could not find any mfi controllers!");
        return;
    }
    GCController *controller = [[GCController controllers] firstObject];
    if ( controller.extendedGamepad ) {
        controller.extendedGamepad.valueChangedHandler = ^(GCExtendedGamepad *gamepad, GCControllerElement *element) {
            if ( gamepad.buttonA.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_A];
                return;
            }
            if ( gamepad.buttonB.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_B];
                return;
            }
            if ( gamepad.buttonX.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_X];
                return;
            }
            if ( gamepad.buttonY.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_Y];
                return;
            }
            if ( gamepad.leftShoulder.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_LS];
                return;
            }
            if ( gamepad.rightShoulder.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_RS];
                return;
            }
            if ( gamepad.dpad.xAxis.value > 0.0f ) {
                [self.keyMapper mapKey:key ToControl:MFI_DPAD_RIGHT];
                return;
            }
            if ( gamepad.dpad.xAxis.value < 0.0f ) {
                [self.keyMapper mapKey:key ToControl:MFI_DPAD_LEFT];
                return;
            }
            if ( gamepad.dpad.yAxis.value > 0.0f ) {
                [self.keyMapper mapKey:key ToControl:MFI_DPAD_UP];
                return;
            }
            if ( gamepad.dpad.yAxis.value < 0.0f ) {
                [self.keyMapper mapKey:key ToControl:MFI_DPAD_DOWN];
                return;
            }
            if ( gamepad.rightTrigger.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_RT];
                return;
            }
            if ( gamepad.leftTrigger.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_LT];
                return;
            }
            self.dismiss();
        };
    } else {
        controller.gamepad.valueChangedHandler = ^(GCGamepad *gamepad, GCControllerElement *element) {
            if ( gamepad.buttonA.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_A];
                return;
            }
            if ( gamepad.buttonB.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_B];
                return;
            }
            if ( gamepad.buttonX.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_X];
                return;
            }
            if ( gamepad.buttonY.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_Y];
                return;
            }
            if ( gamepad.leftShoulder.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_LS];
                return;
            }
            if ( gamepad.rightShoulder.pressed ) {
                [self.keyMapper mapKey:key ToControl:MFI_BUTTON_RS];
                return;
            }
            if ( gamepad.dpad.xAxis.value > 0.0f ) {
                [self.keyMapper mapKey:key ToControl:MFI_DPAD_RIGHT];
                return;
            }
            if ( gamepad.dpad.xAxis.value < 0.0f ) {
                [self.keyMapper mapKey:key ToControl:MFI_DPAD_LEFT];
                return;
            }
            if ( gamepad.dpad.yAxis.value > 0.0f ) {
                [self.keyMapper mapKey:key ToControl:MFI_DPAD_UP];
                return;
            }
            if ( gamepad.dpad.yAxis.value < 0.0f ) {
                [self.keyMapper mapKey:key ToControl:MFI_DPAD_DOWN];
                return;
            }
            self.dismiss();
        };
    }
}

-(void) stopRemappingControls {
    if ( [[GCController controllers] count] == 0 ) {
        return;
    }
    GCController *controller = [[GCController controllers] firstObject];
    if ( controller.extendedGamepad ) {
        controller.extendedGamepad.valueChangedHandler = nil;
    } else {
        controller.gamepad.valueChangedHandler = nil;
    }
}

-(void) setupControllerInputsForController:(GCController*)controller {
    if ( controller == nil ) {
        return;
    }
    
    [self stopRemappingControls];
    
    void (^joystickHandler)(GCControllerDirectionPad *, float, float) = ^(GCControllerDirectionPad *dpad, float xvalue, float yvalue) {
        int maxValue = 32767;
        int x = xvalue * maxValue;
        int y = yvalue * maxValue * -1; // reverse the value
        if ( [self ensureJoystick] ) {
            SDL_PrivateJoystickAxis(joystick, 0, x);
            SDL_PrivateJoystickAxis(joystick, 1, y);
        }
    };
    
    GCControllerButtonInput *buttonX = controller.extendedGamepad ? controller.extendedGamepad.buttonX : controller.gamepad.buttonX;
    GCControllerButtonInput *buttonA = controller.extendedGamepad ? controller.extendedGamepad.buttonA : controller.gamepad.buttonA;
    GCControllerButtonInput *buttonY = controller.extendedGamepad ? controller.extendedGamepad.buttonY : controller.gamepad.buttonY;
    GCControllerButtonInput *buttonB = controller.extendedGamepad ? controller.extendedGamepad.buttonB : controller.gamepad.buttonB;
    GCControllerButtonInput *buttonRS = controller.extendedGamepad ? controller.extendedGamepad.rightShoulder : controller.gamepad.rightShoulder;
    GCControllerButtonInput *buttonLS = controller.extendedGamepad ? controller.extendedGamepad.leftShoulder : controller.gamepad.leftShoulder;
    GCControllerButtonInput *buttonRT = controller.extendedGamepad ? controller.extendedGamepad.rightTrigger : nil;
    GCControllerButtonInput *buttonLT = controller.extendedGamepad ? controller.extendedGamepad.leftTrigger : nil;
    GCControllerDirectionPad *dpad = controller.extendedGamepad ? controller.extendedGamepad.dpad : controller.gamepad.dpad;
    
    if ( controller.extendedGamepad ) {
        controller.extendedGamepad.leftThumbstick.valueChangedHandler = joystickHandler;
    }
    
    // reset all button handlers
    for (GCControllerButtonInput *buttonInput in @[buttonX,buttonY,buttonA,buttonB,buttonRS,buttonRT,buttonLS,buttonLT]) {
        buttonInput.valueChangedHandler = nil;
    }    
    
    //
    // mapped keys
    NSInteger mappedKey = [self.keyMapper getMappedKeyForControl:MFI_BUTTON_X];
    if ( mappedKey != NSNotFound ) {
        buttonX.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( pressed ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKey);
            } else {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKey);
            }
        };
    } else {
        buttonX.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( [self ensureJoystick] ) {
                SDL_PrivateJoystickButton(joystick, 0, pressed ?  SDL_PRESSED : SDL_RELEASED);
            }
        };
    }

    
    mappedKey = [self.keyMapper getMappedKeyForControl:MFI_BUTTON_Y];
    if ( mappedKey != NSNotFound ) {
        buttonY.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( pressed ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKey);
            } else {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKey);
            }
        };
    } else {
        buttonY.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( [self ensureJoystick] ) {
                SDL_PrivateJoystickButton(joystick, 2, pressed ?  SDL_PRESSED : SDL_RELEASED);
            }
        };
    }
    
    mappedKey = [self.keyMapper getMappedKeyForControl:MFI_BUTTON_A];
    if ( mappedKey != NSNotFound ) {
        buttonA.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( pressed ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKey);
            } else {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKey);
            }
        };
    } else {
        buttonA.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( [self ensureJoystick] ) {
                SDL_PrivateJoystickButton(joystick, 1, pressed ?  SDL_PRESSED : SDL_RELEASED);
            }
        };
    }
    
    mappedKey = [self.keyMapper getMappedKeyForControl:MFI_BUTTON_B];
    if ( mappedKey != NSNotFound ) {
        buttonB.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( pressed ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKey);
            } else {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKey);
            }
        };
    } else {
        buttonB.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( [self ensureJoystick] ) {
                SDL_PrivateJoystickButton(joystick, 3, pressed ?  SDL_PRESSED : SDL_RELEASED);
            }
        };
    }
    
    mappedKey = [self.keyMapper getMappedKeyForControl:MFI_BUTTON_LS];
    if ( mappedKey != NSNotFound ) {
        buttonLS.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( pressed ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKey);
            } else {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKey);
            }
        };
    }
    
    mappedKey = [self.keyMapper getMappedKeyForControl:MFI_BUTTON_RS];
    if ( mappedKey != NSNotFound ) {
        buttonRS.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( pressed ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKey);
            } else {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKey);
            }
        };
    }
    
    mappedKey = [self.keyMapper getMappedKeyForControl:MFI_BUTTON_LT];
    if ( mappedKey != NSNotFound && buttonLT != nil ) {
        buttonLT.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( pressed ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKey);
            } else {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKey);
            }
        };
    }
    
    mappedKey = [self.keyMapper getMappedKeyForControl:MFI_BUTTON_RT];
    if ( mappedKey != NSNotFound && buttonLT != nil ) {
        buttonRT.valueChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if ( pressed ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKey);
            } else {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKey);
            }
        };
    }
    
    void (^dpadHandler)(GCControllerDirectionPad *, float, float) = ^(GCControllerDirectionPad *dpad, float xvalue, float yvalue) {
        if ( [self ensureJoystick] ) {
            int maxValue = 32767;
            int x = xvalue * maxValue;
            int y = yvalue * maxValue;
            if ( x > 0 ) {
                x = maxValue;
            } else if ( x < 0 ) {
                x = -maxValue;
            }
            if ( y > 0 ) {
                y = -maxValue;
            } else if ( y < 0 ) {
                y = maxValue;
            }
            SDL_PrivateJoystickAxis(joystick, 0, x);
            SDL_PrivateJoystickAxis(joystick, 1, y);
        }
    };
    
    NSInteger mappedKeyDpadUp = [self.keyMapper getMappedKeyForControl:MFI_DPAD_UP];
    NSInteger mappedKeyDpadDown = [self.keyMapper getMappedKeyForControl:MFI_DPAD_DOWN];
    NSInteger mappedKeyDpadLeft = [self.keyMapper getMappedKeyForControl:MFI_DPAD_LEFT];
    NSInteger mappedKeyDpadRight = [self.keyMapper getMappedKeyForControl:MFI_DPAD_RIGHT];
    if ( mappedKeyDpadUp != NSNotFound || mappedKeyDpadDown != NSNotFound || mappedKeyDpadLeft != NSNotFound || mappedKeyDpadRight != NSNotFound ) {
        dpad.valueChangedHandler = ^(GCControllerDirectionPad *dpad, float xvalue, float yvalue) {
            if ( mappedKeyDpadUp != NSNotFound && yvalue > 0.0 ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKeyDpadUp);
            } else if ( mappedKeyDpadUp != NSNotFound && yvalue <= 0.0 ) {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKeyDpadUp);
            }
            
            if ( mappedKeyDpadDown != NSNotFound && yvalue < 0.0 ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKeyDpadDown);
            } else if ( mappedKeyDpadDown != NSNotFound && yvalue >= 0.0 ) {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKeyDpadDown);
            }
            
            if ( mappedKeyDpadRight != NSNotFound && xvalue > 0.0 ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKeyDpadRight);
            } else if ( mappedKeyDpadRight != NSNotFound && xvalue <= 0.0 ) {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKeyDpadRight);
            }
            
            if ( mappedKeyDpadLeft != NSNotFound && xvalue < 0.0 ) {
                SDL_SendKeyboardKey( 0, SDL_PRESSED, (int)mappedKeyDpadLeft);
            } else if ( mappedKeyDpadLeft != NSNotFound && xvalue >= 0.0 ) {
                SDL_SendKeyboardKey( 0, SDL_RELEASED, (int)mappedKeyDpadLeft);
            }
            
            // pass joystick input through
            dpadHandler(dpad, xvalue, yvalue);
            
        };
    } else {
        dpad.valueChangedHandler = dpadHandler;
    }
}

- (BOOL)ensureJoystick
{
    if (!joystick)
    {
        joystick = SDL_JoystickOpen(0);
    }
    return joystick != 0;
}


@end
