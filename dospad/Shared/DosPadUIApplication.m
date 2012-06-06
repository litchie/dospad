//
//  MyUIApplication.m
//  dospad
//
//  Created by Taco van Dijk on 6/3/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "DosPadUIApplication.h"
#include "keys.h"

extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);

#define GSEVENT_TYPE 2
#define GSEVENT_FLAGS 12
#define GSEVENTKEY_KEYCODE 15
#define GSEVENT_TYPE_KEYUP 11
#define GSEVENT_TYPE_KEYDOWN 10
#define GSEVENT_FLAG_LSHIFT 131072
#define GSEVENT_FLAG_RSHIFT 2097152
#define GSEVENT_FLAG_LCTRL 1048576
#define GSEVENT_FLAG_RCTRL 8388608
#define GSEVENT_FLAG_LALT 524288
#define GSEVENT_FLAG_RALT 4194304
#define GSEVENT_FLAG_LCMD 65536

@implementation DosPadUIApplication

- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    
    if ([event respondsToSelector:@selector(_gsEvent)]) {
        
        int *eventMem;
        eventMem = (int *)[event performSelector:@selector(_gsEvent)];
        if (eventMem) {
            
            int eventType = eventMem[GSEVENT_TYPE];
            int eventFlags = eventMem[GSEVENT_FLAGS];
            //NSLog(@"event flags: %i", eventFlags);
            
            if((eventFlags & GSEVENT_FLAG_LSHIFT) == GSEVENT_FLAG_LSHIFT)
            {
                SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_LSHIFT);
            }
            else
            {
                SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_LSHIFT);
            }
            
            if((eventFlags & GSEVENT_FLAG_RSHIFT) == GSEVENT_FLAG_RSHIFT)
            {
                SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_RSHIFT);
            }
            else
            {
                SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_RSHIFT);
            }
            
            if((eventFlags & GSEVENT_FLAG_LCTRL) == GSEVENT_FLAG_LCTRL)
            {
                SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_LCTRL);
            }
            else
            {
                SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_LCTRL);
            }
            
            if((eventFlags & GSEVENT_FLAG_RCTRL) == GSEVENT_FLAG_RCTRL)
            {
                SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_RCTRL);
            }
            else
            {
                SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_RCTRL);
            }
            
            if((eventFlags & GSEVENT_FLAG_LALT) == GSEVENT_FLAG_LALT)
            {
                SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_LALT);
            }
            else
            {
                SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_LALT);
            }
            
            if((eventFlags & GSEVENT_FLAG_RALT) == GSEVENT_FLAG_RALT)
            {
                SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_RALT);
            }
            else
            {
                SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_RALT);
            }
            
            if((eventFlags & GSEVENT_FLAG_LCMD) == GSEVENT_FLAG_LCMD)
            {
                SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_LGUI);
            }
            else
            {
                SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_LGUI);
            }
            
            if (eventType == GSEVENT_TYPE_KEYUP) {
                int scancode = eventMem[GSEVENTKEY_KEYCODE];
                SDL_SendKeyboardKey(0, SDL_RELEASED, scancode);
            }
            
            if(eventType == GSEVENT_TYPE_KEYDOWN)
            {
                int scancode = eventMem[GSEVENTKEY_KEYCODE];
                SDL_SendKeyboardKey(0, SDL_PRESSED, scancode);
            }
        }
    }
}

@end
