/*
 SDL - Simple DirectMedia Layer
 Copyright (C) 1997-2009 Sam Lantinga
 
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

#import "SDL_uikitview.h"

#define POSITION_CHANGE_THRESHOLD 20 /* Cancel hold If finger pos move beyond this */
#define MOUSE_HOLD_INTERVAL 1.5f /* mouse hold happens after this interval */
#define TAP_THRESHOLD 0.3f /* Tap interval should be less than 0.3s */

/* Mouse hold status */
#define MOUSE_HOLD_NO   0
#define MOUSE_HOLD_WAIT 1
#define MOUSE_HOLD_YES  2

#define MAX_PENDING_CLICKS 10

#if SDL_IPHONE_KEYBOARD
#import "SDL_keyboard_c.h"
#import "keyinfotable.h"
#import "SDL_uikitappdelegate.h"
#import "SDL_uikitwindow.h"
#import "UIExtendedTextField.h"
#endif

#ifdef IPHONEOS
// For calling
#import "SDL_keyboard_c.h"
#import "keyinfotable.h"
void SDL_init_keyboard()
{
    SDL_Keyboard keyboard;
	SDL_zero(keyboard);
	SDL_AddKeyboard(&keyboard, 0);
	SDLKey keymap[SDL_NUM_SCANCODES];
	SDL_GetDefaultKeymap(keymap);
	SDL_SetKeymap(0, 0, keymap, SDL_NUM_SCANCODES);
}
#import "DPSettings.h"

#endif

@interface SDL_uikitview ()
<UIPointerInteractionDelegate>
{
	double _pointerActiveTime;
	CGPoint _lastPointerLocation;
	BOOL _pointerActive;
	UITouch *_primaryTouch;
	CGPoint _primaryOrigin;
	int _primaryHold;
	UITouch *_secondaryTouch;
	CGPoint _secondaryOrigin;
	CFAbsoluteTime _secondaryStartTime;

	struct {
		unsigned rightClick: 1;
		unsigned down: 1;
	} _pendingClicks [MAX_PENDING_CLICKS];
	int _pendingClickIndex;
	int _pendingClickCount;
}

@end


@implementation SDL_uikitview
@synthesize mouseHoldDelegate;

- (void)dealloc
{
#if SDL_IPHONE_KEYBOARD
	SDL_DelKeyboard(0);
	[textField release];
#endif
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame: frame];
	
	if (@available(iOS 13.4, *)) {
		UIPointerInteraction *pi = [[[UIPointerInteraction alloc] initWithDelegate:self] autorelease];
		[self addInteraction:pi];
	} else {
		// Fallback on earlier versions
	}


#if SDL_IPHONE_KEYBOARD
	[self initializeKeyboard];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
#endif
	self.multipleTouchEnabled = YES;
	return self;
    
}

// MARK: Touch Events

static CGFloat CGPointDistanceToPoint(CGPoint a, CGPoint b)
{
    CGFloat dx = a.x - b.x;
    CGFloat dy = a.y - b.y;
    return sqrt(dx*dx+dy*dy);
}

- (void)beginHold
{
	if (_primaryHold != MOUSE_HOLD_WAIT)
		return;
	//NSLog(@"hold down");
	_primaryHold = MOUSE_HOLD_YES;
	
	if (self.mouseHoldDelegate) {
		[self.mouseHoldDelegate onHold:_primaryOrigin];
	}
	
	if ([DPSettings shared].tapAsClick)
		[self sendMouseEvent:0 left:YES down:YES];
}

