//
//  MyUIApplication.m
//  dospad
//
//  Created by Taco van Dijk on 6/3/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "DosPadUIApplication.h"
#include "Common.h"
#include "keys.h"

extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);

#ifndef IS_IOS7
#define IS_IOS7 ([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
#endif
#ifndef IS_IOS9
#define IS_IOS9 ([[UIDevice currentDevice].systemVersion floatValue]>=9.0)
#endif
#define IS_64BIT (sizeof(NSUInteger)==8)

#define GSEVENT_TYPE            2
#define GSEVENT_FLAGS           (IS_64BIT?10:12)

#define GSEVENTKEY_KEYCODE      (IS_64BIT?(IS_IOS9?13:19):(IS_IOS7?17:15))

#define GSEVENT_TYPE_KEYUP      11
#define GSEVENT_TYPE_KEYDOWN    10
#define GSEVENT_TYPE_MODIFIER   12

#define GSEVENT_FLAG_LCMD       65536           // 0x00010000
#define GSEVENT_FLAG_LSHIFT     131072          // 0x00020000
#define GSEVENT_FLAG_LCTRL      1048576         // 0x00100000
#define GSEVENT_FLAG_LALT       524288          // 0x00080000

#define GSEVENT_FLAG_RSHIFT     2097152         // 0x00200000 - not sent IOS9
#define GSEVENT_FLAG_RCTRL      8388608         // 0x00800000 - not sent IOS9
#define GSEVENT_FLAG_RALT       4194304         // 0x00400000 - not sent IOS9


@implementation DosPadUIApplication

- (void)sendkey:(int)scancode pressed:(BOOL)pressed
{
	SDL_SendKeyboardKey(0, pressed?SDL_PRESSED:SDL_RELEASED, scancode);
}

- (void)onFlagsChange:(NSInteger)eventFlags
{
	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_LSHIFT)
		[self sendkey:SDL_SCANCODE_LSHIFT pressed:!!(eventFlags & GSEVENT_FLAG_LSHIFT)];

	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_RSHIFT)
		[self sendkey:SDL_SCANCODE_RSHIFT pressed:!!(eventFlags & GSEVENT_FLAG_RSHIFT)];

	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_LCTRL)
		[self sendkey:SDL_SCANCODE_LCTRL pressed:!!(eventFlags & GSEVENT_FLAG_LCTRL)];

	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_RCTRL)
		[self sendkey:SDL_SCANCODE_RCTRL pressed:!!(eventFlags & GSEVENT_FLAG_RCTRL)];

	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_LALT)
		[self sendkey:SDL_SCANCODE_LALT pressed:!!(eventFlags & GSEVENT_FLAG_LALT)];

	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_RALT)
		[self sendkey:SDL_SCANCODE_RALT pressed:!!(eventFlags & GSEVENT_FLAG_RALT)];
}

#ifndef APPSTORE

- (void)decodeKeyEvent:(NSInteger *)eventMem
{
    NSInteger eventType  = eventMem[GSEVENT_TYPE];                  // See GS_EVENTYPE_*
    NSInteger eventModifier = eventMem[GSEVENT_FLAGS];              // Indicate bitmask of 'modifiers pressed', where modifiers are SHIFT/CTRL/ALT/CAPS/WINKEY/CAPS/ETC (note, only LEFT macros above are actually sent on IOS9).
    NSInteger eventScanCode = eventMem[GSEVENTKEY_KEYCODE];         // ScanCode.
    NSInteger eventLastModifer = lastEventFlags;                    // Previous (last) modifer - used for bitmask detection of released.
    
        // For SmartKeyboard (iPad Pro)
    if (DEFS_GET_INT(kSmartKeyboardMappings) == 1) {
            // Map GRAVE(TILDE) to ESCAPE (CMD-GRAVE = GRAVE)
        if(eventScanCode == SDL_SCANCODE_GRAVE) {
            if(!(eventModifier & GSEVENT_FLAG_LCMD))
                eventScanCode = SDL_SCANCODE_ESCAPE;
            else
                eventModifier &= ~GSEVENT_FLAG_LCMD;
        }
    
            // Map CMD-1->0 to F1->F10
        if(eventModifier & GSEVENT_FLAG_LCMD &&
            eventScanCode >= SDL_SCANCODE_1 &&
            eventScanCode <= SDL_SCANCODE_0) {
        
            eventScanCode = SDL_SCANCODE_F1 + (eventScanCode-SDL_SCANCODE_1);
            eventModifier &= ~GSEVENT_FLAG_LCMD;
        }

            // Map CMD-Minus to F11
        if(eventModifier & GSEVENT_FLAG_LCMD &&
           eventScanCode == SDL_SCANCODE_MINUS) {

            eventScanCode = SDL_SCANCODE_F11;
            eventModifier &= ~GSEVENT_FLAG_LCMD;
        }

            // Map CMD-Plus to F12
        if(eventModifier & GSEVENT_FLAG_LCMD &&
           eventScanCode == SDL_SCANCODE_EQUALS) {

            eventScanCode = SDL_SCANCODE_F12;
            eventModifier &= ~GSEVENT_FLAG_LCMD;
        }
    }
    
    if(!IS_IOS9) { // preserved for backward compatiblity
        if (lastEventFlags ^ eventModifier) {
            [self onFlagsChange:eventModifier];
            lastEventFlags = eventModifier;
        }
    }
    
    bool pressed = false;
    if (eventType == GSEVENT_TYPE_KEYUP) {
        SDL_SendKeyboardKey(0, SDL_RELEASED, (int)eventScanCode);
    } else if(eventType == GSEVENT_TYPE_KEYDOWN) {
        SDL_SendKeyboardKey(0, SDL_PRESSED, (int)eventScanCode);
        pressed = true;
    } else if(IS_IOS9 && eventType == GSEVENT_TYPE_MODIFIER) {       // Send modifier as pure scancode, with PRESSED/RELEASED derived from eventModfier ('keydown' bitmask state).
        pressed = (eventModifier != 0 && eventModifier>eventLastModifer);
        SDL_SendKeyboardKey(0, pressed?SDL_PRESSED:SDL_RELEASED, (int)eventScanCode);
        lastEventFlags = eventModifier;
    }
    
    //NSLog(@"event type<%d>[%ld] code<%d>[%ld] flags<%d>[%ld|0x%08X] lastFlags[%ld|0x%08X] state[%s]", GSEVENT_TYPE, (long)eventType, GSEVENTKEY_KEYCODE, (long)eventScanCode, GSEVENT_FLAGS, (long)eventModfier, (unsigned int)eventModfier, (long)eventLastModifer, (unsigned int)eventLastModifer, pressed?"PRESSED":"RELEASED");
    //for(int i=0;i<20;i++) NSLog(@"%d [%ld]", i, (long)eventMem[i]);
}

- (void)handleKeyUIEvent:(UIEvent *)event
{
    if ([event respondsToSelector:@selector(_gsEvent)]) {
        NSInteger *eventMem;
		
        eventMem = (__bridge void*)[event performSelector:@selector(_gsEvent)];
        if (eventMem) {
            [self decodeKeyEvent:eventMem];
        }
    }
}

- (void)sendEvent:(UIEvent *)event
{
	[super sendEvent:event];
	if ([event respondsToSelector:@selector(_gsEvent)]) {
		NSInteger *eventMem;
		
		eventMem = (__bridge void*)[event performSelector:@selector(_gsEvent)];
		if (eventMem) {
            [self decodeKeyEvent:eventMem];
        }
    }
}

#endif

@end
