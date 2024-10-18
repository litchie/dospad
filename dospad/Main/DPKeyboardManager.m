/*
 *  Copyright (C) 2021-2024 Chaoji Li
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


#import "DPKeyboardManager.h"
#import <GameController/GameController.h>
#include "keys.h"

static DPKeyboardManager *_manager;

@interface DPKeyboardManager ()
{
    BOOL _commandPrefix;
    BOOL _commandCombo;
}

@end

@implementation DPKeyboardManager

+(DPKeyboardManager*)defaultManager
{
    if (!_manager) {
        _manager = [[DPKeyboardManager alloc] init];
    }
    return _manager;
}

// When we are switching to another app using COMMAND-TAB,
// only COMMAND pressed down event will be received, so the
// prefix flag will be always ON unless you press COMMAND again.
// Let's turn off the prefix flag here.
- (void)willResignActive
{
    _commandPrefix = NO;
    _commandCombo = NO;
}

- (id)init
{
    self = [super init];
    
    if (@available(iOS 14.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didConnect:)
                                                     name:GCKeyboardDidConnectNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnect:)
                                                 name:GCKeyboardDidDisconnectNotification
                                               object:nil];
        if ([GCKeyboard coalescedKeyboard]) {
            [self addKeyboardHandler:[GCKeyboard coalescedKeyboard]];
        }
    }
    
    return self;
}

- (int)translateToScancode:(GCKeyCode)keyCode
API_AVAILABLE(ios(14.0)){
    static NSMutableDictionary *d = nil;
    if (!d) {
        d = [NSMutableDictionary dictionary];
        [d setObject:@(SDL_SCANCODE_SPACE) forKey:@(GCKeyCodeSpacebar)];
        [d setObject:@(SDL_SCANCODE_A) forKey:@(GCKeyCodeKeyA)];
        [d setObject:@(SDL_SCANCODE_B) forKey:@(GCKeyCodeKeyB)];
        [d setObject:@(SDL_SCANCODE_C) forKey:@(GCKeyCodeKeyC)];
        [d setObject:@(SDL_SCANCODE_D) forKey:@(GCKeyCodeKeyD)];
        [d setObject:@(SDL_SCANCODE_E) forKey:@(GCKeyCodeKeyE)];
        [d setObject:@(SDL_SCANCODE_F) forKey:@(GCKeyCodeKeyF)];
        [d setObject:@(SDL_SCANCODE_G) forKey:@(GCKeyCodeKeyG)];
        [d setObject:@(SDL_SCANCODE_H) forKey:@(GCKeyCodeKeyH)];
        [d setObject:@(SDL_SCANCODE_I) forKey:@(GCKeyCodeKeyI)];
        [d setObject:@(SDL_SCANCODE_J) forKey:@(GCKeyCodeKeyJ)];
        [d setObject:@(SDL_SCANCODE_K) forKey:@(GCKeyCodeKeyK)];
        [d setObject:@(SDL_SCANCODE_L) forKey:@(GCKeyCodeKeyL)];
        [d setObject:@(SDL_SCANCODE_M) forKey:@(GCKeyCodeKeyM)];
        [d setObject:@(SDL_SCANCODE_N) forKey:@(GCKeyCodeKeyN)];
        [d setObject:@(SDL_SCANCODE_O) forKey:@(GCKeyCodeKeyO)];
        [d setObject:@(SDL_SCANCODE_P) forKey:@(GCKeyCodeKeyP)];
        [d setObject:@(SDL_SCANCODE_Q) forKey:@(GCKeyCodeKeyQ)];
        [d setObject:@(SDL_SCANCODE_R) forKey:@(GCKeyCodeKeyR)];
        [d setObject:@(SDL_SCANCODE_S) forKey:@(GCKeyCodeKeyS)];
        [d setObject:@(SDL_SCANCODE_T) forKey:@(GCKeyCodeKeyT)];
        [d setObject:@(SDL_SCANCODE_U) forKey:@(GCKeyCodeKeyU)];
        [d setObject:@(SDL_SCANCODE_V) forKey:@(GCKeyCodeKeyV)];
        [d setObject:@(SDL_SCANCODE_W) forKey:@(GCKeyCodeKeyW)];
        [d setObject:@(SDL_SCANCODE_X) forKey:@(GCKeyCodeKeyX)];
        [d setObject:@(SDL_SCANCODE_Y) forKey:@(GCKeyCodeKeyY)];
        [d setObject:@(SDL_SCANCODE_Z) forKey:@(GCKeyCodeKeyZ)];
        [d setObject:@(SDL_SCANCODE_1) forKey:@(GCKeyCodeOne)];
        [d setObject:@(SDL_SCANCODE_2) forKey:@(GCKeyCodeTwo)];
        [d setObject:@(SDL_SCANCODE_3) forKey:@(GCKeyCodeThree)];
        [d setObject:@(SDL_SCANCODE_4) forKey:@(GCKeyCodeFour)];
        [d setObject:@(SDL_SCANCODE_5) forKey:@(GCKeyCodeFive)];
        [d setObject:@(SDL_SCANCODE_6) forKey:@(GCKeyCodeSix)];
        [d setObject:@(SDL_SCANCODE_7) forKey:@(GCKeyCodeSeven)];
        [d setObject:@(SDL_SCANCODE_8) forKey:@(GCKeyCodeEight)];
        [d setObject:@(SDL_SCANCODE_9) forKey:@(GCKeyCodeNine)];
        [d setObject:@(SDL_SCANCODE_0) forKey:@(GCKeyCodeZero)];
        [d setObject:@(SDL_SCANCODE_RETURN) forKey:@(GCKeyCodeReturnOrEnter)];
        [d setObject:@(SDL_SCANCODE_ESCAPE) forKey:@(GCKeyCodeEscape)];
        [d setObject:@(SDL_SCANCODE_BACKSPACE) forKey:@(GCKeyCodeDeleteOrBackspace)];
        [d setObject:@(SDL_SCANCODE_TAB) forKey:@(GCKeyCodeTab)];
        [d setObject:@(SDL_SCANCODE_MINUS) forKey:@(GCKeyCodeHyphen)];
        [d setObject:@(SDL_SCANCODE_EQUALS) forKey:@(GCKeyCodeEqualSign)];
        [d setObject:@(SDL_SCANCODE_LEFTBRACKET) forKey:@(GCKeyCodeOpenBracket)];
        [d setObject:@(SDL_SCANCODE_RIGHTBRACKET) forKey:@(GCKeyCodeCloseBracket)];
        [d setObject:@(SDL_SCANCODE_BACKSLASH) forKey:@(GCKeyCodeBackslash)];
       // [d setObject:@(SDL_SCANCODE_UNKNOWN) forKey:@(GCKeyCodeNonUSPound)];
        [d setObject:@(SDL_SCANCODE_SEMICOLON) forKey:@(GCKeyCodeSemicolon)];
        [d setObject:@(SDL_SCANCODE_APOSTROPHE) forKey:@(GCKeyCodeQuote)];
        [d setObject:@(SDL_SCANCODE_GRAVE) forKey:@(GCKeyCodeGraveAccentAndTilde)];
        [d setObject:@(SDL_SCANCODE_COMMA) forKey:@(GCKeyCodeComma)];
        [d setObject:@(SDL_SCANCODE_PERIOD) forKey:@(GCKeyCodePeriod)];
        [d setObject:@(SDL_SCANCODE_SLASH) forKey:@(GCKeyCodeSlash)];
        [d setObject:@(SDL_SCANCODE_CAPSLOCK) forKey:@(GCKeyCodeCapsLock)];
        [d setObject:@(SDL_SCANCODE_F1) forKey:@(GCKeyCodeF1)];
        [d setObject:@(SDL_SCANCODE_F2) forKey:@(GCKeyCodeF2)];
        [d setObject:@(SDL_SCANCODE_F3) forKey:@(GCKeyCodeF3)];
        [d setObject:@(SDL_SCANCODE_F4) forKey:@(GCKeyCodeF4)];
        [d setObject:@(SDL_SCANCODE_F5) forKey:@(GCKeyCodeF5)];
        [d setObject:@(SDL_SCANCODE_F6) forKey:@(GCKeyCodeF6)];
        [d setObject:@(SDL_SCANCODE_F7) forKey:@(GCKeyCodeF7)];
        [d setObject:@(SDL_SCANCODE_F8) forKey:@(GCKeyCodeF8)];
        [d setObject:@(SDL_SCANCODE_F9) forKey:@(GCKeyCodeF9)];
        [d setObject:@(SDL_SCANCODE_F10) forKey:@(GCKeyCodeF10)];
        [d setObject:@(SDL_SCANCODE_F11) forKey:@(GCKeyCodeF11)];
        [d setObject:@(SDL_SCANCODE_F12) forKey:@(GCKeyCodeF12)];
        [d setObject:@(SDL_SCANCODE_PRINTSCREEN) forKey:@(GCKeyCodePrintScreen)];
        [d setObject:@(SDL_SCANCODE_SCROLLLOCK) forKey:@(GCKeyCodeScrollLock)];
        [d setObject:@(SDL_SCANCODE_PAUSE) forKey:@(GCKeyCodePause)];
        [d setObject:@(SDL_SCANCODE_INSERT) forKey:@(GCKeyCodeInsert)];
        [d setObject:@(SDL_SCANCODE_HOME) forKey:@(GCKeyCodeHome)];
        [d setObject:@(SDL_SCANCODE_PAGEUP) forKey:@(GCKeyCodePageUp)];
        [d setObject:@(SDL_SCANCODE_DELETE) forKey:@(GCKeyCodeDeleteForward)];
        [d setObject:@(SDL_SCANCODE_END) forKey:@(GCKeyCodeEnd)];
        [d setObject:@(SDL_SCANCODE_PAGEDOWN) forKey:@(GCKeyCodePageDown)];
        [d setObject:@(SDL_SCANCODE_RIGHT) forKey:@(GCKeyCodeRightArrow)];
        [d setObject:@(SDL_SCANCODE_LEFT) forKey:@(GCKeyCodeLeftArrow)];
        [d setObject:@(SDL_SCANCODE_DOWN) forKey:@(GCKeyCodeDownArrow)];
        [d setObject:@(SDL_SCANCODE_UP) forKey:@(GCKeyCodeUpArrow)];
        [d setObject:@(SDL_SCANCODE_NUMLOCKCLEAR) forKey:@(GCKeyCodeKeypadNumLock)];
        [d setObject:@(SDL_SCANCODE_KP_DIVIDE) forKey:@(GCKeyCodeKeypadSlash)];
        [d setObject:@(SDL_SCANCODE_KP_MULTIPLY) forKey:@(GCKeyCodeKeypadAsterisk)];
        [d setObject:@(SDL_SCANCODE_KP_MINUS) forKey:@(GCKeyCodeKeypadHyphen)];
        [d setObject:@(SDL_SCANCODE_KP_PLUS) forKey:@(GCKeyCodeKeypadPlus)];
        [d setObject:@(SDL_SCANCODE_KP_ENTER) forKey:@(GCKeyCodeKeypadEnter)];
        [d setObject:@(SDL_SCANCODE_KP_1) forKey:@(GCKeyCodeKeypad1)];
        [d setObject:@(SDL_SCANCODE_KP_2) forKey:@(GCKeyCodeKeypad2)];
        [d setObject:@(SDL_SCANCODE_KP_3) forKey:@(GCKeyCodeKeypad3)];
        [d setObject:@(SDL_SCANCODE_KP_4) forKey:@(GCKeyCodeKeypad4)];
        [d setObject:@(SDL_SCANCODE_KP_5) forKey:@(GCKeyCodeKeypad5)];
        [d setObject:@(SDL_SCANCODE_KP_6) forKey:@(GCKeyCodeKeypad6)];
        [d setObject:@(SDL_SCANCODE_KP_7) forKey:@(GCKeyCodeKeypad7)];
        [d setObject:@(SDL_SCANCODE_KP_8) forKey:@(GCKeyCodeKeypad8)];
        [d setObject:@(SDL_SCANCODE_KP_9) forKey:@(GCKeyCodeKeypad9)];
        [d setObject:@(SDL_SCANCODE_KP_0) forKey:@(GCKeyCodeKeypad0)];
        [d setObject:@(SDL_SCANCODE_KP_PERIOD) forKey:@(GCKeyCodeKeypadPeriod)];
        [d setObject:@(SDL_SCANCODE_KP_EQUALS) forKey:@(GCKeyCodeKeypadEqualSign)];
//        [d setObject:@(SDL_SCANCODE_) forKey:@(GCKeyCodeNonUSBackslash)];
        [d setObject:@(SDL_SCANCODE_APPLICATION) forKey:@(GCKeyCodeApplication)];
        [d setObject:@(SDL_SCANCODE_POWER) forKey:@(GCKeyCodePower)];
        [d setObject:@(SDL_SCANCODE_INTERNATIONAL1) forKey:@(GCKeyCodeInternational1)];
        [d setObject:@(SDL_SCANCODE_INTERNATIONAL2) forKey:@(GCKeyCodeInternational2)];
        [d setObject:@(SDL_SCANCODE_INTERNATIONAL3) forKey:@(GCKeyCodeInternational3)];
        [d setObject:@(SDL_SCANCODE_INTERNATIONAL4) forKey:@(GCKeyCodeInternational4)];
        [d setObject:@(SDL_SCANCODE_INTERNATIONAL5) forKey:@(GCKeyCodeInternational5)];
        [d setObject:@(SDL_SCANCODE_INTERNATIONAL6) forKey:@(GCKeyCodeInternational6)];
        [d setObject:@(SDL_SCANCODE_INTERNATIONAL7) forKey:@(GCKeyCodeInternational7)];
        [d setObject:@(SDL_SCANCODE_INTERNATIONAL8) forKey:@(GCKeyCodeInternational8)];
        [d setObject:@(SDL_SCANCODE_INTERNATIONAL9) forKey:@(GCKeyCodeInternational9)];
        [d setObject:@(SDL_SCANCODE_LANG1) forKey:@(GCKeyCodeLANG1)];
        [d setObject:@(SDL_SCANCODE_LANG2) forKey:@(GCKeyCodeLANG2)];
        [d setObject:@(SDL_SCANCODE_LANG3) forKey:@(GCKeyCodeLANG3)];
        [d setObject:@(SDL_SCANCODE_LANG4) forKey:@(GCKeyCodeLANG4)];
        [d setObject:@(SDL_SCANCODE_LANG5) forKey:@(GCKeyCodeLANG5)];
        [d setObject:@(SDL_SCANCODE_LANG6) forKey:@(GCKeyCodeLANG6)];
        [d setObject:@(SDL_SCANCODE_LANG7) forKey:@(GCKeyCodeLANG7)];
        [d setObject:@(SDL_SCANCODE_LANG8) forKey:@(GCKeyCodeLANG8)];
        [d setObject:@(SDL_SCANCODE_LANG9) forKey:@(GCKeyCodeLANG9)];
        [d setObject:@(SDL_SCANCODE_LCTRL) forKey:@(GCKeyCodeLeftControl)];
        [d setObject:@(SDL_SCANCODE_LSHIFT) forKey:@(GCKeyCodeLeftShift)];
        [d setObject:@(SDL_SCANCODE_LALT) forKey:@(GCKeyCodeLeftAlt)];
        [d setObject:@(SDL_SCANCODE_RCTRL) forKey:@(GCKeyCodeRightControl)];
        [d setObject:@(SDL_SCANCODE_RSHIFT) forKey:@(GCKeyCodeRightShift)];
        [d setObject:@(SDL_SCANCODE_RALT) forKey:@(GCKeyCodeRightAlt)];
    }
    NSObject *x = [d objectForKey:@(keyCode)];
    return [(NSNumber*)x intValue];
}

- (NSString*)getKeyName:(GCKeyCode)keyCode
API_AVAILABLE(ios(14.0)){
    static NSMutableDictionary *d = nil;
    if (!d) {
        d = [NSMutableDictionary dictionary];
        [d setObject:@"Spacebar" forKey:@(GCKeyCodeSpacebar)];
        [d setObject:@"KeyA" forKey:@(GCKeyCodeKeyA)];
        [d setObject:@"KeyB" forKey:@(GCKeyCodeKeyB)];
        [d setObject:@"KeyC" forKey:@(GCKeyCodeKeyC)];
        [d setObject:@"KeyD" forKey:@(GCKeyCodeKeyD)];
        [d setObject:@"KeyE" forKey:@(GCKeyCodeKeyE)];
        [d setObject:@"KeyF" forKey:@(GCKeyCodeKeyF)];
        [d setObject:@"KeyG" forKey:@(GCKeyCodeKeyG)];
        [d setObject:@"KeyH" forKey:@(GCKeyCodeKeyH)];
        [d setObject:@"KeyI" forKey:@(GCKeyCodeKeyI)];
        [d setObject:@"KeyJ" forKey:@(GCKeyCodeKeyJ)];
        [d setObject:@"KeyK" forKey:@(GCKeyCodeKeyK)];
        [d setObject:@"KeyL" forKey:@(GCKeyCodeKeyL)];
        [d setObject:@"KeyM" forKey:@(GCKeyCodeKeyM)];
        [d setObject:@"KeyN" forKey:@(GCKeyCodeKeyN)];
        [d setObject:@"KeyO" forKey:@(GCKeyCodeKeyO)];
        [d setObject:@"KeyP" forKey:@(GCKeyCodeKeyP)];
        [d setObject:@"KeyQ" forKey:@(GCKeyCodeKeyQ)];
        [d setObject:@"KeyR" forKey:@(GCKeyCodeKeyR)];
        [d setObject:@"KeyS" forKey:@(GCKeyCodeKeyS)];
        [d setObject:@"KeyT" forKey:@(GCKeyCodeKeyT)];
        [d setObject:@"KeyU" forKey:@(GCKeyCodeKeyU)];
        [d setObject:@"KeyV" forKey:@(GCKeyCodeKeyV)];
        [d setObject:@"KeyW" forKey:@(GCKeyCodeKeyW)];
        [d setObject:@"KeyX" forKey:@(GCKeyCodeKeyX)];
        [d setObject:@"KeyY" forKey:@(GCKeyCodeKeyY)];
        [d setObject:@"KeyZ" forKey:@(GCKeyCodeKeyZ)];
        [d setObject:@"One" forKey:@(GCKeyCodeOne)];
        [d setObject:@"Two" forKey:@(GCKeyCodeTwo)];
        [d setObject:@"Three" forKey:@(GCKeyCodeThree)];
        [d setObject:@"Four" forKey:@(GCKeyCodeFour)];
        [d setObject:@"Five" forKey:@(GCKeyCodeFive)];
        [d setObject:@"Six" forKey:@(GCKeyCodeSix)];
        [d setObject:@"Seven" forKey:@(GCKeyCodeSeven)];
        [d setObject:@"Eight" forKey:@(GCKeyCodeEight)];
        [d setObject:@"Nine" forKey:@(GCKeyCodeNine)];
        [d setObject:@"Zero" forKey:@(GCKeyCodeZero)];
        [d setObject:@"ReturnOrEnter" forKey:@(GCKeyCodeReturnOrEnter)];
        [d setObject:@"Escape" forKey:@(GCKeyCodeEscape)];
        [d setObject:@"DeleteOrBackspace" forKey:@(GCKeyCodeDeleteOrBackspace)];
        [d setObject:@"Tab" forKey:@(GCKeyCodeTab)];
        [d setObject:@"Spacebar" forKey:@(GCKeyCodeSpacebar)];
        [d setObject:@"Hyphen" forKey:@(GCKeyCodeHyphen)];
        [d setObject:@"EqualSign" forKey:@(GCKeyCodeEqualSign)];
        [d setObject:@"OpenBracket" forKey:@(GCKeyCodeOpenBracket)];
        [d setObject:@"CloseBracket" forKey:@(GCKeyCodeCloseBracket)];
        [d setObject:@"Backslash" forKey:@(GCKeyCodeBackslash)];
        [d setObject:@"NonUSPound" forKey:@(GCKeyCodeNonUSPound)];
        [d setObject:@"Semicolon" forKey:@(GCKeyCodeSemicolon)];
        [d setObject:@"Quote" forKey:@(GCKeyCodeQuote)];
        [d setObject:@"GraveAccentAndTilde" forKey:@(GCKeyCodeGraveAccentAndTilde)];
        [d setObject:@"Comma" forKey:@(GCKeyCodeComma)];
        [d setObject:@"Period" forKey:@(GCKeyCodePeriod)];
        [d setObject:@"Slash" forKey:@(GCKeyCodeSlash)];
        [d setObject:@"CapsLock" forKey:@(GCKeyCodeCapsLock)];
        [d setObject:@"F1" forKey:@(GCKeyCodeF1)];
        [d setObject:@"F2" forKey:@(GCKeyCodeF2)];
        [d setObject:@"F3" forKey:@(GCKeyCodeF3)];
        [d setObject:@"F4" forKey:@(GCKeyCodeF4)];
        [d setObject:@"F5" forKey:@(GCKeyCodeF5)];
        [d setObject:@"F6" forKey:@(GCKeyCodeF6)];
        [d setObject:@"F7" forKey:@(GCKeyCodeF7)];
        [d setObject:@"F8" forKey:@(GCKeyCodeF8)];
        [d setObject:@"F9" forKey:@(GCKeyCodeF9)];
        [d setObject:@"F10" forKey:@(GCKeyCodeF10)];
        [d setObject:@"F11" forKey:@(GCKeyCodeF11)];
        [d setObject:@"F12" forKey:@(GCKeyCodeF12)];
        [d setObject:@"PrintScreen" forKey:@(GCKeyCodePrintScreen)];
        [d setObject:@"ScrollLock" forKey:@(GCKeyCodeScrollLock)];
        [d setObject:@"Pause" forKey:@(GCKeyCodePause)];
        [d setObject:@"Insert" forKey:@(GCKeyCodeInsert)];
        [d setObject:@"Home" forKey:@(GCKeyCodeHome)];
        [d setObject:@"PageUp" forKey:@(GCKeyCodePageUp)];
        [d setObject:@"DeleteForward" forKey:@(GCKeyCodeDeleteForward)];
        [d setObject:@"End" forKey:@(GCKeyCodeEnd)];
        [d setObject:@"PageDown" forKey:@(GCKeyCodePageDown)];
        [d setObject:@"RightArrow" forKey:@(GCKeyCodeRightArrow)];
        [d setObject:@"LeftArrow" forKey:@(GCKeyCodeLeftArrow)];
        [d setObject:@"DownArrow" forKey:@(GCKeyCodeDownArrow)];
        [d setObject:@"UpArrow" forKey:@(GCKeyCodeUpArrow)];
        [d setObject:@"KeypadNumLock" forKey:@(GCKeyCodeKeypadNumLock)];
        [d setObject:@"KeypadSlash" forKey:@(GCKeyCodeKeypadSlash)];
        [d setObject:@"KeypadAsterisk" forKey:@(GCKeyCodeKeypadAsterisk)];
        [d setObject:@"KeypadHyphen" forKey:@(GCKeyCodeKeypadHyphen)];
        [d setObject:@"KeypadPlus" forKey:@(GCKeyCodeKeypadPlus)];
        [d setObject:@"KeypadEnter" forKey:@(GCKeyCodeKeypadEnter)];
        [d setObject:@"Keypad1" forKey:@(GCKeyCodeKeypad1)];
        [d setObject:@"Keypad2" forKey:@(GCKeyCodeKeypad2)];
        [d setObject:@"Keypad3" forKey:@(GCKeyCodeKeypad3)];
        [d setObject:@"Keypad4" forKey:@(GCKeyCodeKeypad4)];
        [d setObject:@"Keypad5" forKey:@(GCKeyCodeKeypad5)];
        [d setObject:@"Keypad6" forKey:@(GCKeyCodeKeypad6)];
        [d setObject:@"Keypad7" forKey:@(GCKeyCodeKeypad7)];
        [d setObject:@"Keypad8" forKey:@(GCKeyCodeKeypad8)];
        [d setObject:@"Keypad9" forKey:@(GCKeyCodeKeypad9)];
        [d setObject:@"Keypad0" forKey:@(GCKeyCodeKeypad0)];
        [d setObject:@"KeypadPeriod" forKey:@(GCKeyCodeKeypadPeriod)];
        [d setObject:@"KeypadEqualSign" forKey:@(GCKeyCodeKeypadEqualSign)];
        [d setObject:@"NonUSBackslash" forKey:@(GCKeyCodeNonUSBackslash)];
        [d setObject:@"Application" forKey:@(GCKeyCodeApplication)];
        [d setObject:@"Power" forKey:@(GCKeyCodePower)];
        [d setObject:@"International1" forKey:@(GCKeyCodeInternational1)];
        [d setObject:@"International2" forKey:@(GCKeyCodeInternational2)];
        [d setObject:@"International3" forKey:@(GCKeyCodeInternational3)];
        [d setObject:@"International4" forKey:@(GCKeyCodeInternational4)];
        [d setObject:@"International5" forKey:@(GCKeyCodeInternational5)];
        [d setObject:@"International6" forKey:@(GCKeyCodeInternational6)];
        [d setObject:@"International7" forKey:@(GCKeyCodeInternational7)];
        [d setObject:@"International8" forKey:@(GCKeyCodeInternational8)];
        [d setObject:@"International9" forKey:@(GCKeyCodeInternational9)];
        [d setObject:@"LANG1" forKey:@(GCKeyCodeLANG1)];
        [d setObject:@"LANG2" forKey:@(GCKeyCodeLANG2)];
        [d setObject:@"LANG3" forKey:@(GCKeyCodeLANG3)];
        [d setObject:@"LANG4" forKey:@(GCKeyCodeLANG4)];
        [d setObject:@"LANG5" forKey:@(GCKeyCodeLANG5)];
        [d setObject:@"LANG6" forKey:@(GCKeyCodeLANG6)];
        [d setObject:@"LANG7" forKey:@(GCKeyCodeLANG7)];
        [d setObject:@"LANG8" forKey:@(GCKeyCodeLANG8)];
        [d setObject:@"LANG9" forKey:@(GCKeyCodeLANG9)];
        [d setObject:@"LeftControl" forKey:@(GCKeyCodeLeftControl)];
        [d setObject:@"LeftShift" forKey:@(GCKeyCodeLeftShift)];
        [d setObject:@"LeftAlt" forKey:@(GCKeyCodeLeftAlt)];
        [d setObject:@"LeftGUI" forKey:@(GCKeyCodeLeftGUI)];
        [d setObject:@"RightControl" forKey:@(GCKeyCodeRightControl)];
        [d setObject:@"RightShift" forKey:@(GCKeyCodeRightShift)];
        [d setObject:@"RightAlt" forKey:@(GCKeyCodeRightAlt)];
        [d setObject:@"RightGUI" forKey:@(GCKeyCodeRightGUI)];
    }
    return [d objectForKey:@(keyCode)];
}

- (int)translateCommandPrefixCode:(GCKeyCode)keyCode
API_AVAILABLE(ios(14.0)){
    static NSMutableDictionary *d = nil;
    if (!d) {
        d = [NSMutableDictionary dictionary];

        // TODO This does not work
        [d setObject:@(SDL_SCANCODE_ESCAPE) forKey:@(GCKeyCodeGraveAccentAndTilde)];

        [d setObject:@(SDL_SCANCODE_ESCAPE) forKey:@(GCKeyCodeComma)];
        [d setObject:@(SDL_SCANCODE_F1) forKey:@(GCKeyCodeOne)];
        [d setObject:@(SDL_SCANCODE_F2) forKey:@(GCKeyCodeTwo)];
        [d setObject:@(SDL_SCANCODE_F3) forKey:@(GCKeyCodeThree)];
        [d setObject:@(SDL_SCANCODE_F4) forKey:@(GCKeyCodeFour)];
        [d setObject:@(SDL_SCANCODE_F5) forKey:@(GCKeyCodeFive)];
        [d setObject:@(SDL_SCANCODE_F6) forKey:@(GCKeyCodeSix)];
        [d setObject:@(SDL_SCANCODE_F7) forKey:@(GCKeyCodeSeven)];
        [d setObject:@(SDL_SCANCODE_F8) forKey:@(GCKeyCodeEight)];
        [d setObject:@(SDL_SCANCODE_F9) forKey:@(GCKeyCodeNine)];
        [d setObject:@(SDL_SCANCODE_F10) forKey:@(GCKeyCodeZero)];
        [d setObject:@(SDL_SCANCODE_F11) forKey:@(GCKeyCodeHyphen)];
        [d setObject:@(SDL_SCANCODE_F12) forKey:@(GCKeyCodeEqualSign)];
    }
    NSObject *x = [d objectForKey:@(keyCode)];
    return [(NSNumber*)x intValue];
}

- (void)addKeyboardHandler:(GCKeyboard*)keyboard
API_AVAILABLE(ios(14.0)){
    keyboard.keyboardInput.keyChangedHandler = ^(
        GCKeyboardInput * _Nonnull keyboard,
        GCControllerButtonInput * _Nonnull key,
        GCKeyCode keyCode, BOOL pressed
    ) {
       //NSLog(@"KEYBOARD %@ pressed=%d", [self getKeyName:keyCode], pressed);
        if (keyCode == GCKeyCodeLeftGUI||keyCode==GCKeyCodeRightGUI) {
            // Command key
            if (!pressed && !_commandCombo) {
                [self.delegate keyboardManagerDidReleaseHostKey:self];
            }
            _commandPrefix = pressed;
            _commandCombo = NO;
            return;
        }
        if (self.delegate) {
            if (_commandPrefix)
            {
                _commandCombo = YES;
                [self.delegate keyboardManager:self scancode:[self translateCommandPrefixCode:keyCode] pressed:pressed];
            }
            else
            {
                [self.delegate keyboardManager:self scancode:[self translateToScancode:keyCode] pressed:pressed];
            }
        }
    };
}

 - (void)didConnect:(NSNotification *)note {
    NSLog(@"keyboard connected");
     if (@available(iOS 14.0, *)) {
         GCKeyboard *keyboard = note.object;
         [self addKeyboardHandler:keyboard];
     } else {
         // Fallback on earlier versions
     }
 
 }
 
- (void)didDisconnect:(NSNotification *)note
{
    NSLog(@"keyboard disconnected");
    _commandPrefix = NO;
}

@end