- (void)endHold
{
	if (_primaryHold == MOUSE_HOLD_NO)
		return;
	if (_primaryHold == MOUSE_HOLD_WAIT)
	{
		//NSLog(@"cancel hold");
		[NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginHold) object:self];
	} else {
		//NSLog(@"hold up");
		if ([DPSettings shared].tapAsClick)
			[self sendMouseEvent:0 left:YES down:NO];
	}
	if (self.mouseHoldDelegate) {
		[self.mouseHoldDelegate cancelHold:CGPointZero];
	}
	_primaryHold = MOUSE_HOLD_NO;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    if (@available(iOS 13.4, *)) {
        // check touch event from hw pointer
        // directly send it as down event (e.g. drag and drop possible)
        // Note: For right click to work, you must go to
        // system settings -> General -> Trackpad&Mouse,
        // and enable secondary click.
        if (touch.type == UITouchTypeIndirectPointer) {
            if(event.buttonMask == UIEventButtonMaskPrimary) {
                [self sendMouseEvent:0 left:YES down:YES];
            }
            if(event.buttonMask == UIEventButtonMaskSecondary) {
                [self sendMouseEvent:0 left:NO down:YES];
            }
            return;
        }
    }
	if (!_primaryTouch) {
		//NSLog(@"primary began");
		_primaryTouch = touch;
		_primaryOrigin=[_primaryTouch locationInView:self];
		_primaryHold = MOUSE_HOLD_WAIT;
		[self performSelector:@selector(beginHold) withObject:nil afterDelay:MOUSE_HOLD_INTERVAL];
	} else if (!_secondaryTouch) {
		//NSLog(@"secondary began");
		_secondaryTouch = touch;
		_secondaryOrigin = [_secondaryTouch locationInView:self];
	}
    
    // if asbolute coordinate mode is active (direct touch),
    // move cursor directly to the touched point
    if([DPSettings shared].mouseAbsEnable) {
        [self sendMouseCoordinate:0 x:_primaryOrigin.x y:_primaryOrigin.y];
    }
}

// Get called if there is a mouse and you try to use finger
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	/*
     this can happen if the user puts more than 5 touches on the screen
     at once, or perhaps in other circumstances.  Usually (it seems)
     all active touches are canceled.
     */
	for (UITouch *touch in touches)
	{
		if (touch == _primaryTouch) {
			// clear all buton states
			NSLog(@"primary cancel");
			_primaryTouch = nil;
			_secondaryTouch = nil;
			[self endHold];
		} else if (touch == _secondaryTouch) {
			NSLog(@"secondary cancel");
			// If right down, we should release it as well
			// clear right button states
			_secondaryTouch = nil;
		}
	}
}

// should not use tap count to decide for double tap
// doesn't work well. because it will have two sessions
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches)
	{
        if (@available(iOS 13.4, *)) {
            // check for hw pointer button release
            if(touch.type == UITouchTypeIndirectPointer) {
                // unlike touch start, we don't have button info
                // check SDL mouse to determine button to release
                Uint8 buttonState = SDL_GetMouse(0)->buttonstate;
                if (buttonState & SDL_BUTTON(SDL_BUTTON_LEFT)) {
                    [self sendMouseEvent:0 left:YES down:NO];
                }
                if (buttonState & SDL_BUTTON(SDL_BUTTON_RIGHT)) {
                    [self sendMouseEvent:0 left:NO down:NO];
                }
                continue;
            }
        }
		if (touch == _primaryTouch) {
			
			//NSLog(@"primary ended tap count %d", (int)[_primaryTouch tapCount]);
			if ([DPSettings shared].doubleTapAsRightClick && [_primaryTouch tapCount] == 2)
			{
				[self addClick:YES];
			}
			else if ([_primaryTouch tapCount] > 0)
			{
				[self addClick:NO];
			}
			// clear all buton states
			_primaryTouch = nil;
			_secondaryTouch = nil;
			[self endHold];
		} else if (touch == _secondaryTouch) {
			NSLog(@"secondary ended tap count %d", (int)[touch tapCount]);
			
			if ([_secondaryTouch tapCount] > 0)
			{
				[self addClick:YES];
				// Don't send left button down
				[self endHold];
			}

			// If right down, we should release it as well
			// clear right button states
			_secondaryTouch = nil;
        
            // in absolute coordinate mode (direct touch mode)
            // we need to clear primary too, to prevent unintended move or click
            if([DPSettings shared].mouseAbsEnable) {
                _primaryTouch = nil;
            }
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches)
	{
		if (touch == _primaryTouch)
		{
			CGPoint a = [touch previousLocationInView:self];
			CGPoint b = [touch locationInView:self];
			//NSLog(@"primary move: %f %f",b.x-a.x, b.y-a.y);
			if (_primaryHold == MOUSE_HOLD_WAIT)
			{
				if (CGPointDistanceToPoint(b, _primaryOrigin) > POSITION_CHANGE_THRESHOLD)
				{
					[self endHold];
				}
			}
			if (_primaryHold == MOUSE_HOLD_YES)
			{
				if (self.mouseHoldDelegate)
				{
					[self.mouseHoldDelegate onHoldMoved:b];
				}
			}
            
            // send mouse motion (normal mode), or coordinate (absolute coordinate mode)
            if([DPSettings shared].mouseAbsEnable) {
                [self sendMouseCoordinate:0 x:b.x y:b.y];
            }
            else
            {
                [self sendMouseMotion:0 x:b.x-a.x y:b.y-a.y];
            }
		}
		else if (touch == _secondaryTouch)
		{
			// Don't process secondary touch movements
		}
	}
}



