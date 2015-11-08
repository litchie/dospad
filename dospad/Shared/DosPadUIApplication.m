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

#ifndef IS_IOS7
#define IS_IOS7 ([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
#endif
#ifndef IS_IOS9
#define IS_IOS9 ([[UIDevice currentDevice].systemVersion floatValue]>=9.0)
#endif
#define IS_64BIT (sizeof(NSUInteger)==8)

#define GSEVENT_TYPE 2
#define GSEVENT_FLAGS (IS_IOS9?10:12)

#define GSEVENTKEY_KEYCODE  (IS_64BIT?(IS_IOS9?13:19):(IS_IOS7?17:15))
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

- (void)sendkey:(int)scancode pressed:(BOOL)pressed
{
	SDL_SendKeyboardKey(0, pressed?SDL_PRESSED:SDL_RELEASED, scancode);
}

- (void)onFlagsChange:(int)eventFlags
{
	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_LSHIFT)
		[self sendkey:SDL_SCANCODE_LSHIFT pressed:!!(eventFlags & GSEVENT_FLAG_LSHIFT)];

	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_RSHIFT)
		[self sendkey:SDL_SCANCODE_RSHIFT pressed:!!(eventFlags & GSEVENT_FLAG_RSHIFT)];

	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_LCTRL)
		[self sendkey:SDL_SCANCODE_LCTRL pressed:!!(eventFlags & GSEVENT_FLAG_LCTRL)];

	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_RCTRL)
		[self sendkey:GSEVENT_FLAG_RCTRL pressed:!!(eventFlags & GSEVENT_FLAG_RCTRL)];

	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_LALT)
		[self sendkey:SDL_SCANCODE_LALT pressed:!!(eventFlags & GSEVENT_FLAG_LALT)];

	if ((eventFlags ^ lastEventFlags) & GSEVENT_FLAG_RALT)
		[self sendkey:SDL_SCANCODE_RALT pressed:!!(eventFlags & GSEVENT_FLAG_RALT)];
}

#ifndef APPSTORE

- (void)DecodeKeyEvent:(NSInteger *)eventMem
{
    NSInteger eventType = eventMem[GSEVENT_TYPE];
    NSInteger eventFlags = eventMem[GSEVENT_FLAGS];
    //NSLog(@"event flags: %i type %d", eventFlags, eventType);
    
    if (lastEventFlags ^ eventFlags) {
        [self onFlagsChange:eventFlags];
        lastEventFlags = eventFlags;
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

- (void)handleKeyUIEvent:(UIEvent *)event
{
    [super handleKeyUIEvent:event];
    
    if ([event respondsToSelector:@selector(_gsEvent)]) {
        NSInteger *eventMem;
        eventMem = (NSInteger *)[event performSelector:@selector(_gsEvent)];
        if (eventMem) {
            [self DecodeKeyEvent:eventMem];
        }
    }
}

- (void)sendEvent:(UIEvent *)event
{
	[super sendEvent:event];
	if ([event respondsToSelector:@selector(_gsEvent)]) {
		int *eventMem;
		eventMem = (int *)[event performSelector:@selector(_gsEvent)];
		if (eventMem) {
            [self DecodeKeyEvent:(NSInteger*)eventMem];
        }
    }
}
#endif

@end
