/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997-2010 Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

    Sam Lantinga
    slouken@libsdl.org
*/

#import <UIKit/UIKit.h>
#include "SDL_stdinc.h"
#include "SDL_mouse.h"
#include "SDL_mouse_c.h"
#include "SDL_events.h"

#ifdef IPHONEOS
#define MAX_SIMULTANEOUS_TOUCHES 2 /* Two fingers are enough */

/* Mouse hold status */
#define MOUSE_HOLD_NO   0
#define MOUSE_HOLD_WAIT 1
#define MOUSE_HOLD_YES  2

#define POSITION_CHANGE_THRESHOLD 15 /* Cancel hold If finger pos move beyond this */
#define MOUSE_HOLD_INTERVAL 1.5f /* mouse hold happens after 1s */
#define TAP_THRESHOLD 0.3f /* Tap interval should be less than 0.3s */

typedef struct {
    CGPoint ptOrig;
    int leftHold;
    int mouseHold;
    NSTimeInterval timestamp;
} ExtMice;

@protocol MouseHoldDelegate

-(void)onHold:(CGPoint)pt;
-(void)cancelHold:(CGPoint)pt;

@end


#else
#if SDL_IPHONE_MULTIPLE_MICE
#define MAX_SIMULTANEOUS_TOUCHES 5
#else
#define MAX_SIMULTANEOUS_TOUCHES 1
#endif
#endif

/* *INDENT-OFF* */
#if SDL_IPHONE_KEYBOARD
@interface SDL_uikitview : UIView<UITextFieldDelegate> {
#else
@interface SDL_uikitview : UIView {
#endif
		
	SDL_Mouse mice[MAX_SIMULTANEOUS_TOUCHES];

#ifdef IPHONEOS
    ExtMice extmice[MAX_SIMULTANEOUS_TOUCHES];
    id<MouseHoldDelegate> mouseHoldDelegate;
#endif
    
#if SDL_IPHONE_KEYBOARD
	UITextField *textField;
	BOOL keyboardVisible;
#endif	
    
}
#ifdef IPHONEOS
@property (nonatomic,assign)  id<MouseHoldDelegate> mouseHoldDelegate;
    
- (void)sendMouseEvent:(int)index left:(BOOL)isLeft down:(BOOL)isDown;
    
#endif
    
    
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

#if SDL_IPHONE_KEYBOARD
- (void)showKeyboard;
- (void)hideKeyboard;
- (void)initializeKeyboard;
@property (readonly) BOOL keyboardVisible;
#endif 

@end
/* *INDENT-ON* */