// MARK: SDL Mouse Messages

- (void)ensureSDLMouse
{
    if (SDL_GetNumMice() == 0)
    {
		mice.id = 0;
		mice.driverdata = NULL;
		SDL_AddMouse(&mice, "Mouse", 0, 0, 1);
        NSAssert(SDL_GetNumMice()==1, @"Can not create mouse");
		SDL_SelectMouse(0);
    }

    // update mouse relative / absolute mode, if required
    if(SDL_GetMouse(0)->relative_mode == SDL_TRUE &&
       [DPSettings shared].mouseAbsEnable == YES) {
        // mouse is currently in relative mode, but absolute mode requested
        SDL_SetRelativeMouseMode(0, SDL_FALSE); // update to absolute (non-relative) mode
    }
    if(SDL_GetMouse(0)->relative_mode == SDL_FALSE &&
       [DPSettings shared].mouseAbsEnable == NO) {
        // mouse is currently NOT in relative mode, but should be
        SDL_SetRelativeMouseMode(0, SDL_TRUE);  // update to relative mode
    }
}

- (void)sendMouseMotion:(int)index x:(CGFloat)x y:(CGFloat)y
{
	[self ensureSDLMouse];
	float mouseSpeed = [DPSettings shared].mouseSpeed;
	if (mouseSpeed == 0) mouseSpeed=0.5;
	float scale = 1+2*mouseSpeed;
	NSAssert(index==0 && SDL_GetNumMice()==1, @"Bad mouse");
	SDL_SendMouseMotion(index, 1, x*scale, y*scale, 0);
}

- (void)sendMouseCoordinate:(int)index x:(CGFloat)x y:(CGFloat)y
{
    [self ensureSDLMouse];

    // x and y scale from settings
    float xscale = [DPSettings shared].mouseAbsXScale;
    float yscale = [DPSettings shared].mouseAbsYScale;
    
    // sends the actual mouse coordinate
    SDL_SendMouseMotion(index, 0, x*xscale, y*yscale, 0);  // note 2nd argument 'relative'=0
}

- (void)sendMouseEvent:(int)index left:(BOOL)isLeft down:(BOOL)isDown
{
	[self ensureSDLMouse];
	NSAssert(index==0 && SDL_GetNumMice()==1, @"Bad mouse");
	//NSLog(@"mouse button %@ %@", isLeft?@"Left":@"Right", isDown?@"Down":@"Up");
	SDL_SendMouseButton(index,
						isDown?SDL_PRESSED:SDL_RELEASED,
						isLeft?SDL_BUTTON_LEFT:SDL_BUTTON_RIGHT);
}

// MARK: Scheduled Mouse Click Events

