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

//
// This is a total rewrite of original implementation.
//
// We only support 1 mouse.
//
// The trackpad behavior:
//  - pan around is translated to mouse move
//  - tap is left click
//  - tap while another finger is down is right click
//
// Also: convert pointer move events (bluetooth mouse) to mouse events.
//
// By Chaoji Li, Aug 22, 2020
//
#import <UIKit/UIKit.h>
#include "SDL_stdinc.h"
#include "SDL_mouse.h"
#include "SDL_mouse_c.h"
#include "SDL_events.h"


@protocol MouseHoldDelegate

-(void)onHold:(CGPoint)pt;
-(void)cancelHold:(CGPoint)pt;
-(void)onHoldMoved:(CGPoint)pt;

@end

/* *INDENT-OFF* */
#if SDL_IPHONE_KEYBOARD
@interface SDL_uikitview : UIView<UITextFieldDelegate> {
#else
@interface SDL_uikitview : UIView {
#endif
		
	SDL_Mouse mice;

    id<MouseHoldDelegate> mouseHoldDelegate;
    
#if SDL_IPHONE_KEYBOARD
	UITextField *textField;
	BOOL keyboardVisible;
#endif	
    
}
@property (nonatomic,assign)  id<MouseHoldDelegate> mouseHoldDelegate;
    
- (void)sendMouseEvent:(int)index left:(BOOL)isLeft down:(BOOL)isDown;
- (void)sendMouseMotion:(int)index x:(CGFloat)x y:(CGFloat)y;
- (void)sendMouseCoordinate:(int)index x:(CGFloat)x y:(CGFloat)y;
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