- (void)sendPendingClicks
{
	if (_pendingClickCount == 0)
		return;

	if (![DPSettings shared].tapAsClick)
		return;

	[self sendMouseEvent:0 left:!_pendingClicks[_pendingClickIndex].rightClick
		down:_pendingClicks[_pendingClickIndex].down];
		
	if (!_pendingClicks[_pendingClickIndex].down)
	{
		_pendingClickCount--;
		_pendingClickIndex++;
		if (_pendingClickIndex >= MAX_PENDING_CLICKS)
			_pendingClickIndex = 0;
	}
	else
	{
		_pendingClicks[_pendingClickIndex].down = 0;
	}
	
	if (_pendingClickCount > 0) {
		[self performSelector:@selector(sendPendingClicks) withObject:nil afterDelay:0.1];
	}
}

- (void)addClick:(BOOL)rightClick
{
	if (![DPSettings shared].tapAsClick)
		return;
		
	if (_pendingClickCount >= MAX_PENDING_CLICKS)
		return;
	int i = _pendingClickIndex + _pendingClickCount;
	if (i >= MAX_PENDING_CLICKS)
		i -= MAX_PENDING_CLICKS;
	_pendingClicks[i].rightClick = rightClick;
	_pendingClicks[i].down = 1;
	_pendingClickCount++;
	[NSThread cancelPreviousPerformRequestsWithTarget:self
		selector:@selector(sendPendingClicks)
		object:nil];
	[self sendPendingClicks];
}

// MARK: Pointer Interaction Delegate

- (UIPointerRegion *)pointerInteraction:(UIPointerInteraction *)interaction
	regionForRequest:(UIPointerRegionRequest *)request
	defaultRegion:(UIPointerRegion *)defaultRegion
	API_AVAILABLE(ios(13.4))
{
	CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();

	if (!_primaryTouch)
	{
		if (currentTime - _pointerActiveTime < 2.0)
		{
            if([DPSettings shared].mouseAbsEnable) {
                // absolute coordinate mode, send coord directly
                [self sendMouseCoordinate:0 x:request.location.x y:request.location.y];
            }
            else
            {
                CGFloat dx = request.location.x - _lastPointerLocation.x;
                CGFloat dy = request.location.y - _lastPointerLocation.y;
                //NSLog(@"pointer location: %f %f,  %f %f",request.location.x, request.location.y, dx, dy);
                [self sendMouseMotion:0 x:dx y:dy];
            }
		}
	}
	
	_lastPointerLocation = request.location;
	_pointerActiveTime = currentTime;
	return defaultRegion;
}

- (UIPointerStyle *)pointerInteraction:(UIPointerInteraction *)interaction
	styleForRegion:(UIPointerRegion *)region
	API_AVAILABLE(ios(13.4))
{
	return [UIPointerStyle hiddenPointerStyle];
}



/*
 MARK: Keyboard related functionality
 */
#if SDL_IPHONE_KEYBOARD

- (void)keyboardWillShow:(id)sender
{
    // we never want this keyboard to show
    // the uitextfield is our proxy for receiving external keyboard input
    //[self hideKeyboard];
}

/* Is the iPhone virtual keyboard visible onscreen? */
- (BOOL)keyboardVisible {
	return keyboardVisible;
}

/* Set ourselves up as a UITextFieldDelegate */
- (void)initializeKeyboard {
    
	textField = [[[UIExtendedTextField alloc] initWithFrame: CGRectZero] autorelease];
	textField.delegate = self;
	/* placeholder so there is something to delete! */
	textField.text = @" ";
	
	/* set UITextInputTrait properties, mostly to defaults */
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.enablesReturnKeyAutomatically = NO;
	textField.keyboardAppearance = UIKeyboardAppearanceDefault;
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.returnKeyType = UIReturnKeyDefault;
	textField.secureTextEntry = NO;
	textField.hidden = YES;
    
	keyboardVisible = NO;
	/* add the UITextField (hidden) to our view */
	[self addSubview:textField];
    [self showKeyboard];
	
	/* create our SDL_Keyboard */
	SDL_Keyboard keyboard;
	SDL_zero(keyboard);
	SDL_AddKeyboard(&keyboard, 0);
	SDLKey keymap[SDL_NUM_SCANCODES];
	SDL_GetDefaultKeymap(keymap);
	SDL_SetKeymap(0, 0, keymap, SDL_NUM_SCANCODES);
}



/* reveal onscreen virtual keyboard */
- (void)showKeyboard {
	keyboardVisible = YES;
	[textField becomeFirstResponder];
}

/* hide onscreen virtual keyboard */
- (void)hideKeyboard {
	keyboardVisible = NO;
	[textField resignFirstResponder];
}

/* UITextFieldDelegate method.  Invoked when user types something. */
- (BOOL)textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if ([string length] == 0) {
		/* it wants to replace text with nothing, ie a delete */
		SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_BACKSPACE);
		SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_BACKSPACE);
	}
	else {
		/* go through all the characters in the string we've been sent
         and convert them to key presses */
		int i;
		for (i=0; i<[string length]; i++) {
			
			unichar c = [string characterAtIndex: i];
			
			Uint16 mod = 0;
			SDL_scancode code;
			
			if (c < 127) {
				/* figure out the SDL_scancode and SDL_keymod for this unichar */
				code = unicharToUIKeyInfoTable[c].code;
				mod  = unicharToUIKeyInfoTable[c].mod;
			}
			else {
				/* we only deal with ASCII right now */
				code = SDL_SCANCODE_UNKNOWN;
				mod = 0;
			}
			
			if (mod & KMOD_SHIFT) {
				/* If character uses shift, press shift down */
				SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_LSHIFT);
			}
			/* send a keydown and keyup even for the character */
			SDL_SendKeyboardKey( 0, SDL_PRESSED, code);
			SDL_SendKeyboardKey( 0, SDL_RELEASED, code);
			if (mod & KMOD_SHIFT) {
				/* If character uses shift, press shift back up */
				SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_LSHIFT);
			}
		}
	}
	return NO; /* don't allow the edit! (keep placeholder text there) */
}

/* Terminates the editing session */
- (BOOL)textFieldShouldReturn:(UITextField*)_textField {
	//[self hideKeyboard];
    SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_RETURN);
    SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_RETURN);
	return NO;
}

#endif



@end

/* iPhone keyboard addition functions */
#if SDL_IPHONE_KEYBOARD

int SDL_iPhoneKeyboardShow(SDL_Window * window) {
	
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (nil == view) {
		SDL_SetError("Window has no view");
		return -1;
	}
	else {
		[view showKeyboard];
		return 0;
	}
}

int SDL_iPhoneKeyboardHide(SDL_Window * window) {
	
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (NULL == view) {
		SDL_SetError("Window has no view");
		return -1;
	}
	else {
		[view hideKeyboard];
		return 0;
	}
}

SDL_bool SDL_iPhoneKeyboardIsShown(SDL_Window * window) {
	
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (NULL == view) {
		SDL_SetError("Window has no view");
		return 0;
	}
	else {
		return view.keyboardVisible;
	}
}

int SDL_iPhoneKeyboardToggle(SDL_Window * window) {
	
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (NULL == view) {
		SDL_SetError("Window has no view");
		return -1;
	}
	else {
		if (SDL_iPhoneKeyboardIsShown(window)) {
			SDL_iPhoneKeyboardHide(window);
		}
		else {
			SDL_iPhoneKeyboardShow(window);
		}
		return 0;
	}
}

#else

/* stubs, used if compiled without keyboard support */

int SDL_iPhoneKeyboardShow(SDL_Window * window) {
	SDL_SetError("Not compiled with keyboard support");
	return -1;
}

int SDL_iPhoneKeyboardHide(SDL_Window * window) {
	SDL_SetError("Not compiled with keyboard support");
	return -1;
}

SDL_bool SDL_iPhoneKeyboardIsShown(SDL_Window * window) {
	return 0;
}

int SDL_iPhoneKeyboardToggle(SDL_Window * window) {
	SDL_SetError("Not compiled with keyboard support");
	return -1;
}


#endif /* SDL_IPHONE_KEYBOARD */
